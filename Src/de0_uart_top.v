module de0_uart_top #(
    parameter integer CLOCKS_PER_PULSE = 434  // 50 MHz / 115200 baud (overridable)
)(
    input  wire        CLOCK_50,
    input  wire [1:0]  KEY,
    input  wire [3:0]  SW,
    output wire [7:0]  LED,
    // JP1 GPIO signals used
    output wire GPIO_00,
    output wire GPIO_01,
    output wire GPIO_02,
    output wire GPIO_03,
    output wire GPIO_04,
    output wire GPIO_05,
    output wire GPIO_06,
    output wire GPIO_07,   // TX
    input  wire GPIO_08,   // RX
    output wire GPIO_09,
    output wire GPIO_010,
    output wire GPIO_011,
    output wire GPIO_012,
    output wire GPIO_013,
    output wire GPIO_014,
    output wire GPIO_015
);

    // Internal signals
    wire       tx;
    wire       tx_busy;
    wire       ready;
    wire [7:0] led_out;
    wire [6:0] tx_display_out;
    wire [6:0] rx_display_out;

    // UART instance
    uart #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)
    ) u_uart (
        .data_in        (SW),
        .data_en        (~KEY[1]),
        .clk            (CLOCK_50),
        .rstn           (KEY[0]),
        .tx             (tx),
        .tx_busy        (tx_busy),
        .ready_clr      (1'b0),
        .rx             (GPIO_08),
        .ready          (ready),
        .led_out        (led_out),
        .rx_display_out (rx_display_out),
        .tx_display_out (tx_display_out)
    );

    // Output assignments
    assign LED = led_out;

    // JP1 GPIO mapping - 7-segment displays
    assign GPIO_00  = ~tx_display_out[0];//a
    assign GPIO_01  = ~tx_display_out[1];//b
    assign GPIO_02  = ~tx_display_out[2];//c
    assign GPIO_03  = ~tx_display_out[3];//d
    assign GPIO_04  = ~tx_display_out[4];//e
    assign GPIO_05  = ~tx_display_out[5];//f
    assign GPIO_06  = ~tx_display_out[6];
    
    // TX output
    assign GPIO_07  = tx;
    
    // RX 7-segment display
    assign GPIO_09  = rx_display_out[0];
    assign GPIO_010 = rx_display_out[1];
    assign GPIO_011 = rx_display_out[2];
    assign GPIO_012 = rx_display_out[3];
    assign GPIO_013 = rx_display_out[4];
    assign GPIO_014 = rx_display_out[5];
    assign GPIO_015 = rx_display_out[6];

endmodule