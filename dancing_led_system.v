module dancing_led_system (
    input clk,
    input rst,
    input [15:0] sw,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] an
);

    wire rst_n;
    assign rst_n = ~rst;

    wire tick_100hz;
    wire tick_1khz;
    wire [31:0] pattern_data;

    clk_divider divider_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tick_100hz(tick_100hz),
        .tick_1khz(tick_1khz)
    );

    pattern_generator pattern_inst (
        .clk(clk),
        .rst_n(rst_n),
        .sw(sw),
        .tick(tick_100hz),
        .pattern_data(pattern_data)
    );

    led_sequencer led_inst (
        .clk(clk),
        .rst_n(rst_n),
        .sw(sw),
        .tick(tick_100hz),
        .led_out(led)
    );

    seven_seg_controller display_inst (
        .clk(clk),
        .rst_n(rst_n),
        .refresh_tick(tick_1khz),
        .data_in(pattern_data),
        .seg(seg),
        .an(an)
    );

endmodule
