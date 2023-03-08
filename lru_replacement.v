`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2022 01:13:04 PM
// Design Name: 
// Module Name: lru_replacement
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


module lru_replacement #(
    parameter WAY_SIZE      = 3,
    parameter SET_SIZE      = 2,
    parameter ASSOCIATIVITY = 1
    ) (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [SET_SIZE-1:0] set_in,
    input wire [WAY_SIZE-1:0] way_in,
    output wire [WAY_SIZE-1:0] next_out
);

    integer counts [(1 << SET_SIZE)-1:0][ASSOCIATIVITY-1:0];
    integer tick;
    integer i;
    integer j;
    reg [SET_SIZE-1:0] min_idx;
    reg [SET_SIZE-1:0] new_idx;
    
    always @(posedge clk) begin
        if (rst) begin
            tick = 0;
            new_idx = 0;
            for (i = 0; i < (1 << SET_SIZE); i = i + 1) begin
                for (j = 0; j < ASSOCIATIVITY; j = j + 1) begin
                    counts[i][j] = 0;
                end
            end
        end else begin
            tick = tick + 1;
            if (way_in < ASSOCIATIVITY) begin
                counts[set_in][way_in] = tick;
            end
        end
    end
    
    always @(set_in or way_in or enable) begin
        if (enable) begin
            new_idx = way_in;
            min_idx = 0;
            for (i = 0; i < ASSOCIATIVITY; i = i + 1) begin
                if (counts[set_in][min_idx] > counts[set_in][i]) begin
                    min_idx = i;
                end
            end
            counts[set_in][min_idx] <= tick;
            new_idx <= min_idx;
        end
    end
    
    assign next_out = new_idx;
endmodule
