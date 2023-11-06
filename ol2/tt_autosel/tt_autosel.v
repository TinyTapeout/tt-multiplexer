`default_nettype none

module tt_autosel (
    input wire clk,
    input wire rst_n,

    // I2C master interface
    input  wire scl_i,
    input  wire sda_i,
    output wire scl_o,
    output wire scl_oe_n,
    output wire sda_o,
    output wire sda_oe_n,

`ifdef DEBUG_AUTOSEL
    output wire [15:0] eeprom_data,
`endif

    // Mux ctrl interface
    output reg ctrl_sel_rst_n,
    output reg ctrl_sel_inc,
    output reg ctrl_ena
);

  localparam STATE_INIT = 0;
  localparam STATE_READ_ADDR = 1;
  localparam STATE_MUX_CTRL = 2;
  localparam STATE_IDLE = 3;

  reg [1:0] state;

  wire eeprom_busy;
  wire eeprom_error;
  wire [15:0] mux_address;
`ifdef DEBUG_AUTOSEL
  assign eeprom_data = mux_address;
`endif

  reg [9:0] addr_counter;

  i2c_eeprom i2c (
      .clk(clk),
      .rst(~rst_n),
      .start(state == STATE_INIT),
      .scl_i(scl_i),
      .sda_i(sda_i),
      .scl_o(scl_o),
      .scl_t(scl_oe_n),
      .sda_o(sda_o),
      .sda_t(sda_oe_n),
      .busy(eeprom_busy),
      .error(eeprom_error),
      .data_out(mux_address)
  );

  always @(posedge clk) begin
    if (!rst_n) begin
      state <= STATE_INIT;
      addr_counter <= 0;
      ctrl_sel_rst_n <= 0;
      ctrl_sel_inc <= 0;
      ctrl_ena <= 0;
    end else begin
      case (state)
        STATE_INIT: begin
          state <= STATE_READ_ADDR;
        end
        STATE_READ_ADDR: begin
          if (!eeprom_busy) begin
            state <= STATE_MUX_CTRL;
            ctrl_sel_rst_n <= 1;
          end
        end
        STATE_MUX_CTRL: begin
          if (ctrl_sel_inc) begin
            ctrl_sel_inc <= 0;
          end else begin
            if (addr_counter == mux_address[9:0]) begin
              ctrl_ena <= 1;
            end else begin
              ctrl_sel_inc <= 1;
              addr_counter <= addr_counter + 1;
            end
          end
        end
        STATE_IDLE: begin
          /* nothing */
        end
      endcase
    end
  end

endmodule
