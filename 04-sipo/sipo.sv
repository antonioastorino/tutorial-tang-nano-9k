module sipoNbits #(parameter BITS = 16)
    (
        input wire s_in,
        input wire rst_n,
        input wire clk,
        output reg [BITS-1:0] p_out
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_out <= ~'d0;
        end else begin
            p_out <= {p_out[BITS-2:0], s_in};
        end
    end
endmodule
