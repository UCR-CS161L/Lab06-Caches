# Lab 6 - Caches 

## Introduction

In this lab, you will be exploring cache design trade-offs. You will build a number of different caches, and see how these design choices affect the number of memory accesses. An implementation of a cache simulation, written in Verilog, is included in this lab’s zip file. It has been tested in iverilog and works. It will also work in Vivado with one minor change to the test bench.

**Note:** You can use a modified version of the [PTLSIM](https://drive.google.com/open?id=1mi9z5bPe8ol0j2o4DurU2-ZQXi6OgFrH) simulator to get an executable's memory trace. This executable should work on any compiled C/C++ application. To use it call ./ptlsim with your executable as an argument (i.e. "$./ptlsim a.out"). The simulator should output two files ptlsim.log, and ptlsim.cache. The .cache file will hold a trace of instruction and data loads for your executable. PTLSIM is used to generate traces of any compiled program you have installed. You can generate traces if you want to test your simulator on multiple programs, but we are only grading the performance on the trace below. (It is not required to use this tool, but it might be used to inform your decision for this lab.)

## Deliverables

You will turn in a lab report that chooses a configuration for a cache that you feel performs the best based on your testing. There is no right or wrong answer, but you must choose a configuration and provide data that supports why you believe such a configuration is best.

The cache simulator provided reads one address trace file and simulates multiple cache architectures and reports the miss rate (# misses / total accesses). This simulator has been tested with all the following attributes:
* 32-bit addresses
* **Block Size:** 16 elements
* **Replacement Policies:** LRU, FIFO
* **Cache Sizes:** 1024, 2048, 4096, 8192, 16384 locations
* **Associativity:** Direct Mapped, 2-way, 4-way, and 8-way

The input to your simulator will be the following, given as arguments on the command line:
* Associativity as 1, 2, 4, or 8
* Cache size as 1024, 2048, 4096, 8192 or 16384
* Replacement policy as LRU or FIFO 
* An input file produced by PTLSIM with a trace of memory locations that is redirected to your executable.

You can change any of these parameters either directly in cach_tb.v or on the command line when you synthesize the testbench.
For example, this command line would create a 2-way set associative, 16KB cache that uses a FIFO replacement policy:

```sh
iverilog -o cache_testbench -Pcache_tb.ASSOCIATIVITY=2
-Pcache_tb.CACHE_SIZE=8192 -Pcache_tb.REPLACEMENT=\”LRU\” cache.sv
cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v
```

This command line would then produce a simulation that would output the miss rate, as specified below, for a 2-way cache of size 8192 blocks using the LRU replacement policy for the addresses in the file named trace.mem that is part of this lab.

You can also change the configuration in the cache_tb.v file as well. The following code produces the same configuration as the iverilog command above:

```verilog
module cache_tb #(
    parameter BLOCK_BITS    =    4,
    parameter ADDRESS_BITS  =   32,
    parameter ASSOCIATIVITY =    2,
    parameter REPLACEMENT   = "LRU",
    parameter CACHE_SIZE    = 8192,
    parameter WAY_BITS      = `bits(ASSOCIATIVITY) + 1,
    parameter SET_BITS      = `calc_set_bits(CACHE_SIZE, ASSOCIATIVITY, BLOCK_BITS),
    parameter TAG_BITS      = ADDRESS_BITS - BLOCK_BITS - SET_BITS
);
```
You only need to modify the parameters ASSOCIATIVITY, CACHE_SIZE and REPLACEMENT. Leave all other parameters the same.

The following command line would create a simulation that you would use for collecting data:

```sh
iverilog -o cache_testbench cache.sv cache_tb.v set.v encoder.v
lru_replacement.v fifo_replacement.v
```

Notice that it is the same command as above, with the `-Pcache_tb.Xs` removed. Adding `-Pcach_tb.X=Y` overrides the values in the .v file

To see the output for any configuration type the command: vvp cache_testbench.

The output from the simulator has the following format.
* First output is the associativity, 1, 2, 4, or 8, on it’s own line
* Next output is the cache size, 1024, 2048, 4096, 8192 or 16384, on it’s own line
* Next output is the replacement policy, LRU or FIFO, on it’s own line
* Finally, the output is the miss rate as a percentage for example 5.72.

To test your configuration you should use the memory trace file, trace.mem, included in this lab’s zipfile. The output for this file should look like for the above vvp command line:

```sh
Associativity:      8 
Cache size:         16384 
Replacement policy: LRU 
Miss rate:          5.72
```

You may use any data you want (as produced by the PTLSIM tool mentioned above, but to test if you're simulating the caches correctly the following values will be used as part of the autograder. The best practice would be to test your code for all the possible inputs against the given memory trace and make sure it matches exactly the values below.

<table style="border-collapse: collapse; width: 400px; height: 174px;" border="1">
    <tbody>
        <tr style="height: 29px;">
            <td style="width: 100%; height: 29px; text-align: center;" colspan="6">LRU Replacement Policy</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>1024</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>2048</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>4096</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>8192</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>16834</strong></td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>1</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">55.01</td>
            <td style="width: 18%; height: 29px; text-align: right;">42.07</td>
            <td style="width: 18%; height: 29px; text-align: right;">29.30</td>
            <td style="width: 18%; height: 29px; text-align: right;">20.74</td>
            <td style="width: 18%; height: 29px; text-align: right;">13.91</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>2</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">51.58</td>
            <td style="width: 18%; height: 29px; text-align: right;">36.44</td>
            <td style="width: 18%; height: 29px; text-align: right;">23.70</td>
            <td style="width: 18%; height: 29px; text-align: right;">13.98</td>
            <td style="width: 18%; height: 29px; text-align: right;">8.49</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>4</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">48.85</td>
            <td style="width: 18%; height: 29px; text-align: right;">33.97</td>
            <td style="width: 18%; height: 29px; text-align: right;">20.04</td>
            <td style="width: 18%; height: 29px; text-align: right;">11.33</td>
            <td style="width: 18%; height: 29px; text-align: right;">6.37</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>8</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">47.44</td>
            <td style="width: 18%; height: 29px; text-align: right;">32.20</td>
            <td style="width: 18%; height: 29px; text-align: right;">18.63</td>
            <td style="width: 18%; height: 29px; text-align: right;">10.02</td>
            <td style="width: 18%; height: 29px; text-align: right;">5.72</td>
        </tr>
    </tbody>
</table>

**Note:** The verilog code provided for some unknown reason produces the miss rate 50.29 instead of 47.44 for 8-way associativity and a cache size of 1024. Use 47.44 for any graphing you do in the lab report. All other values for this replacement policy are correct.


<table style="border-collapse: collapse; width: 400px; height: 174px;" border="1">
    <tbody>
        <tr style="height: 29px;">
            <td style="width: 100%; height: 29px; text-align: center;" colspan="6">FIFO Replacement Policy</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>1024</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>2048</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>4096</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>8192</strong></td>
            <td style="width: 18%; text-align: center; height: 29px;"><strong>16834</strong></td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>1</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">55.01</td>
            <td style="width: 18%; height: 29px; text-align: right;">42.07</td>
            <td style="width: 18%; height: 29px; text-align: right;">29.30</td>
            <td style="width: 18%; height: 29px; text-align: right;">20.74</td>
            <td style="width: 18%; height: 29px; text-align: right;">13.91</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>2</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">53.31</td>
            <td style="width: 18%; height: 29px; text-align: right;">38.32</td>
            <td style="width: 18%; height: 29px; text-align: right;">25.47</td>
            <td style="width: 18%; height: 29px; text-align: right;">15.37</td>
            <td style="width: 18%; height: 29px; text-align: right;">9.49</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>4</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">51.86</td>
            <td style="width: 18%; height: 29px; text-align: right;">37.07</td>
            <td style="width: 18%; height: 29px; text-align: right;">23.11</td>
            <td style="width: 18%; height: 29px; text-align: right;">13.67</td>
            <td style="width: 18%; height: 29px; text-align: right;">7.86</td>
        </tr>
        <tr style="height: 29px;">
            <td style="width: 10%; text-align: center; height: 29px;"><strong>8</strong></td>
            <td style="width: 18%; height: 29px; text-align: right;">51.14</td>
            <td style="width: 18%; height: 29px; text-align: right;">35.98</td>
            <td style="width: 18%; height: 29px; text-align: right;">22.40</td>
            <td style="width: 18%; height: 29px; text-align: right;">12.79</td>
            <td style="width: 18%; height: 29px; text-align: right;">7.44</td>
        </tr>
    </tbody>
</table>

### Analysis

As part of this lab you should run experiments with the configurations above, at the very least. You should also do some other analysis to choose your best configuration. For example, you can do larger cache sizes, 32K, 64K, etc. You could also create a new replacement policy. For example, you could create a new policy called random_replacement.v that picks a random number to choose a set to replace instead of using LRU (you can copy lru_replacement.v and change a couple of lines to achieve this). Another idea would be to analyze how long each configuration takes to converge to the final miss rate. If you modify the cache_tb.v file you can have it print data pairs with the current time and current miss rate and graph the miss rate over time. Any clever ideas you can come up with to analyze these confirmations is fair game.

In the end, your lab report must contain at least the graphing of the data above for each of the configurations you test, plus the graphs for the data you produce when you go beyond the configurations listed above.

From this data you should be able to form an opinion as to the best configuration and the make a coherent argument based on this data as to why it’s the best configuration. 

You don't need to add a marker this time. Also, I've provided a .gtkw.

### Producing the Data Graphs


### The Lab Report

Finally, create a file called REPORT.md and use GitHub markdown to write your lab report. This lab
report will again be short, and comprised of two sections. The first section is a description of 
each test case. Use this section to discuss what changes you made in your tests from the prelab
until this final report. The second section should include your waveform. 

## Submission:

Each student **must** turn in their repository from GitHub to Gradescope. The contents of which should be:
- A REPORT.md file with your name and email address, and the content described above
- All Verilog file(s) used in this lab (implementation and test benches).

**If your file does not synthesize or simulate properly, you will receive a 0 on the lab.**
