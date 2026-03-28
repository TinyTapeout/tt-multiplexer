#
# Destroy shapeless BTerms to prevent DPL-0386 errors.
# Power/NC pad_raw[] BTerms have no pin shapes; removing them
# before DetailedPlacement avoids the fatal error.
#

import odb
import click

from reader import click_odb


@click.command()
@click_odb
def remove_shapeless_bterms(reader):
	block = reader.block
	bt_to_del = []

	for bterm in block.getBTerms():
		# Check if this BTerm has any pin shapes
		has_shapes = False
		for bpin in bterm.getBPins():
			if len(bpin.getBoxes()) > 0:
				has_shapes = True
				break

		if not has_shapes:
			# Only destroy if the net has no internal connections either,
			# so we don't accidentally disconnect real logic (e.g. future analog pads)
			net = bterm.getNet()
			if net is None or net.getITermCount() == 0:
				bt_to_del.append(bterm)

	for bt in bt_to_del:
		odb.dbBTerm.destroy(bt)

	print(f"  Destroyed {len(bt_to_del)} shapeless BTerms")


if __name__ == "__main__":
	remove_shapeless_bterms()
