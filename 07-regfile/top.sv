`include "regfile_defs.vh"

/*
 * Top-level wrapper for register file smoke test on Tang Nano 9K.
 * Writes 0xAA to ra (x1) on the first rising edge then continuously
 * reads ra on rs1 and zero (x0) on rs2, displaying results on LEDs.
 *
 * LED display:
 *   led[5:0] = rs1_data[5:0] -- should show 101010 (0xAA low bits)
 *   zero_out = OR of all unused bits -- should stay 0
 */

module top (
    input  wire clk,
    input  wire rst,
    output wire [5:0] led,
    output wire       zero_out
);

    wire [`REG_WIDTH-1:0]      rs1_data;
    wire [`REG_WIDTH-1:0]      rs2_data;

    reg  [`REG_ADDR_WIDTH-1:0] rd_addr;
    reg  [`REG_WIDTH-1:0]      rd_data;
    reg                        rd_wr_en;

    regfile u_regfile (
        .clk      (clk),
        .rs1_addr (`REG_RA),
        .rs1_data (rs1_data),
        .rs2_addr (`REG_ZERO),
        .rs2_data (rs2_data),
        .rd_addr  (rd_addr),
        .rd_data  (rd_data),
        .rd_wr_en (rd_wr_en)
    );

    initial begin
        rd_data  = {`REG_WIDTH{1'b0}};
        rd_addr  = `REG_RA;
        rd_wr_en = 1'b1;
    end

    always @(posedge clk) begin
        if (!rst) begin
            rd_data  <= {`REG_WIDTH{1'b0}};
        end else begin
            rd_data  <= 32'hAA;
        end
    end

    assign led      = ~rs1_data[5:0];
    assign zero_out = (|rs2_data[31:0]) | (|rs1_data[31:6]);

endmodule
