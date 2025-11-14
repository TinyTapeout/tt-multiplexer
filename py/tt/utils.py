#!/usr/bin/env python3

#
# Tiny Tapeout
#
# Utiliy classes
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import yaml

from collections import namedtuple


__all__ = [ 'ConfigNode', 'LayoutNode', 'Point', 'Rect', 'LayoutDimension' ]


class ConfigNode:

	def __init__(self, init = None):
		self._cfg = {}

		if init is not None:
			for k,v in init.items():
				self[k] = v

	def __getattr__(self, k):
		try:
			return self._cfg[k]
		except KeyError:
			raise AttributeError()

	def __setattr__(self, k, v):
		if k[0] != '_':
			# Convert sub-dict to ConfigNode
			if isinstance(v, dict):
				self._cfg[k] = self.__class__(v)
			else:
				self._cfg[k] = v
		else:
			super().__setattr__(k,v)

	def __getitem__(self, k):
		return self._cfg[k]

	def __setitem__(self, k, v):
		self.__setattr__(k, v)

	def __contains__(self, k):
		return k in self._cfg

	def items(self):
		return self._cfg.items()

	def update_from_dict(self, upd_dict):
		for k, nv in upd_dict.items():
			if k not in self:
				self[k] = nv
			else:
				cv = self._cfg[k]
				if isinstance(cv, ConfigNode):
					if not isinstance(nv, dict):
						raise RuntimeError(f'Invalid Config update type for key {k}')
					cv.update_from_dict(nv)
				else:
					self._cfg[k] = nv

	def update_from_yaml(self, stream):
		self.update_from_dict(yaml.load(stream, yaml.FullLoader))


class LayoutNode:

	def __init__(self, init=None):
		self._dat = {}

		if init is not None:
			for k,v in init.items():
				self[k] = v

	def __getattr__(self, k):
		try:
			return self._dat[k]
		except KeyError:
			raise AttributeError()

	def __setattr__(self, k, v):
		if k[0] != '_':
			# Process value
			if isinstance(v, dict):
				# Dict become LayoutNodes
				v = self.__class__(v)

			elif isinstance(v, int):
				# Integer become LayoutDimension
				v = LayoutDimension(v)

			elif isinstance(v, self.__class__):
				# Nothing to do
				pass

			else:
				# Unsupported
				raise ValueError('Unsupported type in LayoutNode')

			self._dat[k] = v
		else:
			super().__setattr__(k,v)

	def __getitem__(self, k):
		return self._dat[k]

	def __setitem__(self, k, v):
		self.__setattr__(k, v)


class Point(namedtuple('Point', 'x y')):

	__slots__ = []

	def __add__(self, other):
		return Point(self.x + other.x, self.y + other.y)


class Rect(namedtuple('Rect', 'x0 y0 x1 y1')):

	__slots__ = []

	@property
	def ll(self):
		return Point(self.x0, self.y0)

	@property
	def lr(self):
		return Point(self.x1, self.y0)

	@property
	def ul(self):
		return Point(self.x0, self.y1)

	@property
	def ur(self):
		return Point(self.x1, self.y1)

	@property
	def w(self):
		return self.x1 - self.x0

	@property
	def h(self):
		return self.y1 - self.y0

	@property
	def c(self):
		return Point(
			(self.x0 + self.x1) // 2,
			(self.y0 + self.y1) // 2,
		)

	def move(self, xofs, yofs):
		return Rect(self.x0 + xofs, self.y0 + yofs, self.x1 + xofs, self.y1 + yofs)


class LayoutDimension(int):

	__iu_scale = 1000

	@classmethod
	def set_iu_scale(self, scale):
		LayoutDimension.__iu_scale = scale

	@classmethod
	def from_iu(kls, iu):
		return kls(1000 * iu // kls.__iu_scale)

	def __new__(kls, value, *args, **kwargs):
		return  super(kls, kls).__new__(kls, value)

	def __add__(self, other):
		return self.__class__(int(self) + int(other))

	__radd__ = __add__

	def __sub__(self, other):
		return self.__class__(int(self) - int(other))

	def __rsub__(self, other):
		return self.__class__(int(other) - int(self))

	def __mul__(self, other):
		if isinstance(other, self.__class__):
			raise ValueError("Can't multiply two LayoutDimension")
		return self.__class__(int(self) * int(other))

	def __rmul__(self, other):
		if isinstance(other, self.__class__):
			raise ValueError("Can't multiply two LayoutDimension")
		return self.__class__(int(self) * int(other))

	def __floordiv__(self, other):
		if isinstance(other, self.__class__):
			return int(self) // int(other)
		else:
			return self.__class__(int(self) // int(other))

	def __str__(self):
		return "%d" % int(self)

	def __repr__(self):
		return "LayoutDimension(%d nm)" % int(self)

	@property
	def nm(self):
		return int(self)

	@property
	def um(self):
		return self / 1000.0

	@property
	def iu(self):
		return int(round(int(self) / 1000.0 * self.__iu_scale))

