# Lab 6 - Caches 

## Introduction

In this lab, you will be exploring cache design trade-offs. You will test a number of different cache configurations, and see how these configurationss affect the number of miss rate. An implementation of a cache module, written in Verilog, is included in this lab. It has been tested in iverilog and works. Additionally, we'll briefly explore why there was a difference in 
performance for the case study done in Lab04.

**Note:** For this lab you will use the `valgrind` tool. This tool simulates a runtime environment for the X86 Intel processor to instrument and measure programs. In this lab we will be 
specifically collecting memory traces of several programs. The `valgrind` tool is already installed in the Codespace for this lab. You may also install this tool on your personal system. 
For Mac OS X, users, especially those running on the newer Arm processors, it is not possible to install `valgrind` currently. 

To collect a memory trace using `valgrind` we'll use the following command:

```sh
valgrind --tool=lackey --trace-mem=yes --basic-counts=no ./hello
```

This command uses the lackey tool of `valgrind` to do a memory trace for the executable `hello`. It then simulates running the executable and keeps track of all types of memory accesses
including data loads, store and modifications, and instruction loads. For this lab, we will be interested in only the loads of data and instructions.

The output of this program should look something like this:

```
==3930== Lackey, an example Valgrind tool
==3930== Copyright (C) 2002-2017, and GNU GPL'd, by Nicholas Nethercote.
==3930== Using Valgrind-3.18.1 and LibVEX; rerun with -h for copyright info
==3930== Command: ./prog0.out 100
==3930== 
I  040202b0,3
I  040202b3,5
 S 1ffeffff78,8
I  04021050,4
I  04021054,1
 S 1ffeffff70,8
I  04021055,3
I  04021058,2
 S 1ffeffff68,8
I  0402105a,2
 S 1ffeffff60,8
I  0402105c,2
 S 1ffeffff58,8
I  0402105e,2
 S 1ffeffff50,8
I  04021060,1
 S 1ffeffff48,8
I  04021061,7
I  04021068,4
 S 1ffefffef8,8
I  0402106c,2
I  0402106e,7
I  04021075,7
 M 0403ae0e,1
I  0402107c,7
 S 0403aaf0,8
I  04021083,4
I  04021087,3
I  0402108a,7
I  04021091,7
 S 04039aa0,8
I  04021098,7
 L 04039e80,8
I  0402109f,7
 S 0403ab00,8
```

The first 5 lines are the header to the output, and will be ignored. The succeeding lines are the memory accesses. Lines starting with an `L` are data loads, starting with an `S` are
data stores, starting with `I` are instruction loads and starting with `M` data modifications. We will be looking at the lines starting with `L` and `I`. After the memory access type
are the address and size of the memory accessed. We are only interested in the accessed address, however. 

The following descption, using `awk`, describes how to collect a memory trace and thenb filter the output of `valgrind` to a format usable by the cache module given as part of this lab.

First you will collect the memory trace and store it in a text file using the following command:

```sh
valgrind --tool=lackey --trace-mem=yes --basic-counts=no ./hello 2> hello.raw.mem
```

To filter the output from `valgrind` into a format usable by the cache module, use the following command:

```sh
awk '{if($1 == "L" || $1 == "I") {split($2, a, ","); print a[1];}}' hello.raw.mem > hello.mem
```

The output of this command will look like that:

```
040202b0
040202b3
04021050
04021054
04021055
04021058
0402105a
0402105c
0402105e
04021060
04021061
04021068
0402106c
0402106e
04021075
0402107c
04021083
04021087
0402108a
04021091
```

This output is the format we will use for the data collection throughout this lab. 

## Deliverables

You will turn in a lab report that compares the caching miss rate for two hello world programs, one written in C the other in C++, and then output of running the case study programs from Lab04. Next, your report will identify the best cache configuration for each program based on the miss rate. Your answer does not necessarily have to be the configuration with the best performance, but you might want to way the diminishing returns on adding more transistors to get less and less performance benefit. There is no right or wrong answer, but you must choose a configuration and provide and explanation as to why you believe such a configuration is best.

### Using the Cache Simulator

The cache simulator provided reads addresses from a memory trace file and simulates multiple cache architectures and reports the miss rate (# misses / total accesses). This simulator has been tested with all the following attributes:
* 32-bit addresses
* **Block Size:** 16 elements
* **Replacement Policies:** LRU, FIFO
* **Cache Sizes:** 1024, 2048, 4096, 8192, 16384 locations
* **Associativity:** Direct Mapped, 2-way, 4-way, and 8-way

The input to your simulator will be the following, given as arguments on the command line:
* Associativity as 1, 2, 4, or 8
* Cache size as 1024, 2048, 4096, 8192 or 16384
* Replacement policy as LRU or FIFO 
* An input file produced by `valgrind` and filtered with `awk` with a memory trace from the executables described above.

You can change any of these parameters either directly in cach_tb.v or on the command line when you synthesize the testbench.

For example, this command line would create a 2-way set associative, 16KB (notice the cache size in the command below is 8K not 16K, why?) cache that uses a LRU replacement policy:

```sh
iverilog -o lab06_sim -Pcache_tb.ASSOCIATIVITY=2 -Pcache_tb.CACHE_SIZE=8192 -Pcache_tb.REPLACEMENT=\"LRU\" cache.v cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v
```

You can also change the memory trace file on the command line when synthesizing the lab project with the following command:

```sh
iverilog -o lab06_sim -Pcache_tb.ASSOCIATIVITY=2 -Pcache_tb.CACHE_SIZE=8192 -Pcache_tb.REPLACEMENT=\"LRU\" -Pcache_tb.TRACE_FILE=\"hello.mem\" cache.v cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v
```

The only change from the previous command is the addition of the argument `-Pcache_tb.TRACE_FILE=\"hello.mem\"`.

This command line would then produce a simulation which when run would output the miss rate, as specified below, for a 2-way cache of size 8192 blocks using the LRU replacement policy for the addresses in the file named trace.mem that is part of this lab.

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

If you do make the changes in `cache_tb.v` rather than change the parameters on the command line, then you should use the following command:

```sh
iverilog -o lab06_sim cache.v cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v
```

Notice that it is the same command as above, with the `-Pcache_tb.Xs` removed. Adding `-Pcach_tb.X=Y` overrides the values in the .v file

You only need to modify the parameters ASSOCIATIVITY, CACHE_SIZE and REPLACEMENT. Leave all other parameters the same.
To see the output for any configuration type the command: vvp cache_testbench.

The output from the simulator has the following format.
* First output is the associativity, 1, 2, 4, or 8, on it’s own line
* Next output is the cache size, 1024, 2048, 4096, 8192 or 16384, on it’s own line
* Next output is the replacement policy, LRU or FIFO, on it’s own line
* Finally, the output is the miss rate as a percentage, for example 5.72.

To test your configuration you should use the memory trace file, trace.mem, included in this lab’s zipfile. The output for this file should look like for the above vvp command line:

```sh
misses:          216179
total accesses:  849921
Miss rate:        25.44
Way bits:             4
Set bits:             4
Tag bits:            24
Associativity:        8
Cache Size:        2048
Replacement:        LRU
```
### Programs for Memory Traces

We are going to use 4 programs for the analysis we are doing in this lab. The first two are simple hello world programs. It is suprising how long the memory traces are for these simple 
programs.

For the C version of the hello world program, use the following code:

```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    printf("Hello, World!\n");
    return EXIT_SUCCESS;
}
```

For the C++ version of the hello world program, use the following code:

```c++
#include <iostream>
#include <cstdlib>

int main(int argc, char *argv[]) {
    std::cout << "Hello, World!" << std::endl;
    return EXIT_SUCCESS;
}
```

The other two programs are the same as from Lab04. The file `case_study.tar.gz` contains the code, and is included with these lab. Unzip this file and make the executables `prog0.out` and
`prog1.out`. For this lab, we'll only run these executables with a size of 100. Creating traces for sizes greater than 100 will take too long on the containers used by Codespaces.

### Analysis

First, produce the memory traces for each of the executables described above. For example, for the C version of hello world, use the following command:

```sh
valgrind --tool=lackey --trace-mem=yes --basic-counts=no ./hello 2> hello.raw.mem
```

Don't forget to process `hello.raw.mem` using `awk` as described above.

Next, produce the memory traces for each of the programs from the case student. The following command will produce a memory trace for `prog0.out` from the case study:

```sh
valgrind --tool=lackey --trace-mem=yes --basic-counts=no ./prog0.out 100 2> prog0.raw.mem
```
Finally, run experiments, with all the configurations above, for each of the filtered memory trace files. You should also do some other analysis to choose your best configuration for each
executable. Your report will specify and describe why you chose each configuration. 

You don't need to any wave forms for this lab.

### Producing the Data Graphs

You should provide at least one graph of the data from all the configurations tested for one of the executables described above. You can provide charts for more than one executable, but you 
must do at least one. You only need to produce this graph for one replacement policy. This graph can be produced in any software you are familiar with, for example Excel or a Jupyter notebook. This graph should have separate lines for each associativity tested. The X-axis should be the size of the cache, and the Y-axis should be the miss rate.

### The Lab Report

Finally, create a file called REPORT.md and use GitHub markdown to write your lab report. This lab
report will contain the information described above. Your charts can just be .png or .jpg files added to the repository. While your grade will be entirely based on this report, don't feel like
you need to overload the grader with information by writing a lot of text. Instead specify which configurations you chose for each executable and why.  Additionally, describe your observations across the 4 executables and if there is a common theme among the configurations you choose. Be sure to include at least one chart in this lab report.

## Submission:

Each student **must** turn in their repository from GitHub to Gradescope. The contents of which should be:
- A REPORT.md file with your name and email address, and the content described above
- All Verilog file(s) used in this lab (implementation and test benches).

**If your file does not synthesize or simulate properly, you will receive a 0 on the lab.**
