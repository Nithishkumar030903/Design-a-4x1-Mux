module pattern_generator (
    input clk,
    input rst_n,
    input [15:0] sw,
    input tick,
    output reg [31:0] pattern_data
);

    reg [3:0] step;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            step <= 4'd0;
            pattern_data <= 32'hFFFFFFFF;
        end else if (tick) begin
            step <= step + 4'd1;
            if (sw[0]) begin
                case (step[1:0])
                    2'd0: pattern_data <= 32'hFEFEFEFE;
                    2'd1: pattern_data <= 32'hFDFDFDFD;
                    2'd2: pattern_data <= 32'hFBFBFBFB;
                    2'd3: pattern_data <= 32'hF7F7F7F7;
                endcase
            end else begin
                case (step[1:0])
                    2'd0: pattern_data <= 32'hEFEFEFEF;
                    2'd1: pattern_data <= 32'hDFDFDFDF;
                    2'd2: pattern_data <= 32'hBFBFBFBF;
                    2'd3: pattern_data <= 32'h7F7F7F7F;
                endcase
            end
        end
    end

endmodule
