module led (
    input  wire btn_a,      
    input  wire btn_b,      
    output reg [1:0] leds   
    );

    assign leds[0] = btn_a;
    assign leds[1] = btn_b;
endmodule
