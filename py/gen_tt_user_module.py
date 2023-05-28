#!/usr/bin/env python3

import sys

from mako.template import Template
import yaml

def main(argv0, tmpl_fn, data_fn):

	with open(data_fn,'r') as fh:
		data = yaml.load(fh, Loader=yaml.FullLoader)

	to_pos = lambda s: tuple([int(v) for v in s.split('.')])
	data = dict([(to_pos(k), v) for k,v in data.items()])

	template = Template(filename=tmpl_fn)
	output = template.render(modules=data)

	print(output)


if __name__ == '__main__':
	main(*sys.argv)
