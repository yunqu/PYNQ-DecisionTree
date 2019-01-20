set overlay_name "decision_tree_3_stages"
set design_name "decision_tree_3_stages"

# open project and block design
open_project -quiet ./${overlay_name}/${overlay_name}.xpr
open_bd_design ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd

# set sdx platform properties
set_property PFM_NAME "xilinx.com:xd:${overlay_name}:1.0" \
        [get_files ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd]
set_property PFM.CLOCK { \
    FCLK_CLK0 {id "0" is_default "true" proc_sys_reset "proc_sys_reset_0" } \
    } [get_bd_cells /processing_system7_0]
set_property PFM.AXI_PORT { \
    S_AXI_ACP {memport "S_AXI_ACP"} \
    S_AXI_HP1 {memport "S_AXI_HP"} \
    S_AXI_HP2 {memport "S_AXI_HP"} \
    S_AXI_HP3 {memport "S_AXI_HP"} \
    } [get_bd_cells /processing_system7_0]
set intVar []
for {set i 0} {$i < 16} {incr i} {
    lappend intVar In$i {}
}
set_property PFM.IRQ $intVar [get_bd_cells /xlconcat_0]

# generate dsa
write_dsa -force ./${overlay_name}.dsa
validate_dsa ./${overlay_name}.dsa