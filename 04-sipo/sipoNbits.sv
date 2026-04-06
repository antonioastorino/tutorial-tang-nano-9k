// MODE
// 0 -> left shift
// 1 -> right shift
module sipoNbits 
    #(
    parameter BITS = 16,
    parameter MODE = 0 
    )
    (
        input wire clk,
        input wire s_in,
        input wire rst_n,
        output reg [BITS-1:0] p_out
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_out <= {BITS{1'b1}};
        end else begin
            case (MODE)
                0: p_out <= {p_out[BITS-2:0], s_in};
                1: p_out <= {s_in, p_out[BITS-1:1]};
                default: p_out <= {BITS{1'b0}};
            endcase
        end
    end
endmodule
