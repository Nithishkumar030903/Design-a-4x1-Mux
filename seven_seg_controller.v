module seven_seg_controller (
    input clk,
    input rst_n,
    input refresh_tick,
    input [31:0] data_in,
    output reg [7:0] seg,
    output reg [3:0] an
);

    reg [1:0] digit_select;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            digit_select <= 2'd0;
            an <= 4'b1111;
            seg <= 8'hFF;
        end else if (refresh_tick) begin
            digit_select <= digit_select + 2'd1;
            case (digit_select)
                2'd0: begin
                    an <= 4'b1110;
                    seg <= data_in[7:0];
                end
                2'd1: begin
                    an <= 4'b1101;
                    seg <= data_in[15:8];
                end
                2'd2: begin
                    an <= 4'b1011;
                    seg <= data_in[23:16];
                end
                2'd3: begin
                    an <= 4'b0111;
                    seg <= data_in[31:24];
                end
            endcase
        end
    end

endmodule
