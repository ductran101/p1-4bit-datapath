# Supporting implementation choice; the PDFs do not prescribe this script.
# vivado -mode batch -source /path/to/scripts/vivado_run.tcl -tclargs sim|synth <part>

if {$argc != 2 || [lindex $argv 0] ni {sim synth}} {
    error "Usage: vivado -mode batch -source scripts/vivado_run.tcl -tclargs sim|synth <part>"
}
set mode [lindex $argv 0]
set part_name [lindex $argv 1]
if {[llength [get_parts -quiet $part_name]] != 1} {
    error "Choose one installed Vivado part: $part_name"
}

set repo_dir [file dirname [file dirname [file normalize [info script]]]]
set build_dir [file join $repo_dir build]
set project_dir [file join $build_dir vivado]
set rtl_files {}
foreach name {
    full_adder adder_subtractor_4bit logic_unit_4bit shifter_4bit
    control_unit muldiv_unit result_mux flag_unit alu_4bit
} {
    set source_file [file join $repo_dir rtl ${name}.v]
    if {![file isfile $source_file]} { error "Missing design source: $source_file" }
    lappend rtl_files $source_file
}
set tb_file [file join $repo_dir tb alu_4bit_tb.v]
if {![file isfile $tb_file]} { error "Missing simulation source: $tb_file" }

file mkdir $project_dir
# -force is confined to this project's generated build/vivado directory.
create_project -force p1_4bit $project_dir -part $part_name
set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]
add_files -norecurse $rtl_files
add_files -fileset sim_1 -norecurse [list $tb_file]
# The .v testbench uses $fatal for a failing process status.
set_property file_type SystemVerilog [get_files $tb_file]
set_property top alu_4bit [get_filesets sources_1]
set_property top alu_4bit_tb [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

if {$mode eq "sim"} {
    # Open at time zero, then explicitly run the complete self-checking testbench.
    set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
    launch_simulation -mode behavioral
    run all
    close_sim
    puts "XSim logs: [file join $project_dir p1_4bit.sim sim_1 behav xsim]"
} else {
    launch_runs synth_1
    wait_on_run synth_1
    if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
        error "Synthesis did not complete: [get_property STATUS [get_runs synth_1]]"
    }
    open_run synth_1
    report_utilization -file [file join $project_dir utilization.rpt]
    puts "Utilization report: [file join $project_dir utilization.rpt]"
}
close_project
