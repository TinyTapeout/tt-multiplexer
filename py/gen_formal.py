#!/usr/bin/env python3
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--module")
args = parser.parse_args()

for x in range(16):
    for y in range(24):
        print(f'"{x}.{y}": "{args.module}"\n')
