
`timescale 1 ns / 1 ps

	module binary_tree_v1_1_S00_AXIS #
	(
		// Users to add parameters here
        parameter NUM_BITS_PER_FIELD_INDEX = 3,
        parameter NUM_FIELDS = 1<<NUM_BITS_PER_FIELD_INDEX,
        parameter NUM_BITS_PER_FIELD = 8,
        parameter TOTAL_NUM_BITS = NUM_FIELDS * NUM_BITS_PER_FIELD,
        parameter NUM_STAGES = 8,
		// User parameters ends
		// Do not modify the parameters beyond this line

		parameter ADDR_WIDTH = 8,
        parameter DATA_WIDTH = TOTAL_NUM_BITS,
        parameter LAST_ENABLE = 1
	)
	(
       input wire       clk,
       input wire       rst,        
       /*
        * AXI input
        */
       input  wire [DATA_WIDTH-1:0]  input_axis_tdata,
       input  wire                   input_axis_tvalid,
       output wire                   input_axis_tready,
       input  wire                   input_axis_tlast,
                
       /*
        * AXI output
        */
       output wire [DATA_WIDTH-1:0]  output_axis_tdata,
       output wire                   output_axis_tvalid,
       input  wire                   output_axis_tready,
       output wire                   output_axis_tlast
	);
	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

localparam LAST_OFFSET = DATA_WIDTH;
localparam WIDTH   = LAST_OFFSET + (LAST_ENABLE ? 1          : 0);

reg [ADDR_WIDTH:0] wr_ptr_reg = {ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [ADDR_WIDTH:0] wr_addr_reg = {ADDR_WIDTH+1{1'b0}};
reg [ADDR_WIDTH:0] rd_ptr_reg = {ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [ADDR_WIDTH:0] rd_addr_reg = {ADDR_WIDTH+1{1'b0}};

reg [WIDTH-1:0] mem[(2**ADDR_WIDTH)-1:0];
reg [WIDTH-1:0] mem_read_data_reg;
reg mem_read_data_valid_reg = 1'b0, mem_read_data_valid_next;

wire [WIDTH-1:0] input_axis;

reg [WIDTH-1:0] output_axis_reg;
reg output_axis_tvalid_reg = 1'b0, output_axis_tvalid_next;

// full when first MSB different but rest same
wire full = ((wr_ptr_reg[ADDR_WIDTH] != rd_ptr_reg[ADDR_WIDTH]) &&
             (wr_ptr_reg[ADDR_WIDTH-1:0] == rd_ptr_reg[ADDR_WIDTH-1:0]));
// empty when pointers match exactly
wire empty = wr_ptr_reg == rd_ptr_reg;

// control signals
reg write;
reg read;
reg store_output;

assign input_axis_tready = ~full;

generate
    assign input_axis[DATA_WIDTH-1:0] = input_axis_tdata;
    if (LAST_ENABLE) assign input_axis[LAST_OFFSET]               = input_axis_tlast;
endgenerate

assign output_axis_tvalid = output_axis_tvalid_reg;

assign output_axis_tdata = output_axis_reg[DATA_WIDTH-1:0];
assign output_axis_tlast = LAST_ENABLE ? output_axis_reg[LAST_OFFSET]               : 1'b1;

// Write logic
always @* begin
    write = 1'b0;

    wr_ptr_next = wr_ptr_reg;

    if (input_axis_tvalid) begin
        // input data valid
        if (~full) begin
            // not full, perform write
            write = 1'b1;
            wr_ptr_next = wr_ptr_reg + 1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        wr_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_reg <= wr_ptr_next;
    end

    wr_addr_reg <= wr_ptr_next;

    if (write) begin
        mem[wr_addr_reg[ADDR_WIDTH-1:0]] <= input_axis;
    end
end

// Read logic
always @* begin
    read = 1'b0;

    rd_ptr_next = rd_ptr_reg;

    mem_read_data_valid_next = mem_read_data_valid_reg;

    if (store_output | ~mem_read_data_valid_reg) begin
        // output data not valid OR currently being transferred
        if (~empty) begin
            // not empty, perform read
            read = 1'b1;
            mem_read_data_valid_next = 1'b1;
            rd_ptr_next = rd_ptr_reg + 1;
        end else begin
            // empty, invalidate
            mem_read_data_valid_next = 1'b0;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        rd_ptr_reg <= {ADDR_WIDTH+1{1'b0}};
        mem_read_data_valid_reg <= 1'b0;
    end else begin
        rd_ptr_reg <= rd_ptr_next;
        mem_read_data_valid_reg <= mem_read_data_valid_next;
    end

    rd_addr_reg <= rd_ptr_next;

    if (read) begin
        mem_read_data_reg <= mem[rd_addr_reg[ADDR_WIDTH-1:0]];
    end
end

// Output register
always @* begin
    store_output = 1'b0;

    output_axis_tvalid_next = output_axis_tvalid_reg;

    if (output_axis_tready | ~output_axis_tvalid) begin
        store_output = 1'b1;
        output_axis_tvalid_next = mem_read_data_valid_reg;
    end
end

always @(posedge clk) begin
    if (rst) begin
        output_axis_tvalid_reg <= 1'b0;
    end else begin
        output_axis_tvalid_reg <= output_axis_tvalid_next;
    end

    if (store_output) begin
        output_axis_reg <= mem_read_data_reg;
    end
end


endmodule
