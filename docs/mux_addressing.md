# Tiny Tapeout Multiplexer Addressing

Each tile address is divided in a mux select (5 MSB) and a tile select (5 LSB):

- [9:5] Mux select
- [4:0] Tile select

The mux select itself is subdivided into a distance (number of mux units) away from the controller and if it's above or below the controller:

- [9:6] Distance from controller
- [5] Side (0 is below the controller, 1 is above the controller)

The tile select is also subdivided into a distance (number of "ports" away from the spine connection in the center) and a side selection.

- [4:1] Distance from the spine connection
- [0] Side (0 is side of mux closer to the controller, 1 is the side of the mux away from controller).
