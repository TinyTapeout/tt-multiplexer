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
% for (py,px), project in modules.items():
		if ((POS_Y == ${py}) && (POS_X == ${px}))
		begin : block_${py}_${px}
% if project.get('sram', False):
			wire ram_clk0;
			wire ram_csb0;
			wire ram_web0;
			wire [3:0] ram_wmask0;
			wire [8:0] ram_addr0;
			wire [31:0] ram_din0;
			wire [31:0] ram_dout0;

% endif
			tt_um_${project['name']} tt_um_I (
				.uio_in  (uio_in),
				.uio_out (uio_out),
				.uio_oe  (uio_oe),
				.uo_out  (uo_out),
				.ui_in   (ui_in),
				.ena     (ena),
				.clk     (clk),
				.rst_n   (rst_n)
% if project.get('sram', False):
				,
				.ram_clk0 (ram_clk0),
				.ram_csb0 (ram_csb0),
				.ram_web0 (ram_web0),
				.ram_wmask0 (ram_wmask0),
				.ram_addr0 (ram_addr0),
				.ram_din0 (ram_din0),
				.ram_dout0 (ram_dout0)
%endif
			);

% if project.get('sram', False):
			sky130_sram_2kbyte_1rw1r_32x512_8 sram (
				.clk0(ram_clk0),
				.csb0(ram_csb0),
				.web0(ram_web0),
				.wmask0(ram_wmask0),
				.addr0(ram_addr0),
				.din0(ram_din0),
				.dout0(ram_dout0),
				.clk1(k_zero),
				.csb1(k_zero),
				.addr1({32{k_zero}})
			);
% endif
		end
%endfor

% for (py,px), uid in modules.items():
		if ((POS_Y == ${py}) && (POS_X == ${px}))
		begin
		end
		else
%endfor
		begin
			// Tie-off
			assign ow = { N_OW{k_zero} };
		end
	endgenerate

endmodule // tt_user_module
