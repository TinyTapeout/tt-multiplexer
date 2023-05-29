#!/usr/bin/env python3

#
# Generate the tt_defs.vh file from the template
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import sys

from mako.template import Template

import tt


def main(argv0, tmpl_fn):

	cfg_fn = tt.TinyTapeout.get_config_file()
	cfg    = tt.ConfigNode.from_yaml(open(cfg_fn, 'r'))

	template = Template(filename=tmpl_fn)
	output = template.render(cfg=cfg)

	print(output)


if __name__ == '__main__':
	main(*sys.argv)
