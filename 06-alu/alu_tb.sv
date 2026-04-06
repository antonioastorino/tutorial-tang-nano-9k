`ifdef SIMULATION
`include "alu_defs.vh"
`timescale 1ns/1ps

module alu_tb;

    // Inputs
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [2:0]  op;
    reg         sub;

    // Outputs
    wire [31:0] result;
    wire        zero;

    // Track test results
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    alu u_alu (
        .a      (a),
        .b      (b),
        .op     (op),
        .sub    (sub),
        .result (result),
        .zero   (zero)
    );

    // Task to check a single operation
    task check;
        input [31:0] in_a;
        input [31:0] in_b;
        input [2:0]  in_op;
        input        in_sub;
        input [31:0] expected;
        input [63:0] test_name;
        begin
            a   = in_a;
            b   = in_b;
            op  = in_op;
            sub = in_sub;
            #10;
            if (result === expected) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%s] a=0x%08x b=0x%08x op=%03b sub=%b | got=0x%08x expected=0x%08x",
                    test_name, in_a, in_b, in_op, in_sub, result, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Task to check the zero flag
    task check_zero;
        input [31:0] in_a;
        input [31:0] in_b;
        input [2:0]  in_op;
        input        in_sub;
        input        expected_zero;
        input [63:0] test_name;
        begin
            a   = in_a;
            b   = in_b;
            op  = in_op;
            sub = in_sub;
            #10;
            if (zero === expected_zero) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%s] zero flag: got=%b expected=%b",
                    test_name, zero, expected_zero);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("========== ALU Testbench ==========");

        // -----------------------------------------
        // ADD (op=ALU_ADD, sub=0)
        // -----------------------------------------
        check(32'd7,          32'd3,         `ALU_ADD,  0, 32'd10,        "ADD     ");
        check(32'd0,          32'd0,         `ALU_ADD,  0, 32'd0,         "ADD_ZERO");
        check(32'hFFFFFFFF,   32'd1,         `ALU_ADD,  0, 32'd0,         "ADD_WRAP");
        check(32'h7FFFFFFF,   32'd1,         `ALU_ADD,  0, 32'h80000000,  "ADD_OVFL");

        // -----------------------------------------
        // SUB (op=ALU_ADD, sub=1)
        // -----------------------------------------
        check(32'd7,          32'd3,         `ALU_ADD,  1, 32'd4,         "SUB     ");
        check(32'd3,          32'd7,         `ALU_ADD,  1, 32'hFFFFFFFC,  "SUB_NEG ");
        check(32'd0,          32'd0,         `ALU_ADD,  1, 32'd0,         "SUB_ZERO");
        check(32'h80000000,   32'd1,         `ALU_ADD,  1, 32'h7FFFFFFF,  "SUB_OVFL");

        // -----------------------------------------
        // SLL (op=ALU_SLL, sub=0)
        // -----------------------------------------
        check(32'd1,          32'd0,         `ALU_SLL,  0, 32'd1,         "SLL_0   ");
        check(32'd1,          32'd1,         `ALU_SLL,  0, 32'd2,         "SLL_1   ");
        check(32'd1,          32'd31,        `ALU_SLL,  0, 32'h80000000,  "SLL_31  ");
        check(32'hFFFFFFFF,   32'd1,         `ALU_SLL,  0, 32'hFFFFFFFE,  "SLL_FF  ");
        check(32'd1,          32'd32,        `ALU_SLL,  0, 32'd1,         "SLL_MOD ");

        // -----------------------------------------
        // SLT (op=ALU_SLT, sub=0) â signed compare
        // -----------------------------------------
        check(32'd3,          32'd7,         `ALU_SLT,  0, 32'd1,         "SLT_T   ");
        check(32'd7,          32'd3,         `ALU_SLT,  0, 32'd0,         "SLT_F   ");
        check(32'd0,          32'd0,         `ALU_SLT,  0, 32'd0,         "SLT_EQ  ");
        check(32'hFFFFFFFF,   32'd1,         `ALU_SLT,  0, 32'd1,         "SLT_NEG ");
        check(32'd1,          32'hFFFFFFFF,  `ALU_SLT,  0, 32'd0,         "SLT_POS ");

        // -----------------------------------------
        // SLTU (op=ALU_SLTU, sub=0) â unsigned compare
        // -----------------------------------------
        check(32'd3,          32'd7,         `ALU_SLTU, 0, 32'd1,         "SLTU_T  ");
        check(32'd7,          32'd3,         `ALU_SLTU, 0, 32'd0,         "SLTU_F  ");
        check(32'd0,          32'd0,         `ALU_SLTU, 0, 32'd0,         "SLTU_EQ ");
        check(32'hFFFFFFFF,   32'd1,         `ALU_SLTU, 0, 32'd0,         "SLTU_BIG");
        check(32'd1,          32'hFFFFFFFF,  `ALU_SLTU, 0, 32'd1,         "SLTU_SML");

        // -----------------------------------------
        // XOR (op=ALU_XOR, sub=0)
        // -----------------------------------------
        check(32'hFFFFFFFF,   32'hFFFFFFFF,  `ALU_XOR,  0, 32'd0,         "XOR_SAME");
        check(32'hFFFFFFFF,   32'd0,         `ALU_XOR,  0, 32'hFFFFFFFF,  "XOR_ZERO");
        check(32'hA5A5A5A5,   32'h5A5A5A5A, `ALU_XOR,  0, 32'hFFFFFFFF,  "XOR_PAT ");
        check(32'hA5A5A5A5,   32'hA5A5A5A5, `ALU_XOR,  0, 32'd0,         "XOR_SELF");

        // -----------------------------------------
        // SRL (op=ALU_SR, sub=0) â logical right shift
        // -----------------------------------------
        check(32'h80000000,   32'd1,         `ALU_SR,   0, 32'h40000000,  "SRL_1   ");
        check(32'hFFFFFFFF,   32'd4,         `ALU_SR,   0, 32'h0FFFFFFF,  "SRL_4   ");
        check(32'hFFFFFFFF,   32'd31,        `ALU_SR,   0, 32'd1,         "SRL_31  ");
        check(32'd1,          32'd1,         `ALU_SR,   0, 32'd0,         "SRL_OUT ");
        check(32'hFFFFFFFF,   32'd32,        `ALU_SR,   0, 32'hFFFFFFFF,  "SRL_MOD ");

        // -----------------------------------------
        // SRA (op=ALU_SR, sub=1) â arithmetic right shift
        // -----------------------------------------
        check(32'h80000000,   32'd1,         `ALU_SR,   1, 32'hC0000000,  "SRA_NEG ");
        check(32'hFFFFFFFF,   32'd4,         `ALU_SR,   1, 32'hFFFFFFFF,  "SRA_NEG4");
        check(32'hFFFFFFFF,   32'd31,        `ALU_SR,   1, 32'hFFFFFFFF,  "SRA_N31 ");
        check(32'h7FFFFFFF,   32'd1,         `ALU_SR,   1, 32'h3FFFFFFF,  "SRA_POS ");
        check(32'h7FFFFFFF,   32'd31,        `ALU_SR,   1, 32'd0,         "SRA_P31 ");

        // -----------------------------------------
        // OR (op=ALU_OR, sub=0)
        // -----------------------------------------
        check(32'hA5A5A5A5,   32'h5A5A5A5A, `ALU_OR,   0, 32'hFFFFFFFF,  "OR_FULL ");
        check(32'hFFFFFFFF,   32'd0,         `ALU_OR,   0, 32'hFFFFFFFF,  "OR_ONES ");
        check(32'd0,          32'd0,         `ALU_OR,   0, 32'd0,         "OR_ZERO ");

        // -----------------------------------------
        // AND (op=ALU_AND, sub=0)
        // -----------------------------------------
        check(32'hFFFFFFFF,   32'hFFFFFFFF,  `ALU_AND,  0, 32'hFFFFFFFF,  "AND_ONES");
        check(32'hFFFFFFFF,   32'd0,         `ALU_AND,  0, 32'd0,         "AND_ZERO");
        check(32'hA5A5A5A5,   32'h5A5A5A5A, `ALU_AND,  0, 32'd0,         "AND_PAT ");
        check(32'hA5A5A5A5,   32'hFFFFFFFF,  `ALU_AND,  0, 32'hA5A5A5A5, "AND_MASK");

        // -----------------------------------------
        // Zero flag
        // -----------------------------------------
        check_zero(32'd0,     32'd0,         `ALU_ADD,  0, 1'b1,          "ZERO_SET");
        check_zero(32'd1,     32'd0,         `ALU_ADD,  0, 1'b0,          "ZERO_CLR");
        check_zero(32'd5,     32'd5,         `ALU_ADD,  1, 1'b1,          "ZERO_SUB");
        check_zero(32'hFFFF,  32'hFFFF,      `ALU_XOR,  0, 1'b1,          "ZERO_XOR");

        // -----------------------------------------
        // Summary
        // -----------------------------------------
        $display("===================================");
        $display("PASSED: %0d  FAILED: %0d", pass_count, fail_count);
        $display("===================================");

        $finish;
    end

endmodule
`endif
