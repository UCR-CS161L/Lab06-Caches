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

module cache #(
    parameter ASSOCIATIVITY  =  8,
    parameter WAY_BITS       =  4,
    parameter BLOCK_BITS     =  4,
    parameter SET_BITS       =  3,
    parameter TAG_BITS       = 25,
    parameter DATA_BITS      = 32,
    parameter ADDR_BITS      = 32,
    parameter REPLACEMENT    = "LRU"
) (
    input wire                   clk,
    input wire                   rst,
    input wire                   enable,
    input wire [ADDR_BITS-1:0]   address_in,
    input wire [DATA_BITS-1:0]   data_in,
    
    output wire hit_out,
    output reg [DATA_BITS-1:0] data_out
);

wire                 valids[ASSOCIATIVITY-1:0];
wire [TAG_BITS-1:0]  tags[ASSOCIATIVITY-1:0];
wire [DATA_BITS-1:0] data[ASSOCIATIVITY-1:0];

wire [SET_BITS-1:0] set_idx;
wire [TAG_BITS-1:0] tag;

wire [WAY_BITS-1:0] way;
wire [WAY_BITS-1:0] match;

reg [ASSOCIATIVITY-1:0] hits;
reg [ASSOCIATIVITY-1:0] enables;

 generate
     if (REPLACEMENT == "FIFO") begin
         fifo_replacement # (
             .ASSOCIATIVITY(ASSOCIATIVITY), 
             .SET_SIZE(SET_BITS),
             .WAY_SIZE(WAY_BITS)
         ) replacement (
             .clk(clk),
             .rst(rst),
             .enable(enable),
             .set_in(set_idx),
             .way_in(match),
         .next_out(way)
         );
     end else if (REPLACEMENT == "LRU") begin
         lru_replacement # (
             .ASSOCIATIVITY(ASSOCIATIVITY), 
             .SET_SIZE(SET_BITS),
             .WAY_SIZE(WAY_BITS)
         ) replacement (
             .clk(clk),
             .rst(rst),
             .enable(enable),
             .set_in(set_idx),
             .way_in(match),
             .next_out(way)
         );
     end
 endgenerate
    
genvar i;

generate
    for (i = 0; i < ASSOCIATIVITY; i = i+1) begin 
        set #(.INDEX_BITS(SET_BITS), .TAG_BITS(TAG_BITS), .DATA_BITS(DATA_BITS)) SET (
            .clk(clk),
            .rst(rst),
            .enable(enables[i]),
            .index_in(set_idx),
            .tag_in(tag),
            .data_in(data_in),
            .valid_out(valids[i]),
            .tag_out(tags[i]),
            .data_out(data[i])
            );
    end
endgenerate

encoder #(.IN_SIZE(ASSOCIATIVITY), .OUT_SIZE(WAY_BITS)) match_encoder (.out(match), .in(hits));

integer w;

always @(posedge clk) begin
    if(rst) begin
        hits <= 0;
        enables <= 0;
        data_out <= 0;
    end else begin
        enables <= enable << way;    
        data_out <= data[enable ? way : match];
        for (w = 0; w < ASSOCIATIVITY; w = w + 1) begin 
            hits[w] = tag === tags[w] && valids[w] === 1;
        end
    end
end

always @(tag or set_idx) begin
    for (w = 0; w < ASSOCIATIVITY; w = w + 1) begin 
        hits[w] = tag === tags[w] && valids[w] === 1;
    end    
end

always @(enable or way) begin
    enables <= enable << way;    
end

assign hit_out = |hits;
assign set_idx = address_in[SET_BITS+BLOCK_BITS:BLOCK_BITS];
assign tag = address_in[ADDR_BITS-1:SET_BITS+BLOCK_BITS];

endmodule
