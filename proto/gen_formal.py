#!/usr/bin/env python3

with open("tt_user_module.yaml", 'w') as fh:
    for x in range(16):
        for y in range(24):
            fh.write(f'"{x}.{y}": "formal"\n')
