module top
    (
        input wire sys_clk,
        input wire btn_s1,
        input wire  btn_s2,
        output reg [5:0] leds
    );
    parameter BITS = 6;
    wire tied_on = 1'b1;
    wire [BITS-1:0] sipo_val;

    sipoNbits
    #(.BITS(BITS))
    sipo_inst
    (
        .clk(btn_s1),
        .rst_n(tied_on),
        .s_in(btn_s2),
        .p_out(sipo_val)
    );

    genvar i;
    generate
    for (i = 0; i < 6; i = i + 1) begin
        assign leds[i] = sipo_val[i];
    end
    endgenerate

endmodule
