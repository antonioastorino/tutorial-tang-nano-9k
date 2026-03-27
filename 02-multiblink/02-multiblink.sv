module top (
    input  wire sys_clk,    // 27 MHz clock  - pin 52
    input  wire btn_s1,     // reset button  - pin 4
    output wire  [5:0] led  // 6 LEDs        - pins 10,11,13,14,15,16
);

    // counter wide enough to hold 2^25
    reg [24:0] counter;
    always @(posedge sys_clk or negedge btn_s1) begin
        if (!btn_s1)
            counter <= 25'd0;
        else
            counter <= counter + 1'b1;
    end

    assign led[0] = counter[24];
    assign led[1] = counter[23];
    assign led[2] = counter[22];
    assign led[3] = counter[21];
    assign led[4] = counter[20];
    assign led[5] = counter[19];
endmodule
