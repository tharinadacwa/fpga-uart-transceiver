module binary_to_7seg (
    input  wire [3:0] data_in,
    output wire [6:0] data_out
);
    reg [6:0] seg_raw;

    always @(*) begin
        case (data_in)
            4'h0: seg_raw = 7'b0111111;
            4'h1: seg_raw = 7'b0000110;
            4'h2: seg_raw = 7'b1011011;
            4'h3: seg_raw = 7'b1001111;
            4'h4: seg_raw = 7'b1100110;
            4'h5: seg_raw = 7'b1101101;
            4'h6: seg_raw = 7'b1111101;
            4'h7: seg_raw = 7'b0000111;
            4'h8: seg_raw = 7'b1111111;
            4'h9: seg_raw = 7'b1101111;
            4'hA: seg_raw = 7'b1110111;
            4'hB: seg_raw = 7'b1111100;
            4'hC: seg_raw = 7'b0111001;
            4'hD: seg_raw = 7'b1011110;
            4'hE: seg_raw = 7'b1111001;
            4'hF: seg_raw = 7'b1110001;
            default: seg_raw = 7'b0000000;
        endcase
    end

    // active-low outputs for common-anode display
    assign data_out = ~seg_raw;
endmodule