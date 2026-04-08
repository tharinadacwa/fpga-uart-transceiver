`timescale 1ns/1ps

module tb_de0_uart_top;

    // -------------------------
    // Signals
    // -------------------------
    reg        CLOCK_50;
    reg  [1:0] KEY;
    reg  [3:0] SW;
    wire [7:0] LED;
    wire [15:0] GPIO;

    // TX looped back to RX
    assign GPIO[8] = GPIO[7];

    // -------------------------
    // Parameters
    // -------------------------
    localparam integer CPP = 50;    // clocks per pulse
    localparam real    CLK = 20.0;  // 20ns = 50MHz

    // -------------------------
    // DUT
    // -------------------------
    de0_uart_top #(.CLOCKS_PER_PULSE(CPP)) dut (
        .CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW), .LED(LED),
        .GPIO_00(GPIO[0]),  .GPIO_01(GPIO[1]),  .GPIO_02(GPIO[2]),
        .GPIO_03(GPIO[3]),  .GPIO_04(GPIO[4]),  .GPIO_05(GPIO[5]),
        .GPIO_06(GPIO[6]),  .GPIO_07(GPIO[7]),  .GPIO_08(GPIO[8]),
        .GPIO_09(GPIO[9]),  .GPIO_010(GPIO[10]),.GPIO_011(GPIO[11]),
        .GPIO_012(GPIO[12]),.GPIO_013(GPIO[13]),.GPIO_014(GPIO[14]),
        .GPIO_015(GPIO[15])
    );

    // -------------------------
    // Clock
    // -------------------------
    initial CLOCK_50 = 0;
    always #(CLK/2) CLOCK_50 = ~CLOCK_50;

    // -------------------------
    // Main Test
    // -------------------------
    initial begin
        // Initial state
        KEY = 2'b11;
        SW  = 4'h0;

        // Reset
        KEY[0] = 0;
        repeat(10) @(posedge CLOCK_50);
        KEY[0] = 1;
        repeat(10) @(posedge CLOCK_50);
        $display("Reset done");

        // TEST 1 - transmit 0xA
        SW = 4'hA;
        @(posedge CLOCK_50);
        KEY[1] = 0;            // press button
        @(posedge CLOCK_50);
        KEY[1] = 1;            // release button
        repeat(CPP * 15) @(posedge CLOCK_50);
        $display("TEST1: SW=0xA  LED=0x%h  %s", LED, (LED==8'h0A) ? "PASS":"FAIL");
        repeat(50) @(posedge CLOCK_50);

        // TEST 2 - transmit 0x5
        SW = 4'h5;
        @(posedge CLOCK_50);
        KEY[1] = 0;
        @(posedge CLOCK_50);
        KEY[1] = 1;
        repeat(CPP * 15) @(posedge CLOCK_50);
        $display("TEST2: SW=0x5  LED=0x%h  %s", LED, (LED==8'h05) ? "PASS":"FAIL");
        repeat(50) @(posedge CLOCK_50);

        // TEST 3 - transmit 0xF
        SW = 4'hF;
        @(posedge CLOCK_50);
        KEY[1] = 0;
        @(posedge CLOCK_50);
        KEY[1] = 1;
        repeat(CPP * 15) @(posedge CLOCK_50);
        $display("TEST3: SW=0xF  LED=0x%h  %s", LED, (LED==8'h0F) ? "PASS":"FAIL");
        repeat(50) @(posedge CLOCK_50);

        $display("All tests done");
        $finish;
    end

endmodule