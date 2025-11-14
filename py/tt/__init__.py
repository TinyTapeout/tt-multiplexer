#!/usr/bin/env python3

#
# Top Level of python classes for Tiny Tapeout mux system
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os

from .utils import *
from .placer import *
from .layout import *
from .elements import *


class TinyTapeout:

	def __init__(self, config=None, modules=None):
		# Generic config / layout
		self.cfg    = self.get_config(config)
		self.layout = Layout(self.cfg)

		# Modules placement
		if modules is not False:
			# Get module file
			modules = self.get_modules_file(modules)

			# Placer / Elements
			self.placer = ModulePlacer(self.cfg, modules)
			self.die    = Die(self.layout, self.placer)

	@classmethod
	def _get_data_files(kls, user_val, env_var, default_val):
		base = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, os.path.pardir, 'cfg'))
		val = os.getenv(env_var, user_val) or default_val
		if val is None:
			return None
		rv = []
		for fn in val.split(':'):
			if not os.path.isabs(fn):
				fn = os.path.join(base, fn)
			rv.append(fn)
		return rv

	@classmethod
	def get_config_files(kls, config=None):
		DEFAULT_CONFIG = {
			'sky130A': 'sky130.yaml',
		}.get(os.getenv('PDK'))
		return kls._get_data_files(config, 'TT_CONFIG', DEFAULT_CONFIG)

	@classmethod
	def get_modules_file(kls, modules=None):
		mf = kls._get_data_files(modules, 'TT_MODULES', 'modules_placed.yaml')
		if (mf is not None) and len(mf) > 1:
			raise RuntimeError('Multiple modules files are not supported')
		return None if not mf else mf[0]

	@classmethod
	def get_config(kls, config=None):
		# Determine the config files
		config  = kls.get_config_files(config)
		if config is None:
			raise RuntimeError('Unable to load config. Make sure either PDK and/or TT_CONFIG env var is set')

		# Load actual config
		cfg = ConfigNode()
		for fn in config:
			cfg.update_from_yaml(open(fn, 'r'))

		# Check PDK
		pdk_env = os.getenv('PDK')
		if (pdk_env is not None) and (pdk_env != cfg.pdk.name):
			raise RuntimeError('Environment variable PDK set to value inconsistent with loaded config file')

		return cfg

