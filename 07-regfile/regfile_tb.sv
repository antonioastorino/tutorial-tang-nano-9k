`ifdef SIMULATION
`include "regfile_defs.vh"
`timescale 1ns/1ps

module regfile_tb;

    // Clock
    reg clk;

    // Read port 1
    reg  [`REG_ADDR_WIDTH-1:0] rs1_addr;
    wire [`REG_WIDTH-1:0]      rs1_data;

    // Read port 2
    reg  [`REG_ADDR_WIDTH-1:0] rs2_addr;
    wire [`REG_WIDTH-1:0]      rs2_data;

    // Write port
    reg  [`REG_ADDR_WIDTH-1:0] rd_addr;
    reg  [`REG_WIDTH-1:0]      rd_data;
    reg                        rd_wr_en;

    // Test tracking
    integer pass_count;
    integer fail_count;

    // Instantiate DUT
    regfile u_regfile (
        .clk      (clk),
        .rs1_addr (rs1_addr),
        .rs1_data (rs1_data),
        .rs2_addr (rs2_addr),
        .rs2_data (rs2_data),
        .rd_addr  (rd_addr),
        .rd_data  (rd_data),
        .rd_wr_en (rd_wr_en)
    );

    // 10ns clock period
    always #5 clk = ~clk;

    // Write a value and wait for rising edge
    task write_reg;
        input [`REG_ADDR_WIDTH-1:0] addr;
        input [`REG_WIDTH-1:0]      data;
        begin
            rd_addr  = addr;
            rd_data  = data;
            rd_wr_en = 1'b1;
            @(posedge clk);
            #1;
            rd_wr_en = 1'b0;
        end
    endtask

    // Check a read port value
    task check_read;
        input [`REG_ADDR_WIDTH-1:0] addr;
        input [`REG_WIDTH-1:0]      expected;
        input [127:0]               test_name;
        begin
            rs1_addr = addr;
            #1;
            if (rs1_data === expected) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%s] addr=x%02d | got=0x%08x expected=0x%08x",
                    test_name, addr, rs1_data, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Check both read ports simultaneously
    task check_dual_read;
        input [`REG_ADDR_WIDTH-1:0] addr_a;
        input [`REG_WIDTH-1:0]      expected_a;
        input [`REG_ADDR_WIDTH-1:0] addr_b;
        input [`REG_WIDTH-1:0]      expected_b;
        input [127:0]               test_name;
        begin
            rs1_addr = addr_a;
            rs2_addr = addr_b;
            #1;
            if (rs1_data === expected_a && rs2_data === expected_b) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%s] | rs1 got=0x%08x expected=0x%08x | rs2 got=0x%08x expected=0x%08x",
                    test_name, rs1_data, expected_a, rs2_data, expected_b);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk      = 1'b0;
        rs1_addr = {`REG_ADDR_WIDTH{1'b0}};
        rs2_addr = {`REG_ADDR_WIDTH{1'b0}};
        rd_addr  = {`REG_ADDR_WIDTH{1'b0}};
        rd_data  = {`REG_WIDTH{1'b0}};
        rd_wr_en = 1'b0;
        pass_count = 0;
        fail_count = 0;

        $display("========== Register File Testbench ==========");

        // -----------------------------------------
        // x0 always reads as zero
        // -----------------------------------------
        check_read(5'd0, 32'd0, "X0_ZERO_INIT    ");

        // x0 write is ignored
        write_reg(5'd0, 32'hDEADBEEF);
        check_read(5'd0, 32'd0, "X0_WRITE_IGNORE ");

        // -----------------------------------------
        // Basic write and read back
        // -----------------------------------------
        write_reg(5'd1, 32'hAAAAAAAA);
        check_read(5'd1, 32'hAAAAAAAA, "WR_RD_X1        ");

        write_reg(5'd31, 32'h12345678);
        check_read(5'd31, 32'h12345678, "WR_RD_X31       ");

        // -----------------------------------------
        // Overwrite a register
        // -----------------------------------------
        write_reg(5'd1, 32'h00000001);
        check_read(5'd1, 32'h00000001, "OVERWRITE_X1    ");

        // -----------------------------------------
        // Write enable gating -- no write when wr_en=0
        // -----------------------------------------
        rs1_addr = 5'd2;
        rd_addr  = 5'd2;
        rd_data  = 32'hDEADBEEF;
        rd_wr_en = 1'b0;
        @(posedge clk);
        #1;
        check_read(5'd2, 32'd0, "WR_EN_GATE      ");

        // -----------------------------------------
        // Dual read port -- read two different regs simultaneously
        // -----------------------------------------
        write_reg(5'd3, 32'hCAFEBABE);
        write_reg(5'd4, 32'h0000FFFF);
        check_dual_read(5'd3, 32'hCAFEBABE, 5'd4, 32'h0000FFFF, "DUAL_READ       ");

        // -----------------------------------------
        // Dual read with one port reading x0
        // -----------------------------------------
        check_dual_read(5'd0, 32'd0, 5'd3, 32'hCAFEBABE, "DUAL_READ_X0    ");

        // -----------------------------------------
        // Read during write (same cycle) -- write is synchronous
        // so read should return OLD value
        // -----------------------------------------
        rs1_addr = 5'd5;
        rd_addr  = 5'd5;
        rd_data  = 32'hFFFFFFFF;
        rd_wr_en = 1'b1;
        #1;
        // x5 was never written so should still be 0 before clock edge
        if (rs1_data === 32'd0) begin
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL [RD_DURING_WR ] got=0x%08x expected=0x%08x",
                rs1_data, 32'd0);
            fail_count = fail_count + 1;
        end
        @(posedge clk);
        #1;
        rd_wr_en = 1'b0;
        // Now the write should have taken effect
        check_read(5'd5, 32'hFFFFFFFF, "WR_AFTER_CLK    ");

        // -----------------------------------------
        // Write to all registers and verify
        // -----------------------------------------
        begin : write_all
            integer j;
            for (j = 1; j < `REG_COUNT; j = j + 1) begin
                write_reg(j[`REG_ADDR_WIDTH-1:0], j[`REG_WIDTH-1:0] * 32'h11111111);
            end
            for (j = 1; j < `REG_COUNT; j = j + 1) begin
                rs1_addr = j[`REG_ADDR_WIDTH-1:0];
                #1;
                if (rs1_data === j[`REG_WIDTH-1:0] * 32'h11111111) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL [ALL_REGS     ] x%02d got=0x%08x expected=0x%08x",
                        j, rs1_data, j * 32'h11111111);
                    fail_count = fail_count + 1;
                end
            end
        end

        // -----------------------------------------
        // Summary
        // -----------------------------------------
        $display("=============================================");
        $display("PASSED: %0d  FAILED: %0d", pass_count, fail_count);
        $display("=============================================");

        $finish;
    end

endmodule
`endif
