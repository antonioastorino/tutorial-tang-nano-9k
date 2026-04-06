module top (
    input  wire sys_clk,    // 27 MHz clock  - pin 52
    input  wire btn_s1,     // reset button  - pin 4
    output wire  [5:0] led  // 6 LEDs        - pins 10,11,13,14,15,16
);
    parameter BITS = 25;
    wire [BITS-1:0] counter_val;
    
    counter
    #(.BITS(BITS))
    counter_inst
    (
        .clk(sys_clk),
        .rst_n(btn_s1),
        .count(counter_val)
    );
    
    genvar i;
    generate
    for (i = 0; i < 6; i = i + 1) begin
        assign led[i] = counter_val[BITS-1-i];
    end
    endgenerate
endmodule
