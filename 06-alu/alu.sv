`include "alu_defs.vh"

/*
 * RV32I ALU
 * Supports all RV32I arithmetic, logic, shift, and compare operations.
 * Pure combinational - no clock.
 *
 * op encoding (matches funct3 from RV32I spec):
 *   ALU_ADD  (000) = ADD (sub=0) or SUB (sub=1)
 *   ALU_SLL  (001) = Shift Left Logical
 *   ALU_SLT  (010) = Set Less Than, signed
 *   ALU_SLTU (011) = Set Less Than, unsigned
 *   ALU_XOR  (100) = XOR
 *   ALU_SR   (101) = Shift Right Logical (sub=0) or Arithmetic (sub=1)
 *   ALU_OR   (110) = OR
 *   ALU_AND  (111) = AND
 */

module alu (
    input  wire [31:0] a,       // rs1 or PC
    input  wire [31:0] b,       // rs2 or immediate
    input  wire [2:0]  op,      // funct3
    input  wire        sub,     // 1 = SUB or SRA, 0 = ADD or SRL
    output reg  [31:0] result,
    output wire        zero     // 1 when result == 0 (used by branch logic later)
);

    // Internal sub signal: asserted if explicitly requested,
    // or if op is SLT (010) or SLTU (011) which always need a-b
    wire sub_i;
    assign sub_i = sub | (op == `ALU_SLT) | (op == `ALU_SLTU);

    // Adder/subtractor: subtraction is addition of two's complement
    wire [31:0] sum;
    wire [31:0] b_mux;
    wire        carry_in;

    assign b_mux    = sub_i ? ~b : b;
    assign carry_in = sub_i ? 1'b1 : 1'b0;
    assign sum      = a + b_mux + {{31{1'b0}}, carry_in};

    // Shift amount is lower 5 bits of b
    wire [4:0] shamt;
    assign shamt = b[4:0];

    // SLT: signed less-than
    // Different signs: negative operand is smaller, a[31] tells us if a is negative
    // Same signs: use sign bit of subtraction result
    wire slt_result;
    assign slt_result = (a[31] != b[31]) ? a[31] : sum[31];

    // SLTU: unsigned less-than
    wire sltu_result;
    assign sltu_result = (a < b) ? 1'b1 : 1'b0;

    // SRA: arithmetic right shift, fill with sign bit
    wire [31:0] sra_result;
    assign sra_result = $signed(a) >>> shamt;

    assign zero = (result == 32'b0);

    always @(*) begin
        case (op)
            `ALU_ADD:  result = sum;
            `ALU_SLL:  result = a << shamt;
            `ALU_SLT:  result = {31'b0, slt_result};
            `ALU_SLTU: result = {31'b0, sltu_result};
            `ALU_XOR:  result = a ^ b;
            `ALU_SR:   result = sub_i ? sra_result : (a >> shamt);
            `ALU_OR:   result = a | b;
            `ALU_AND:  result = a & b;
            default:   result = 32'b0;
        endcase
    end

endmodule
