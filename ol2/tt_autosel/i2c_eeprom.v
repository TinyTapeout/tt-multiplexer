`default_nettype none

module i2c_eeprom #(
    parameter ADDRESS       = 7'h50,  // EEPROM I2C bus address
    parameter REG_ADDR      = 8'h00,  // EEPROM register address
    parameter CLOCK_DIVIDER = 200
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire scl_i,
    input wire sda_i,
    output wire scl_o,
    output wire scl_t,
    output wire sda_o,
    output wire sda_t,
    output reg busy,
    output reg error,
    output reg [15:0] data_out
);

  // State encoding
  localparam IDLE = 0;
  localparam WRITE_ADDRESS = 1;
  localparam READ_FIRST_BYTE = 2;
  localparam READ_SECOND_BYTE = 3;
  localparam DONE = 4;
  localparam ERROR = 5;

  reg [2:0] state = IDLE;

  reg [7:0] data_out_hi;

  wire i2c_busy;
  wire i2c_cmd_ready;
  wire i2c_data_ready;
  wire i2c_data_valid;
  wire i2c_missed_ack;
  wire [7:0] i2c_data_out;

  wire cmd_read = (state == READ_FIRST_BYTE || state == READ_SECOND_BYTE);
  wire cmd_write = (state == WRITE_ADDRESS);

  i2c_master i2c (
      .clk(clk),
      .rst(rst),
      .s_axis_cmd_address(ADDRESS),
      .s_axis_cmd_start(0),
      .s_axis_cmd_read(cmd_read),
      .s_axis_cmd_write(cmd_write),
      .s_axis_cmd_stop(state == READ_SECOND_BYTE || state == ERROR),
      .s_axis_cmd_valid(1),
      .s_axis_cmd_ready(i2c_cmd_ready),
      .s_axis_data_tdata(REG_ADDR),  // EEPROM address to read from
      .s_axis_data_tvalid(cmd_write),
      .s_axis_data_tready(i2c_data_ready),
      .m_axis_data_tdata(i2c_data_out),
      .m_axis_data_tvalid(i2c_data_valid),
      .m_axis_data_tready(cmd_read),
      .scl_i(scl_i),
      .scl_o(scl_o),
      .scl_t(scl_t),
      .sda_i(sda_i),
      .sda_o(sda_o),
      .sda_t(sda_t),
      .busy(i2c_busy),
      .bus_control(),
      .bus_active(),
      .missed_ack(i2c_missed_ack),
      .prescale(CLOCK_DIVIDER - 1),
      .stop_on_idle(1)
  );

  // Control state transitions on the positive edge of the clock
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      busy <= 1'b0;
      error <= 1'b0;
      data_out <= 16'h0000;
    end else begin
      case (state)
        IDLE: begin
          busy <= 1'b0;
          if (start && !i2c_busy) begin
            busy <= 1'b1;
            state <= WRITE_ADDRESS;
          end
        end
        WRITE_ADDRESS: begin
          if (i2c_data_ready) begin
            state <= READ_FIRST_BYTE;
          end
        end
        READ_FIRST_BYTE: begin
          if (i2c_data_valid) begin
            data_out_hi <= i2c_data_out;
            state <= READ_SECOND_BYTE;
          end
        end
        READ_SECOND_BYTE: begin
          if (i2c_data_valid) begin
            data_out <= {data_out_hi, i2c_data_out};
            state <= DONE;
          end
        end
        ERROR,
        DONE: begin
          if (!i2c_busy) begin
            busy <= 1'b0;
            state <= IDLE;
          end
        end
        default: begin
          state <= IDLE;
        end
      endcase
      if (i2c_missed_ack) begin
        data_out <= 0;
        error <= 1'b1;
        state <= ERROR;
      end
    end
  end

endmodule
