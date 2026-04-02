module top
    (
        input wire sys_clk,
        input wire btn_s1,
        input wire  btn_s2,
        output reg [5:0] leds
    );
    parameter BITS = 6;
    parameter FREQ = 4; // Frequency in Hz
    wire [BITS-1:0] sipo_val;

    reg [24:0] count;
    reg slow_clk;

    always @(posedge sys_clk) begin
        count <= count + 1;
        if (count == 27000000 / FREQ) begin
            count <= 0;
        end
        if (count < (27000000 / 2 / FREQ)) begin
            slow_clk <= 1;
        end else begin
            slow_clk <= 0;
        end
    end

    sipoNbits
    #(.BITS(BITS))
    sipo_inst
    (
        .clk(slow_clk),
        .rst_n(btn_s1),
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
