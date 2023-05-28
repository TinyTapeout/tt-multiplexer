#!/usr/bin/env python3

#
# Draw a SVG with the layout that will be used during
# hardening
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import sys

import tt


def main(argv0, svg_out):
	tti = tt.TinyTapeout()
	tti.die.draw_to_svg(svg_out)


if __name__ == '__main__':
	main(*sys.argv)
