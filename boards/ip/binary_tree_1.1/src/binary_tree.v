`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yun Rock Qu
// 
// Create Date: 02/14/2018 01:39:43 PM
// Design Name: 
// Module Name: binary_tree
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module binary_tree #(parameter NUM_BITS_PER_FIELD_INDEX = 3,
                     parameter NUM_FIELDS = 1<<NUM_BITS_PER_FIELD_INDEX,
                     parameter NUM_BITS_PER_FIELD = 8,
                     parameter TOTAL_NUM_BITS = NUM_FIELDS * NUM_BITS_PER_FIELD,
                     parameter NUM_STAGES = 8)(
                     input [TOTAL_NUM_BITS-1:0] data,
                     input addr_i,
                     input reset,
                     input clk,
                     input load,
                     input valid_in,
                     input last_in,
                     input [(NUM_STAGES-1)*NUM_STAGES/2:0] addr_w,
                     input [NUM_STAGES*NUM_BITS_PER_FIELD_INDEX-1:0] program_field,
                     input [NUM_STAGES*NUM_BITS_PER_FIELD-1:0] program_node,
                     output [NUM_STAGES-1:0] addr_o,
                     output valid_out,
                     output last_out
    );

reg [TOTAL_NUM_BITS*NUM_STAGES-1:0] data_reg;
wire [NUM_STAGES*(NUM_STAGES+1)/2:0] addr_wire;
wire [NUM_STAGES-1:0] valid_wire;
wire [NUM_STAGES-1:0] last_wire;

// Note: LSB of addr_wire should always be set to 0
//       MSB of addr_w should always be set to 0 as well

assign addr_wire[0] = addr_i;
assign addr_o = addr_wire[NUM_STAGES*(NUM_STAGES+1)/2 -: NUM_STAGES];
assign valid_out = valid_wire[NUM_STAGES-1];
assign last_out = last_wire[NUM_STAGES-1];

// arrange all the stages
first_stage #(.NUM_BITS_PER_FIELD_INDEX(NUM_BITS_PER_FIELD_INDEX),
              .NUM_FIELDS(NUM_FIELDS),
              .NUM_BITS_PER_FIELD(NUM_BITS_PER_FIELD),
              .TOTAL_NUM_BITS(TOTAL_NUM_BITS))
           u_0(.data_i(data_reg[TOTAL_NUM_BITS-1 -: TOTAL_NUM_BITS]),
               .addr_i(addr_wire[0]),
               .reset(reset),
               .clk(clk),
               .load(load),
               .valid_in(valid_in),
               .last_in(last_in),
               .addr_w(addr_w[NUM_STAGES*(NUM_STAGES-1)/2]),
               .program_field(program_field[NUM_STAGES*NUM_BITS_PER_FIELD_INDEX-1 -: NUM_BITS_PER_FIELD_INDEX]),
               .program_node(program_node[NUM_STAGES*NUM_BITS_PER_FIELD-1 -: NUM_BITS_PER_FIELD]),
               .addr_o(addr_wire[1]),
               .valid_out(valid_wire[0]),
               .last_out(last_wire[0])
               );

genvar i;
generate
    for (i=1; i<NUM_STAGES; i = i+1) begin: node_i
            middle_stage #(.NUM_BITS_PER_FIELD_INDEX(NUM_BITS_PER_FIELD_INDEX),
                           .NUM_FIELDS(NUM_FIELDS),
                           .NUM_BITS_PER_FIELD(NUM_BITS_PER_FIELD),
                           .TOTAL_NUM_BITS(TOTAL_NUM_BITS),
                           .STAGE_INDEX(i))
                       u_i(.data_i(data_reg[TOTAL_NUM_BITS*(i+1)-1 -: TOTAL_NUM_BITS]),
                           .addr_i(addr_wire[(i+1)*i/2 -: i]),
                           .reset(reset),
                           .clk(clk),
                           .load(load),
                           .valid_in(valid_wire[i-1]),
                           .last_in(last_wire[i-1]),
                           .addr_w(addr_w[(NUM_STAGES-1)*NUM_STAGES/2-i*(i-1)/2 -1 -: i]),
                           .program_field(program_field[(NUM_STAGES-i)*NUM_BITS_PER_FIELD_INDEX-1 -: NUM_BITS_PER_FIELD_INDEX]),
                           .program_node(program_node[(NUM_STAGES-i)*NUM_BITS_PER_FIELD-1 -: NUM_BITS_PER_FIELD]),
                           .addr_o(addr_wire[(i+2)*(i+1)/2 -: (i+1)]),
                           .valid_out(valid_wire[i]),
                           .last_out(last_wire[i])
                           );
    end
endgenerate

// pipeline the data input
always@(*) begin
    data_reg[TOTAL_NUM_BITS-1 -: TOTAL_NUM_BITS] = data;
end
generate
    for (i=1; i<NUM_STAGES; i = i+1) begin: data_register
        always@(posedge clk) begin
            data_reg[(i+1)*TOTAL_NUM_BITS-1 -: TOTAL_NUM_BITS] <= data_reg[i*TOTAL_NUM_BITS-1 -: TOTAL_NUM_BITS];
        end
    end
endgenerate

endmodule
