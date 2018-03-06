
`timescale 1 ns / 1 ps

	module binary_tree_v1_1 #
	(
		// Users to add parameters here
        parameter NUM_FIELDS = 4,
        parameter NUM_BITS_PER_FIELD = 8,
        parameter NUM_STAGES = 8,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT    = 32,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);
	// function called logb2 that returns an integer which has the 
    // value of the log base 2 (input has to be power of 2).
    function integer logb2 (input integer bit_depth);
      begin
        for(logb2=0; bit_depth>1; logb2=logb2+1)
          bit_depth = bit_depth >> 1;
      end
    endfunction
    
    localparam NUM_BITS_PER_FIELD_INDEX = logb2(NUM_FIELDS);
    localparam TOTAL_NUM_BITS = NUM_FIELDS * NUM_BITS_PER_FIELD;
	// Axi Stream data
	wire [TOTAL_NUM_BITS-1:0] data;
	wire [NUM_STAGES-1:0] addr;
	wire valid_axis2pipe;
	wire valid_pipe2axis;
	wire last_axis2pipe;
    wire last_pipe2axis;
    wire ready_loopback;
	
	// Axi Lite data
    wire addr_i;
    wire reset;
    wire load;
    wire [(NUM_STAGES-1)*NUM_STAGES/2:0] addr_w;
    wire [NUM_STAGES*NUM_BITS_PER_FIELD_INDEX-1:0] program_field;
    wire [NUM_STAGES*NUM_BITS_PER_FIELD-1:0] program_node;
    
// Instantiation of Axi Bus Interface S00_AXI
	binary_tree_v1_1_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
		.NUM_BITS_PER_FIELD_INDEX(NUM_BITS_PER_FIELD_INDEX),
        .NUM_FIELDS(NUM_FIELDS),
        .NUM_BITS_PER_FIELD(NUM_BITS_PER_FIELD),
        .TOTAL_NUM_BITS(TOTAL_NUM_BITS),
        .NUM_STAGES(NUM_STAGES)
	) binary_tree_v1_1_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		.reset(reset),
        .load(load),
        .addr_i(addr_i),
        .program_field(program_field),
        .program_node(program_node),
        .addr_w(addr_w)
	);

// Instantiation of Axi Bus Interface S00_AXIS
	binary_tree_v1_1_S00_AXIS # ( 
		.NUM_BITS_PER_FIELD_INDEX(NUM_BITS_PER_FIELD_INDEX),
        .NUM_FIELDS(NUM_FIELDS),
        .NUM_BITS_PER_FIELD(NUM_BITS_PER_FIELD),
        .TOTAL_NUM_BITS(TOTAL_NUM_BITS),
        .NUM_STAGES(NUM_STAGES)
	) binary_tree_v1_1_S00_AXIS_inst (
		.clk(m00_axis_aclk),
            .rst(~m00_axis_aresetn),
            .input_axis_tdata(s00_axis_tdata[TOTAL_NUM_BITS-1:0]),
            .input_axis_tvalid(s00_axis_tvalid),
            .input_axis_tready(s00_axis_tready),
            .input_axis_tlast(s00_axis_tlast),
            .output_axis_tdata(data),
            .output_axis_tvalid(valid_axis2pipe),
            .output_axis_tready(ready_loopback),
            .output_axis_tlast(last_axis2pipe)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	binary_tree_v1_1_M00_AXIS # ( 
		.NUM_BITS_PER_FIELD_INDEX(NUM_BITS_PER_FIELD_INDEX),
        .NUM_FIELDS(NUM_FIELDS),
        .NUM_BITS_PER_FIELD(NUM_BITS_PER_FIELD),
        .TOTAL_NUM_BITS(TOTAL_NUM_BITS),
        .NUM_STAGES(NUM_STAGES)
	) binary_tree_v1_1_M00_AXIS_inst (
		.clk(m00_axis_aclk),
		.rst(~m00_axis_aresetn),
		.input_axis_tdata(addr),
		.input_axis_tvalid(valid_pipe2axis),
        .input_axis_tready(ready_loopback),
        .input_axis_tlast(last_pipe2axis),
        .output_axis_tdata(m00_axis_tdata[NUM_STAGES-1:0]),
        .output_axis_tvalid(m00_axis_tvalid),
        .output_axis_tready(m00_axis_tready),
        .output_axis_tlast(m00_axis_tlast)
	);
    assign m00_axis_tdata[C_M00_AXIS_TDATA_WIDTH-1:NUM_STAGES] = 0;
	// Add user logic here
    binary_tree #(
                    .NUM_BITS_PER_FIELD_INDEX(NUM_BITS_PER_FIELD_INDEX),
                    .NUM_FIELDS(NUM_FIELDS),
                    .NUM_BITS_PER_FIELD(NUM_BITS_PER_FIELD),
                    .TOTAL_NUM_BITS(TOTAL_NUM_BITS),
                    .NUM_STAGES(NUM_STAGES)
            ) binary_tree_inst (
                    .data(data),
                    .addr_i(addr_i),
                    .reset(reset),
                    .clk(m00_axis_aclk),
                    .load(load),
                    .valid_in(valid_axis2pipe),
                    .last_in(last_axis2pipe),
                    .addr_w(addr_w),
                    .program_node(program_node),
                    .program_field(program_field),
                    .addr_o(addr),
                    .valid_out(valid_pipe2axis),
                    .last_out(last_pipe2axis)
                    );
	// User logic ends

	endmodule
