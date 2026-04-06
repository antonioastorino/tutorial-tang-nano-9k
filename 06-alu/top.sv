`include "alu_defs.vh"

/*
 * Top-level wrapper for ALU smoke test on Tang Nano 9K.
 * Hardwires a = 7, b = 3, op = ADD and displays low 6 bits
 * of result on the active-low LEDs.
 * Change a, b, op, sub to manually verify other operations.
 */

module top (
    output wire [5:0] led,
    output wire       zero_out
);

    wire [31:0] result;
    wire        zero;

    wire [31:0] a;
    wire [31:0] b;
    wire [2:0]  op;
    wire        sub;

    assign a   = 32'd7;
    assign b   = 32'd3;
    assign op  = `ALU_ADD;
    assign sub = 1'b0;

    alu u_alu (
        .a      (a),
        .b      (b),
        .op     (op),
        .sub    (sub),
        .result (result),
        .zero   (zero)
    );

    assign led      = ~result[5:0];
    assign zero_out = zero | (|result[31:6]);

endmodule
