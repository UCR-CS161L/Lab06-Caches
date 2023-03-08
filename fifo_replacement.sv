`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2021 11:12:57 AM
// Design Name: 
// Module Name: fifo_replacement
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


module fifo_replacement #(
    parameter WAY_SIZE      = 3,
    parameter SET_SIZE      = 2,
    parameter ASSOCIATIVITY = 1
    )(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [SET_SIZE-1:0] set_in,
    input wire [WAY_SIZE-1:0] way_in,
    output wire [WAY_SIZE-1:0] next_out
    );
    
    reg [WAY_SIZE-1:0] prev;
    reg [WAY_SIZE-1:0] curr [(1 << SET_SIZE)-1: 0];
    
    integer i;
    
    always @(posedge clk) begin
        if(rst) begin
            for (i = 0; i < (1 << SET_SIZE); i = i + 1) begin
                curr[i] <= 0;
            end
        end else begin
            if(enable) begin
                curr[set_in] = (curr[set_in] + 1) % ASSOCIATIVITY;
            end
        end
    end
    
    always @(set_in or enable) begin
        prev = curr[set_in];
    end
    
    assign next_out = (ASSOCIATIVITY === 1) ? 0 : prev;
    
endmodule
