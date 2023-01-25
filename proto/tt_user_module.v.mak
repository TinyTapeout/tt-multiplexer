/*
 * tt_user_module.v
 *
 * Wrapper to instanciate correct user module according to
 * grid position.
 *
 * Also maps signals to more "human" names
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_user_module #(
	// Position on grid
	parameter integer POS_X  = 0,
	parameter integer POS_Y  = 0,

	// Config
	parameter integer N_IO   = 8,
	parameter integer N_O    = 8,
	parameter integer N_I    = 10,

	// auto-set
	parameter integer N_OW = N_O + N_IO * 2 ,
	parameter integer N_IW = N_I + N_IO
)(
	output wire  [N_OW-1:0] ow,
	input  wire  [N_IW-1:0] iw,
	input  wire             ena,
	input  wire             k_zero
);

	wire [7:0] uio_in;
	wire [7:0] uio_out;
	wire [7:0] uio_oe;
	wire [7:0] uo_out;
	wire [7:0] ui_in;
	wire       clk;
	wire       rst_n;

	assign { uio_in, ui_in, rst_n, clk } = iw;
	assign ow = { uio_oe, uio_out, uo_out };

	generate
% for (py,px), uid in modules.items():
		if ((POS_Y == ${py}) && (POS_X == ${px}))
		begin
			tt_um_${uid} tt_um_${py}_${px}_I (
				.uio_in  (uio_in),
				.uio_out (uio_out),
				.uio_oe  (uio_oe),
				.uo_out  (uo_out),
				.ui_in   (ui_in),
				.ena     (ena),
				.clk     (clk),
				.rst_n   (rst_n)
			);
		end
		else
%endfor

		begin
			// Tie-off
			assign ow = { N_OW{k_zero} };
		end
	endgenerate

endmodule // tt_user_module
