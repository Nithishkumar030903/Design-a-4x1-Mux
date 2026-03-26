module mux_4x1_top (
    input wire clk,
    input wire rst,
    input wire [3:0] in_data,
    input wire [1:0] sel,
    output reg out_y
);

    wire rst_n;
    wire mux_out;

    assign rst_n = ~rst;

    mux_4x1 u_mux_4x1 (
        .in_data(in_data),
        .sel(sel),
        .y(mux_out)
    );

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            out_y <= 1'b0;
        end else begin
            out_y <= mux_out;
        end
    end

endmodule
