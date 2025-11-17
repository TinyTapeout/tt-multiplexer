#
# OpenDB script to cleanup the database from spurious BTerms
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import odb
import click
from reader import click_odb


@click.command()
@click_odb
def route(
	reader,
):

	# Remove all BTerms that have no connections
	bt_to_del = []

	for bt in reader.block.getBTerms():
		n = bt.getNet()
		if (n.getITermCount() == 0) and (n.getBTermCount() == 1):
			bt_to_del.append(bt)

	for bt in bt_to_del:
		odb.dbBTerm.destroy(bt)


if __name__ == "__main__":
	route()
