/*
 * tt_mux.v
 *
 * Row mux for two rows of user modules (Top/Bottom)
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_mux #(
	parameter integer N_UM = 16,
	parameter integer N_IO = 8,
	parameter integer N_O  = 8,
	parameter integer N_I  = 10,

	// auto-set
    parameter integer S_OW = N_O + N_IO * 2 + 2,
    parameter integer S_IW = N_I + N_IO + 10 + 1 + 2,

    parameter integer U_OW = N_O + N_IO * 2,
    parameter integer U_IW = N_I + N_IO
)(
	// Connections to user modules
	input  wire [(U_OW*N_UM)-1:0] um_ow,
	output wire [(U_IW*N_UM)-1:0] um_iw,
	output wire [      N_UM -1:0] um_ena,
	output wire [      N_UM -1:0] um_k_zero,

	// Vertical spine connection
	output wire [S_OW-1:0] spine_ow,
	input  wire [S_IW-1:0] spine_iw,

	// Config straps
	input  wire [4:0] addr,

	// Tie-offs
	output wire k_zero,
	output wire k_one
);

	assign k_one  = 1'b1;
	assign k_zero = 1'b0;

endmodule // tt_mux
