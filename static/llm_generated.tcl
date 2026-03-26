set project_name "mux_4x1_top"

foreach p {
    "./$project_name"
    "./$project_name.xpr"
    "./$project_name.runs"
    "./$project_name.sim"
    "./$project_name.cache"
    "./$project_name.hw"
} {
    if {[file exists $p]} {
        catch { file delete -force $p }
    }
}

file mkdir "./$project_name"

create_project -force $project_name "./$project_name" -part xc7a35tcpg236-1

set fh [open "./$project_name/mux_4x1_top.v" w]
puts $fh {module mux_4x1_top (
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

endmodule}
close $fh

set fh [open "./$project_name/mux_4x1.v" w]
puts $fh {module mux_4x1 (
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

endmodule}
close $fh

add_files -norecurse "./$project_name/mux_4x1_top.v"
add_files -norecurse "./$project_name/mux_4x1.v"

set fh [open "./$project_name/mux_4x1_top_tb.v" w]
puts $fh {`timescale 1ns/1ps

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

endmodule}
close $fh

add_files -fileset sim_1 "./$project_name/mux_4x1_top_tb.v"

set fh [open "./$project_name/constraints.xdc" w]
puts $fh {set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN V17 [get_ports {in_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in_data[0]}]
set_property PACKAGE_PIN V16 [get_ports {in_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in_data[1]}]
set_property PACKAGE_PIN W16 [get_ports {in_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in_data[2]}]
set_property PACKAGE_PIN W17 [get_ports {in_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {in_data[3]}]
set_property PACKAGE_PIN W15 [get_ports {sel[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sel[0]}]
set_property PACKAGE_PIN V15 [get_ports {sel[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sel[1]}]
set_property PACKAGE_PIN U16 [get_ports out_y]
set_property IOSTANDARD LVCMOS33 [get_ports out_y]}
close $fh

add_files -fileset constrs_1 "./$project_name/constraints.xdc"

set_property top mux_4x1_top [get_filesets sources_1]
set_property top mux_4x1_top_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# ============================================================
# Vivado Automation Script
# Phases: Synthesis → Implementation → Bitstream → Programming
# ============================================================

# --- Phase 2: Synthesis ---
puts "\n==== PHASE 2: Synthesis ===="
if {[get_projects -quiet] eq ""} {
    puts "ERROR: No project is open. Cannot launch synthesis. Exiting."
}

puts "INFO: Launching synthesis..."
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1

# Check synthesis completion status
set synth_status [get_property STATUS [get_runs synth_1]]
puts "INFO: Synthesis run 'synth_1' finished with status: $synth_status"
if {$synth_status ne "synth_design Complete!"} {
    puts "ERROR: Synthesis did not complete successfully. Check Vivado log for details."
}

# --- Phase 3: Implementation and Bitstream Generation ---
puts "\n==== PHASE 3: Implementation and Bitstream Generation ===="
if {[get_projects -quiet] eq ""} {
    puts "ERROR: No project is open. Cannot launch implementation. Exiting."
}

# Ensure synthesis completed before implementation
set synth_run_obj [get_runs synth_1]
if {$synth_run_obj eq ""} {
    puts "ERROR: Synthesis run 'synth_1' not found in project."
}

set synth_status [get_property STATUS $synth_run_obj]
if {$synth_status ne "synth_design Complete!"} {
    puts "ERROR: Synthesis must complete successfully before bitstream generation. Current status: $synth_status"
 
}

# Reset and run implementation up to bitstream
puts "INFO: Running implementation..."
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Check implementation completion status
set impl_status [get_property STATUS [get_runs impl_1]]
puts "INFO: Implementation run 'impl_1' finished with status: $impl_status"
if {$impl_status ne "write_bitstream Complete!"} {
    puts "ERROR: Implementation and bitstream generation did not complete successfully."}

# --- Phase 4: Bitstream Path Detection and Programming ---
puts "\n==== PHASE 4: Bitstream File Detection ===="

# Open the implemented design
open_run impl_1 -name implemented_design

# Try to get bitstream path automatically
set bitstream_file [get_property BITSTREAM.FILE [current_design]]

# If Vivado didn’t return it, search manually
if {$bitstream_file eq ""} {
    puts "WARNING: Vivado did not return BITSTREAM.FILE. Searching manually..."

    # Recursive file search procedure
    proc find_bit_files {dir} {
        set bit_files [glob -nocomplain -directory $dir *.bit]
        foreach subdir [glob -nocomplain -directory $dir -types d *] {
            set bit_files [concat $bit_files [find_bit_files $subdir]]
        }
        return $bit_files
    }

    set proj_dir [get_property DIRECTORY [current_project]]
    set bit_files [find_bit_files $proj_dir]

    if {[llength $bit_files] == 0} {
        puts "ERROR: No bitstream file found in project directory: $proj_dir"
    }

    # Pick latest by modification time
    set bitstream_file [lindex [lsort -decreasing -command {file mtime} $bit_files] 0]
}

puts "INFO: Bitstream generated successfully:"
puts "     → $bitstream_file"

# --- FPGA Programming ---
open_hw
connect_hw_server
current_hw_target [get_hw_targets *]
open_hw_target

set hw_device [lindex [get_hw_devices] 0]
refresh_hw_device $hw_device

set_property PROGRAM.FILE $bitstream_file $hw_device
program_hw_devices $hw_device

puts "INFO: FPGA programmed successfully!"

#--------_-Combined-_--------