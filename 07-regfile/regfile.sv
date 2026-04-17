`include "regfile_defs.vh"

/*
 * RV32I Register File
 *
 * - 32 registers of 32 bits each (x0-x31)
 * - Two asynchronous read ports (rs1, rs2)
 * - One synchronous write port (rd), rising edge triggered
 * - x0 is hardwired to zero - reads always return 0, writes are ignored
 */

module regfile (
    input  wire                       clk,
    // Read port 1 (rs1)
    input  wire [`REG_ADDR_WIDTH-1:0] rs1_addr,
    output wire [`REG_WIDTH-1:0]      rs1_data,
    // Read port 2 (rs2)
    input  wire [`REG_ADDR_WIDTH-1:0] rs2_addr,
    output wire [`REG_WIDTH-1:0]      rs2_data,
    // Write port (rd)
    input  wire [`REG_ADDR_WIDTH-1:0] rd_addr,
    input  wire [`REG_WIDTH-1:0]      rd_data,
    input  wire                       rd_wr_en
);

    // Register array -- x0 is never written so it stays zero
    reg [`REG_WIDTH-1:0] regs [`REG_COUNT-1:0];

    // Initialize all registers to zero
    integer i;
    initial begin
        for (i = 0; i < `REG_COUNT; i = i + 1)
            regs[i] = {`REG_WIDTH{1'b0}};
    end

    // Asynchronous reads -- x0 always returns zero
    assign rs1_data = (rs1_addr == {`REG_ADDR_WIDTH{1'b0}}) ? {`REG_WIDTH{1'b0}} : regs[rs1_addr];
    assign rs2_data = (rs2_addr == {`REG_ADDR_WIDTH{1'b0}}) ? {`REG_WIDTH{1'b0}} : regs[rs2_addr];

    // Synchronous write -- x0 writes are ignored
    always @(posedge clk) begin
        if (rd_wr_en && (rd_addr != {`REG_ADDR_WIDTH{1'b0}}))
            regs[rd_addr] <= rd_data;
    end

endmodule
