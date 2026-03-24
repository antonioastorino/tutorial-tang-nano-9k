module led (
    input button_a,      
    input button_b,      
    output reg [1:0] leds   
    );

    assign leds[0] = button_a;
    assign leds[1] = button_b;
endmodule
