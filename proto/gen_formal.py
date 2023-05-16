#!/usr/bin/env python3
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--module")
args = parser.parse_args()

with open("tt_user_module.yaml", 'w') as fh:
    for x in range(16):
        for y in range(24):
            fh.write(f'"{x}.{y}": "{args.module}"\n')
