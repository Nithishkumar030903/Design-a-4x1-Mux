`timescale 1ns/1ps

module dancing_led_system_tb ();

    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] led;
    wire [7:0] seg;
    wire [3:0] an;

    dancing_led_system dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led),
        .seg(seg),
        .an(an)
    );

    always #5 clk = ~clk;

    reg [15:0] last_led;
    reg [3:0] last_an;
    integer timeout_counter;

    initial begin
        clk = 0;
        rst = 1;
        sw = 16'h0000;
        last_led = 16'h0000;
        last_an = 4'hF;
        timeout_counter = 0;

        #100 rst = 0;
        #100;

        sw = 16'h0001;
        #2000000;

        sw = 16'h0002;
        #2000000;

        if (timeout_counter > 1000) begin
            $display("FAIL: System inactive");
            $stop;
        end else begin
            $display("PASS: System active");
            $finish;
        end
    end

    always @(posedge clk) begin
        if (led == last_led && an == last_an) begin
            timeout_counter <= timeout_counter + 1;
        end else begin
            timeout_counter <= 0;
        end
        last_led <= led;
        last_an <= an;

        if (timeout_counter > 2000000) begin
            $display("FAIL: Outputs static for too long");
            $stop;
        end
    end

endmodule
