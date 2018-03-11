# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_M00_AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_M00_AXIS_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {AXI4Stream source: Data Width} ${C_M00_AXIS_TDATA_WIDTH}
  set C_S00_AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXIS_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {AXI4Stream sink: Data Width} ${C_S00_AXIS_TDATA_WIDTH}
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXI data bus} ${C_S00_AXI_DATA_WIDTH}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of S_AXI address bus} ${C_S00_AXI_ADDR_WIDTH}

  ipgui::add_param $IPINST -name "NUM_BITS_PER_FIELD"
  ipgui::add_param $IPINST -name "NUM_STAGES"
  ipgui::add_param $IPINST -name "NUM_FIELDS"

}

proc update_PARAM_VALUE.NUM_BITS_PER_FIELD { PARAM_VALUE.NUM_BITS_PER_FIELD } {
	# Procedure called to update NUM_BITS_PER_FIELD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_BITS_PER_FIELD { PARAM_VALUE.NUM_BITS_PER_FIELD } {
	# Procedure called to validate NUM_BITS_PER_FIELD
	return true
}

proc update_PARAM_VALUE.NUM_FIELDS { PARAM_VALUE.NUM_FIELDS } {
	# Procedure called to update NUM_FIELDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_FIELDS { PARAM_VALUE.NUM_FIELDS } {
	# Procedure called to validate NUM_FIELDS
	return true
}

proc update_PARAM_VALUE.NUM_STAGES { PARAM_VALUE.NUM_STAGES } {
	# Procedure called to update NUM_STAGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_STAGES { PARAM_VALUE.NUM_STAGES } {
	# Procedure called to validate NUM_STAGES
	return true
}

proc update_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M00_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S00_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXIS_START_COUNT { MODELPARAM_VALUE.C_M00_AXIS_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "C_M00_AXIS_START_COUNT". Setting updated value from the model parameter.
set_property value 32 ${MODELPARAM_VALUE.C_M00_AXIS_START_COUNT}
}

proc update_MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_BITS_PER_FIELD_INDEX { MODELPARAM_VALUE.NUM_BITS_PER_FIELD_INDEX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "NUM_BITS_PER_FIELD_INDEX". Setting updated value from the model parameter.
set_property value 2 ${MODELPARAM_VALUE.NUM_BITS_PER_FIELD_INDEX}
}

proc update_MODELPARAM_VALUE.NUM_FIELDS { MODELPARAM_VALUE.NUM_FIELDS PARAM_VALUE.NUM_FIELDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_FIELDS}] ${MODELPARAM_VALUE.NUM_FIELDS}
}

proc update_MODELPARAM_VALUE.NUM_BITS_PER_FIELD { MODELPARAM_VALUE.NUM_BITS_PER_FIELD PARAM_VALUE.NUM_BITS_PER_FIELD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_BITS_PER_FIELD}] ${MODELPARAM_VALUE.NUM_BITS_PER_FIELD}
}

proc update_MODELPARAM_VALUE.TOTAL_NUM_BITS { MODELPARAM_VALUE.TOTAL_NUM_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "TOTAL_NUM_BITS". Setting updated value from the model parameter.
set_property value 16 ${MODELPARAM_VALUE.TOTAL_NUM_BITS}
}

proc update_MODELPARAM_VALUE.NUM_STAGES { MODELPARAM_VALUE.NUM_STAGES PARAM_VALUE.NUM_STAGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_STAGES}] ${MODELPARAM_VALUE.NUM_STAGES}
}

