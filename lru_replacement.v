`timescale 1ns / 1ps
//=========================================================================
// Name & Email must be EXACTLY as in Gradescope roster!
// Name: 
// Email: 
// 
// Assignment name: 
// Lab section: 
// TA: 
// 
// I hereby certify that I have not received assistance on this assignment,
// or used code, from ANY outside source other than the instruction team
// (apart from what was provided in the starter file).
//
//=========================================================================

//=========================================================================
//
// DO NOT CHANGE ANYTHING BELOW THIS COMMENT. IT IS PROVIDED TO MAKE SURE 
// YOUR LAB IS SUCCESSFULL. 
//
//=========================================================================

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
