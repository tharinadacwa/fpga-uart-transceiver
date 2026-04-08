module uart #(
    parameter integer CLOCKS_PER_PULSE = 434
)(
    input  wire [3:0] data_in,
    input  wire       data_en,
    input  wire       clk,
    input  wire       rstn,
    output wire       tx,
    output wire       tx_busy,
    input  wire       ready_clr,
    input  wire       rx,
    output wire       ready,
    output wire [7:0] led_out,
    output wire [6:0] rx_display_out,
    output wire [6:0] tx_display_out
);
    wire [7:0] tx_data;
    wire [7:0] rx_data;

    // Latch the last successfully transmitted nibble
    reg [3:0] tx_data_latched;

    assign tx_data = {4'b0000, data_in};
    assign led_out = rx_data;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            tx_data_latched <= 4'b0000;
        else if (data_en && !tx_busy)   // capture when transmitter accepts data
            tx_data_latched <= data_in;
    end

    transmitter #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)
    ) uart_tx (
        .data_in (tx_data),
        .data_en (data_en),
        .clk     (clk),
        .rstn    (rstn),
        .tx      (tx),
        .tx_busy (tx_busy)
    );

    receiver #(
        .CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)
    ) uart_rx (
        .clk      (clk),
        .rstn     (rstn),
        .ready_clr(ready_clr),
        .rx       (rx),
        .ready    (ready),
        .data_out (rx_data)
    );

    // TX display shows LAST SENT value (latched)
    binary_to_7seg tx_converter (
        .data_in (tx_data_latched),     // ← FIXED
        .data_out(tx_display_out)
    );

    binary_to_7seg rx_converter (
        .data_in (rx_data[3:0]),
        .data_out(rx_display_out)
    );

endmodule