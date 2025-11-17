/*
 * tt_um_tpl.v
 *
 * Dummy user module template used as a STA standin
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module {mod_name} (
	input  wire VGND,
	input  wire VDPWR,
	input  wire VAPWR,
	inout  wire [7:0] ua,
	input  wire [7:0] ui_in,
	output wire [7:0] uo_out,
	input  wire [7:0] uio_in,
	output wire [7:0] uio_out,
	output wire [7:0] uio_oe,
	input  wire       ena,
	input  wire       clk,
	input  wire       rst_n
);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_0 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[0]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_1 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[1]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_2 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[2]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_3 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[3]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_4 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[4]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_5 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[5]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_6 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[6]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_ui_in_7 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ui_in[7]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_0 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[0]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_1 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[1]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_2 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[2]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_3 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[3]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_4 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[4]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_5 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[5]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_6 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[6]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_uio_in_7 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (uio_in[7]),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_ctl_ena (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (ena),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_clk (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (clk),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_in_rst_n (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (rst_n),
		.Z    ()
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_0 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[0])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_1 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[1])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_2 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[2])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_3 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[3])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_4 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[4])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_5 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[5])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_6 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[6])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uo_out_7 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uo_out[7])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_0 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[0])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_1 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[1])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_2 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[2])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_3 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[3])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_4 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[4])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_5 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[5])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_6 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[6])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_out_7 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_out[7])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_0 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[0])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_1 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[1])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_2 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[2])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_3 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[3])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_4 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[4])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_5 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[5])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_6 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[6])
	);

	gf180mcu_fd_sc_mcu7t5v0__buf_2 buf_out_uio_oe_7 (
		.VSS  (VGND),
		.VNW  (VGND),
		.VPW  (VDPWR),
		.VDD  (VDPWR),
		.I    (),
		.Z    (uio_oe[7])
	);

endmodule // {mod_name}
