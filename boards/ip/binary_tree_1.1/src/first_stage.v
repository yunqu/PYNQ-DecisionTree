`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yun Rock Qu
// 
// Create Date: 02/14/2018 10:35:25 AM
// Design Name: 
// Module Name: first_stage
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


module first_stage #(parameter NUM_BITS_PER_FIELD_INDEX = 3,
                     parameter NUM_FIELDS = 1<<NUM_BITS_PER_FIELD_INDEX,
                     parameter NUM_BITS_PER_FIELD = 8,
                     parameter TOTAL_NUM_BITS = NUM_FIELDS * NUM_BITS_PER_FIELD)(
input [TOTAL_NUM_BITS-1:0] data_i,
input addr_i,
input reset,
input clk,
input load,
input addr_w,
input valid_in,
input last_in,
input [NUM_BITS_PER_FIELD_INDEX-1:0] program_field,
input [NUM_BITS_PER_FIELD-1:0] program_node,
output reg addr_o,
output reg valid_out,
output reg last_out
);

reg [NUM_BITS_PER_FIELD-1:0] node_mem[1:0];
reg [NUM_BITS_PER_FIELD_INDEX-1:0] field_mem[1:0];
reg [NUM_BITS_PER_FIELD-1:0] data_compare;

always@(*) begin
    data_compare <= data_i[NUM_BITS_PER_FIELD*(NUM_FIELDS-field_mem[addr_i])-1 -:NUM_BITS_PER_FIELD];
end

always@(posedge reset, posedge clk) begin
    if (reset) begin
        addr_o <= 0;
        // instantiating memory instead of register
        node_mem[addr_w] <= 0;
        field_mem[addr_w] <= 0;
    end
    else begin
        if (clk) begin
            if (load) begin
                node_mem[addr_w] <= program_node;
                field_mem[addr_w] <= program_field;
                addr_o <= 0;
            end
            else begin
                if (data_compare == node_mem[addr_i]) begin
                    addr_o <= 0;
                end
                else begin
                    addr_o <= 1;
                end
            end
        end
    end         
end

always@(posedge reset, posedge clk) begin
    if (reset) begin
        {valid_out, last_out} <= 0;
    end 
    else begin
        if (clk) begin
            if (load) begin
                {valid_out, last_out} <= 0;
            end else begin
                {valid_out, last_out} <= {valid_in, last_in};
            end
        end
    end
end

endmodule