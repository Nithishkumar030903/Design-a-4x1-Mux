module led_sequencer (
    input clk,
    input rst_n,
    input [15:0] sw,
    input tick,
    output reg [15:0] led_out
);

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            led_out <= 16'h0001;
        end else if (tick) begin
            if (sw[1]) begin
                led_out <= {led_out[0], led_out[15:1]};
            end else begin
                led_out <= {led_out[14:0], led_out[15]};
            end
        end
    end

endmodule
