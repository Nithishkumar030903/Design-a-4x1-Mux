`timescale 1ns/1ps

module mux_4x1_top_tb;

    reg clk;
    reg rst;
    reg [3:0] in_data;
    reg [1:0] sel;
    wire out_y;

    integer i;
    integer activity_count;
    reg [1:0] last_out;

    mux_4x1_top dut (
        .clk(clk),
        .rst(rst),
        .in_data(in_data),
        .sel(sel),
        .out_y(out_y)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        in_data = 4'b0000;
        sel = 2'b00;
        activity_count = 0;
        
        #20 rst = 0;
        #20;

        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            in_data = i[3:0];
            sel = i[1:0];
            
            repeat(2) @(posedge clk);
            
            if (out_y === in_data[sel]) begin
                activity_count = activity_count + 1;
            end else begin
                $display("FAILURE: Mismatch at in_data=%b, sel=%b. Expected %b, got %b", in_data, sel, in_data[sel], out_y);
                $finish;
            end
        end

        if (activity_count == 0) begin
            $display("FAILURE: No output activity detected.");
            $finish;
        end else begin
            $display("SUCCESS: Simulation passed with %0d valid transitions.", activity_count);
            $finish;
        end
    end

endmodule
