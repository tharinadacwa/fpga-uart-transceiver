      parameter integer CLOCKS_PER_PULSE = 16
)(
    input  wire [7:0] data_in,
    input  wire       data_en,//Enable signal — pulse high to trigger a transmission
    input  wire       clk,//System clock
    input  wire       rstn,//Active-low synchronous reset
    output reg        tx,//Serial TX line sent to receiver
    output wire       tx_busy //High while a transmission is in progress
);
    // State encoding (replaces typedef enum)
    localparam [1:0] TX_IDLE  = 2'd0,
                     TX_START = 2'd1,
                     TX_DATA  = 2'd2,
                     TX_STOP  = 2'd3;// 4 states declaration 

    reg [1:0] state;// state register 
    reg [7:0] data_reg;
    reg [2:0] bit_count;// transmited bit count tracker 
    reg [$clog2(CLOCKS_PER_PULSE)-1:0] clk_count;// counts clock pulses
    reg data_en_d;//It is used together with data_en to detect the rising edge

    wire start_pulse;
    assign start_pulse = data_en & ~data_en_d;// detecting rising edge 
    assign tx_busy     = (state != TX_IDLE);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin//reset all
            data_en_d <= 1'b0;
            state     <= TX_IDLE;
            data_reg  <= 8'd0;
            bit_count <= 3'd0;
            clk_count <= {$clog2(CLOCKS_PER_PULSE){1'b0}};
            tx        <= 1'b1;
        end else begin
            data_en_d <= data_en;
            case (state)
                TX_IDLE: begin// 1st state idle state 
                    tx        <= 1'b1;// OUTPUT decoded here
                    clk_count <= {$clog2(CLOCKS_PER_PULSE){1'b0}};
                    bit_count <= 3'd0;
                    if (start_pulse) begin
                        data_reg <= data_in;
                        state    <= TX_START;// NEXT STATE decoded here
                    end
                end
                TX_START: begin
                    tx <= 1'b0;// take line low// This LOW pulse is the UART start bit it tells the receiver "data is coming, start sampling."
                    if (clk_count == CLOCKS_PER_PULSE-1) begin// counts 16 pulses of real clk and its one clk in our system 
                        clk_count <= {$clog2(CLOCKS_PER_PULSE){1'b0}};//{4{1'b0}}  = repeat 1'b0 four times
                        state     <= TX_DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end
                TX_DATA: begin// send bit by bit 
                    tx <= data_reg[bit_count];
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        clk_count <= {$clog2(CLOCKS_PER_PULSE){1'b0}};
                        if (bit_count == 3'd7) begin
                            bit_count <= 3'd0;
                            state     <= TX_STOP;
                        end else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end
                TX_STOP: begin
                    tx <= 1'b1;// pull line HIGH
                    if (clk_count == CLOCKS_PER_PULSE-1) begin
                        clk_count <= {$clog2(CLOCKS_PER_PULSE){1'b0}};
                        state     <= TX_IDLE; // return to idle
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end
                default: begin
                    state <= TX_IDLE;
                    tx    <= 1'b1;
                end
            endcase
        end
    end
endmodule