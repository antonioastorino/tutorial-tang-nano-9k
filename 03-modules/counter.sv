module counter 
#(parameter BITS = 25)
(
    input  wire clk,
    input  wire rst_n,
    output reg [BITS-1:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {BITS{1'b0}};
        else
            count <= count + 1;
    end
endmodule
