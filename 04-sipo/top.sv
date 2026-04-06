module top
    (
        input wire sys_clk,
        input wire btn_s1,
        input wire  btn_s2,
        output wire [5:0] leds
    );
    parameter BITS = 6;
    parameter MODE = 1;
    parameter FREQ = 4; // Frequency in Hz
    wire [BITS-1:0] sipo_val;

    reg [24:0] count;
    reg slow_clk;

    always @(posedge sys_clk) begin
        if (count >= (27000000 / FREQ - 1)) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end
        slow_clk <= (count < (27000000 / 2 / FREQ)) ?  1'b1 : 1'b0;
    end

    sipoNbits
    #(
        .BITS(BITS),
        .MODE(MODE)
    )
    sipo_inst
    (
        .clk(slow_clk),
        .rst_n(btn_s1),
        .s_in(btn_s2),
        .p_out(sipo_val)
    );

    assign leds = sipo_val;

endmodule
