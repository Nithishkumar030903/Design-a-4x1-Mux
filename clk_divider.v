module clk_divider (
    input clk,
    input rst_n,
    output reg tick_100hz,
    output reg tick_1khz
);

    reg [19:0] count_100hz;
    reg [16:0] count_1khz;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            count_100hz <= 20'd0;
            tick_100hz <= 1'b0;
        end else begin
            if (count_100hz >= 20'd999999) begin
                count_100hz <= 20'd0;
                tick_100hz <= 1'b1;
            end else begin
                count_100hz <= count_100hz + 20'd1;
                tick_100hz <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            count_1khz <= 17'd0;
            tick_1khz <= 1'b0;
        end else begin
            if (count_1khz >= 17'd99999) begin
                count_1khz <= 17'd0;
                tick_1khz <= 1'b1;
            end else begin
                count_1khz <= count_1khz + 17'd1;
                tick_1khz <= 1'b0;
            end
        end
    end

endmodule
