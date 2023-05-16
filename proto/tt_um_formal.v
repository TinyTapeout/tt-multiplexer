/*
 * tt_um_formal.v
 *
 * User module for formal connectivity proof
 *
 * Author: Matt Venn <matt@mattvenn.net>
 */

`default_nettype none

module tt_um_formal (
	input  wire [7:0] ui_in,	// Dedicated inputs
	output wire [7:0] uo_out,	// Dedicated outputs
	input  wire [7:0] uio_in,	// IOs: Input path
	output wire [7:0] uio_out,	// IOs: Output path
	output wire [7:0] uio_oe,	// IOs: Enable path (active high: 0=input, 1=output)
	input  wire       ena,
	input  wire       clk,
	input  wire       rst_n
);
    
    rand reg [7:0] anyseq1; assign uo_out  = anyseq1;
    
    always @(*) begin
        if(ena) begin
            assert(ui_in == uo_out);
        end else begin
            assert(ui_in == 0);
        end
    end

endmodule // tt_um_formal
