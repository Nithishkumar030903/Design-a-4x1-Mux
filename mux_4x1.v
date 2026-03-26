module mux_4x1 (
    input wire [3:0] in_data,
    input wire [1:0] sel,
    output reg y
);

    always @(*) begin
        case (sel)
            2'b00:   y = in_data[0];
            2'b01:   y = in_data[1];
            2'b10:   y = in_data[2];
            2'b11:   y = in_data[3];
            default: y = 1'b0;
        endcase
    end

endmodule
