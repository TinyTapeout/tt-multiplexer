#!/usr/bin/env python3

#
# Generate a dummy config for the format tests filling
# all slots with the same module
#
# Copyright (c) 2023 Matt Venn <matt@mattvenn.net>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--module")
args = parser.parse_args()

for x in range(16):
    for y in range(24):
        print(f'"{x}.{y}": "{args.module}"\n')
