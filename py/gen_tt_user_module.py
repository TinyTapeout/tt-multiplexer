#!/usr/bin/env python3

#
# Generate the tt_user_module.v file from the template and
# configuration file for which module is in which slot
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import sys

from mako.template import Template

import tt


def main(argv0, tmpl_fn, data_fn):

	cfg_fn = tt.TinyTapeout.get_config_file()
	cfg    = tt.ConfigNode.from_yaml(open(cfg_fn, 'r'))
	placer = tt.ModulePlacer(cfg, data_fn)

	template = Template(filename=tmpl_fn)
	output = template.render(grid=placer.grid)

	print(output)


if __name__ == '__main__':
	main(*sys.argv)
