`default_nettype none

// Enables the eeprom_data debug output of tt_autosel:
`define DEBUG_AUTOSEL

module fpga_top (
    input  wire clk,
    input  wire rst,
    output reg  led,
    output wire uart_tx,
    inout  wire i2c_scl,
    inout  wire i2c_sda,
    output wire ctrl_sel_rst_n,
    output wire ctrl_sel_inc,
    output wire ctrl_ena
);

  parameter CLK_FREQ = 27;  // Mhz
  parameter UART_BAUD = 115200;  // Khz

  reg [31:0] counter = 0;

  wire scl_i;
  wire scl_o;
  wire scl_oe_n;

  IOBUF scl_buf (
      .O  (scl_i),
      .IO (i2c_scl),
      .I  (scl_o),
      .OEN(scl_oe_n)
  );

  wire sda_i;
  wire sda_o;
  wire sda_oe_n;

  IOBUF sda_buf (
      .O  (sda_i),
      .IO (i2c_sda),
      .I  (sda_o),
      .OEN(sda_oe_n)
  );

  // --

  wire [15:0] eeprom_data;

  tt_autosel autosel (
      .clk  (clk),
      .rst_n(rst_n),

      .eeprom_data(eeprom_data),

      // I2C master interface
      .scl_i(scl_i),
      .sda_i(sda_i),
      .scl_o(scl_o),
      .scl_oe_n(scl_oe_n),
      .sda_o(sda_o),
      .sda_oe_n(sda_oe_n),

      // Mux ctrl interface
      .ctrl_sel_rst_n(ctrl_sel_rst_n),
      .ctrl_sel_inc(ctrl_sel_inc),
      .ctrl_ena(ctrl_ena)
  );

  // --

  wire rst_n = ~rst;
  wire tx_ready;
  reg [7:0] tx_byte;
  reg tx_valid;

  uart_tx #(
      .CLK_FRE  (CLK_FREQ),
      .BAUD_RATE(UART_BAUD)
  ) uart_tx_inst (
      .clk(clk),
      .rst_n(rst_n),
      .tx_pin(uart_tx),
      .tx_data(tx_byte),
      .tx_data_valid(tx_valid),
      .tx_data_ready(tx_ready)
  );

  reg [2:0] send_index = 0;

  function [7:0] hexchar(input [3:0] value);
    case (value)
      0:  hexchar = "0";
      1:  hexchar = "1";
      2:  hexchar = "2";
      3:  hexchar = "3";
      4:  hexchar = "4";
      5:  hexchar = "5";
      6:  hexchar = "6";
      7:  hexchar = "7";
      8:  hexchar = "8";
      9:  hexchar = "9";
      10: hexchar = "A";
      11: hexchar = "B";
      12: hexchar = "C";
      13: hexchar = "D";
      14: hexchar = "E";
      15: hexchar = "F";
    endcase
  endfunction

  /* Send a byte every 1 second */
  always @(posedge clk) begin
    if (counter == 27000000) begin
      send_index <= 0;
    end else if (tx_ready) begin
      case (send_index)
        0: tx_byte <= hexchar(eeprom_data[15:12]);
        1: tx_byte <= hexchar(eeprom_data[11:8]);
        2: tx_byte <= hexchar(eeprom_data[7:4]);
        3: tx_byte <= hexchar(eeprom_data[3:0]);
        4: tx_byte <= 13;  // CR
        5: tx_byte <= 10;  // LF
      endcase
      if (send_index < 6) begin
        tx_valid   <= 1;
        send_index <= send_index + 1;
      end else begin
        tx_valid <= 0;
      end
    end
  end

  always @(posedge clk) begin
    counter <= counter + 1;
    if (counter == 27000000) begin
      counter <= 0;
      led <= ~led;
    end
  end

endmodule
