`timescale 1ns/1ps

module sqrt_mult_system_tb;

    reg clk = 0;
    reg rst_i = 1;
    reg start_i = 0;
    reg [7:0] a_bi = 0;
    reg [7:0] b_bi = 0;
    wire [15:0] result;
    wire done;

    sqrt_mult_system DUT (
        .clk_i(clk),
        .rst_i(rst_i),
        .start_i(start_i),
        .a_bi(a_bi),
        .b_bi(b_bi),
        .result(result),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sqrt_mult_system_tb);

        rst_i = 1;
        repeat (2) @(posedge clk);
        rst_i = 0;
        @(posedge clk);

        test(8'd4,   8'd16,  16'd16,  1);   // 4 * sqrt(16) = 16
        test(8'd5,   8'd25,  16'd25,  2);   // 5 * sqrt(25) = 25
        test(8'd3,   8'd2,   16'd3,   3);   // 3 * sqrt(2) = 3
        test(8'd0,   8'd100, 16'd0,   4);   // 0 * sqrt(100) = 0
        test(8'd8,   8'd0,   16'd0,   5);   // 8 * sqrt(0) = 0
        test(8'd1,   8'd1,   16'd1,   6);   // 1 * sqrt(1) = 1
        test(8'd255, 8'd255, 16'd3825,7);   // 255 * sqrt(255) ≈ 3825
        test(8'd100, 8'd4,   16'd200, 8);   // 100 * sqrt(4) = 200
        test(8'd2,   8'd225, 16'd30,  9);   // 2 * sqrt(225) = 30
        test(8'd6,   8'd64,  16'd48,  10);  // 6 * sqrt(64) = 48

        #10 $finish;
    end

    localparam integer MAX_WAIT_CYCLES = 2000;

    task test;
        input [7:0] a, b;
        input [15:0] expected;
        input integer num;
        integer cycles;
        begin
            a_bi = a;
            b_bi = b;
            @(posedge clk) start_i = 1;
            @(posedge clk) start_i = 0;

            cycles = 0;
            while (!done && cycles < MAX_WAIT_CYCLES) begin
                @(posedge clk);
                cycles = cycles + 1;
            end

            if (done)
                $display("%2d: %0d*sqrt(%0d)=%0d (exp %0d)", num, a, b, result, expected);
            else
                $display("TIMEOUT in test %0d", num);

            repeat (2) @(posedge clk);
        end
    endtask

endmodule
