#!/usr/bin/env python3

#
# Take a module list and generates a fully placed version of it where
# each module is associated to an absolute slot
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import sys

import tt


def main(argv0, src_fn, dst_fn):
	cfg_fn = tt.TinyTapeout.get_config_file()
	cfg    = tt.ConfigNode.from_yaml(open(cfg_fn, 'r'))
	placer = tt.ModulePlacer(cfg, src_fn, verbose=True)
	placer.save_modules(dst_fn)


if __name__ == '__main__':
	main(*sys.argv)
