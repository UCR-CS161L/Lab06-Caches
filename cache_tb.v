`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2021 12:16:02 PM
// Design Name: 
// Module Name: cache_tb
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

`define bits(x) $rtoi($log10(x)/$log10(2))

`define calc_set_bits(cache_size, associativity, block_bits) `bits(cache_size) - `bits(associativity) - block_bits 

module cache_tb #(
    parameter BLOCK_BITS    =    4,
    parameter ADDRESS_BITS  =   32,
    parameter ASSOCIATIVITY =    8,
    parameter REPLACEMENT   = "LRU",
    parameter CACHE_SIZE    = 2048,
    parameter WAY_BITS      = `bits(ASSOCIATIVITY) + 1,
    parameter SET_BITS      = `calc_set_bits(CACHE_SIZE, ASSOCIATIVITY, BLOCK_BITS),
    parameter TAG_BITS      = ADDRESS_BITS - BLOCK_BITS - SET_BITS
);

reg clk;
reg rst;
wire hit;
wire [31:0] data_out;

reg enable;

reg [31:0] data_in;
reg [31:0] address_in;

cache #(
     .ASSOCIATIVITY(ASSOCIATIVITY),
     .WAY_BITS(WAY_BITS),
     .SET_BITS(SET_BITS),
     .BLOCK_BITS(BLOCK_BITS),
     .TAG_BITS(TAG_BITS),
     .REPLACEMENT(REPLACEMENT)
) UUT (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .address_in(address_in),
    .data_in(data_in),
    .hit_out(hit),
    .data_out(data_out)
);

initial begin
   $dumpfile("testbench.vcd");
   $dumpvars(0, UUT);
end

initial begin
    clk = 0; rst = 1; #50;
    clk = 1; rst = 1; #50;
    clk = 0; rst = 0;

    forever begin
        #50; clk = ~clk;
    end
    
end

integer address_file;

initial begin
    $write("Opening file...");
    address_file = $fopen("./trace.mem", "r");
    if ($feof(address_file)) begin
        $display("*** Cannot open trace file ***", address_file);
        $finish;
    end
    $display("Done");
end

integer address;
integer scan_file;

integer miss_count = 0;
integer total_count = 0;

initial begin 
        enable = 0;
    @(negedge rst);
    
    forever begin   
        if($feof(address_file)) begin
            $display("End of file");
            $display("misses:         %7d", miss_count);
            $display("total accesses: %7d", total_count); 
            $display("Miss rate:      %7.2f", (100.0 * miss_count / total_count));
            $display("Way bits:       %7d", UUT.WAY_BITS);
            $display("Set bits:       %7d", UUT.SET_BITS);
            $display("Tag bits:       %7d", UUT.TAG_BITS);
            $display("Associativity:  %7d", ASSOCIATIVITY);
            $display("Cache Size:     %7d", (1 << (`bits(ASSOCIATIVITY) + SET_BITS + BLOCK_BITS)));
            $display("Replacement:    %7s", REPLACEMENT);
            $finish;
        end
        scan_file = $fscanf(address_file, "%x\n", address_in);
        
        @(posedge clk);
        total_count = total_count + 1;
        if (hit === 0) begin
            miss_count = miss_count + 1;
            data_in = $urandom;
            enable = 1;
        end
        @(posedge clk);
        enable = 0;
    end
end

endmodule
