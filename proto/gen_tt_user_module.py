#!/usr/bin/env python

from mako.template import Template
import yaml


with open('tt_user_module.yaml', 'r') as fh:
    data = yaml.load(fh, Loader=yaml.FullLoader)

to_pos = lambda s: tuple([int(v) for v in s.split('.')])
data = dict([(to_pos(k), v) for k,v in data.items()])

template = Template(filename='tt_user_module.v.mak')
output = template.render(modules=data)

with open('tt_user_module.v', 'w') as fh:
	fh.write(output)
