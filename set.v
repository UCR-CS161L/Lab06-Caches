`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2021 12:32:58 PM
// Design Name: 
// Module Name: set
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


module set #(
    parameter INDEX_BITS = 5,
    parameter TAG_BITS   = 23,
    parameter DATA_BITS  = 32
) (
    input wire                   clk,
    input wire                   rst,
    input wire                   enable,
    input wire  [INDEX_BITS-1:0] index_in,
    input wire  [TAG_BITS-1:0]   tag_in,
    input wire  [DATA_BITS-1:0]  data_in,

    output wire                  valid_out,
    output wire [TAG_BITS-1:0]   tag_out,
    output wire [DATA_BITS-1:0]  data_out
);

    reg                 valid [(1 << INDEX_BITS)-1:0];
    reg [TAG_BITS-1:0]  tag   [(1 << INDEX_BITS)-1:0];
    reg [DATA_BITS-1:0] data  [(1 << INDEX_BITS)-1:0];

    integer block;

    always @(posedge clk) begin
        if (rst) begin
            for (block = 0; block < (1 << INDEX_BITS); block = block+1) begin
                valid[block] <= 1'b0;
                tag[block]   <= { TAG_BITS  {1'b0} };
                data[block]  <= { DATA_BITS {1'b0} };
            end 
        end
    end
    
    always @(posedge enable) begin
        valid[index_in] <= 1'b1;
        tag[index_in]   <= tag_in;
        data[index_in]  <= data_in;
    end
    
    assign valid_out = valid[index_in];
    assign tag_out   = tag[index_in];
    assign data_out  = data[index_in];

endmodule
