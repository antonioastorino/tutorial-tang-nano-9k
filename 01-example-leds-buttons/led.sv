module led (
    input [1:0] buttons,      
    output reg [1:0] leds   
    );

    assign leds[0] = button[0];
    assign leds[1] = button[1];
endmodule
