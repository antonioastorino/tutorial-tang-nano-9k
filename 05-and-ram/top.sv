module top (
    input wire sys_clk,
    output wire [5:0] leds
);
    reg [5:0] mem [0:15];
    initial $readmemh("data.hex", mem);
    
    reg [3:0] addr;
    reg [23:0] divider;
    
    initial begin
        addr = 0;
        divider = 0;
    end

    always @(posedge sys_clk) begin
        divider <= divider + 1;
        if (divider == 24'd13_500_000) begin
            divider <= 0;
            addr <= addr + 2;
        end
    end
    
    wire [5:0] a = mem[addr];
    wire [5:0] b = mem[addr + 1];

    assign leds = ~(a & b);
endmodule
