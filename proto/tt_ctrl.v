/*
 * tt_ctrl.v
 *
 * Controller module for TinyTapout mux
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_ctrl #(
	parameter integer N_IO =  8,
	parameter integer N_O  =  8,
	parameter integer N_I  = 10,

	// auto-set
	parameter integer S_OW = N_O + N_IO * 2 + 2,
	parameter integer S_IW = N_I + N_IO + 10 + 1 + 2
)(
	// User pads connections
	input  wire  [N_IO-1:0] pad_uio_in,
	output wire  [N_IO-1:0] pad_uio_out,
	output wire  [N_IO-1:0] pad_uio_oe_n,

	output wire   [N_O-1:0] pad_uo_out,

	input  wire   [N_I-1:0] pad_ui_in,

	// Vertical spine connection
	input  wire  [S_OW-1:0] spine_ow,
	output wire  [S_IW-1:0] spine_iw,

	// Control interface
	input  wire ctrl_sel_rst_n,
	input  wire ctrl_sel_inc,
	input  wire ctrl_ena,

	// Convenient constants for top-level tie-offs
	output wire k_one,
	output wire k_zero
);

	// Signals
	// -------

	// Split spine connections
	wire            so_gh;
	wire [N_IO-1:0] so_uio_oe;
	wire [N_IO-1:0] so_uio_out;
	wire  [N_O-1:0] so_uo_out;
	wire            so_gl;

	wire            si_gh;
	wire [N_IO-1:0] si_uio_in;
	wire  [N_I-1:0] si_ui_in;
	wire      [9:0] si_sel;
	wire            si_ena;
	wire            si_gl;

	// Selection
	reg  [9:0] sel_cnt;
	wire [9:0] sel_cnt_clk;


	// Spine mapping
	// -------------

	assign { so_gh, so_uio_oe, so_uio_out, so_uo_out, so_gl } = spine_ow;

	assign pad_uio_oe_n = ~so_uio_oe;
	assign pad_uio_out  =  so_uio_out;
	assign pad_uo_out   =  so_uo_out;

	assign spine_iw = { si_gh, si_uio_in, si_ui_in, si_sel, si_ena, si_gl };

	assign si_gh     = 1'b0;
	assign si_uio_in = pad_uio_in;
	assign si_ui_in  = pad_ui_in;
	assign si_sel    = sel_cnt;
	assign si_ena    = ctrl_ena;
	assign si_gl     = 1'b0;


	// Selection
	// ---------

	genvar i;
	generate
		for (i=0; i<10; i=i+1) begin
			always @(posedge sel_cnt_clk[i] or negedge ctrl_sel_rst_n)
				if (~ctrl_sel_rst_n)
					sel_cnt[i] <= 1'b0;
				else
					sel_cnt[i] <= ~sel_cnt[i];
		end
	endgenerate

	assign sel_cnt_clk = { ~sel_cnt[8:0], ctrl_sel_inc };


	// Tie points
	// ----------

	assign k_one  = 1'b1;
	assign k_zero = 1'b0;

endmodule // tt_ctrl
