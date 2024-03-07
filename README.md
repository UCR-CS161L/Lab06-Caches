# Lab 6 - Caches 

## Introduction

In this lab, you will be exploring how to design a cost effective cache. You will test a number of different cache configurations, and see how these configurationss affect the miss rate. An implementation of a cache module, written in Verilog, is included in this lab. It has been tested in iverilog and works. Additionally, we will explore data and instruction caches.

To test these different cache configurations you will need to run some programs and capture the addresses that the program referenced while running the program. To capture these addresses
we will use Valgrind to instrument 4 different programs: two matrix multiplication programs, one row major and the other column major, and two "Hello, World!" programs, one in C and the other
in C++.


**Note:** For this lab you will use the `valgrind` tool. This tool simulates a runtime environment for the X86 Intel processor to instrument and measure programs. In this lab we will be 
specifically collecting memory traces of several programs. The `valgrind` tool is already installed in the Codespace for this lab. You may also install this tool on your personal system. 
For Mac OS X, users, especially those running on the newer Arm processors, it is not possible to install `valgrind` currently. 

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

The other two programs that show how important understanding a computer's 
architecture is, and the compiler is when developing efficient code. For this 
study, you are to compare and analyze the execution time of the two programs 
given in this repository in the files [program0.cpp](./program0.cpp) and 
[program1.cpp](./program1.cpp). You should run a number of experiments varying 
the input size from 100 to 30,000. 

For this lab, we'll only run these executables with a size of 100. Creating traces for sizes greater than 100 will take too long on the containers used by Codespaces.

### Building the Executables

Before running the experiments, it is necessary that you build the code associated with this lab. These executables are built using CMake. CMake is available on Windows, Mac OS X and Linux, and is the default project file for Visual Studio Code. Therefore, be begin building the executables, open the folder containing these files in Visual Studio Code. Then from the Command Pallete type CMake and then select "CMake: Configure". This step creates the build files for this project. You may be asked to select a kit. This means to select a C++ compiler installed on your system. Once you have configured the CMake project, you can build the executables. These executables will be called matrix-mul-row and matrix-mul-col. 

If you don't have Visual Studio Code and the toolchain for C++, then you can do this project in a Codespace on GitHub, just as you've done in previous labs. As usual, create a repository by copying this template repository to a repository you own. Then go to Code -> Create Code Space. From there, follow the directions above to build the executables.

If for some reason you cannot do the CMake configuration and/or build in Visual Studio Code, then you can execute the following commands to configure and build the executables.

```sh
mkdir build
cmake -B ./build . # Configures the build system
cmake --build build # Build the executables
```

### Running the Executables

Once the executables are built, they can be run to observe how long matrix multiplications take when accessing the matrix either in row major or column major mode. If successful (it should always be successful), it will print out passed and the number of seconds take to do the matrix multiplication. 

The following is an example of running a single experiment for row major matrix multiplication:

```sh
./build/matrix-mul-row-major 100 # run matrix multiplication with 100 X 100 matrix
```

The folling is an example of running a single experiment for column major matrix multiplication:

```sh
./build/matrix-mul-col-major 100 # run matrix multiplication with 100 X 100 matrix
```

### Capturing Memory Addresses

First, produce the memory traces for each of the executables described above. For example, for the C version of hello world, use the following command:

```sh
valgrind --tool=lackey --trace-mem=yes --basic-counts=no ./build/hello_c 2> hello_c.raw.mem
```

Next, to produce the memory traces for each of the programs from the case student. The following command will produce a memory trace for `matrix-mul-col-major`:

```sh
valgrind --tool=lackey --trace-mem=yes --basic-counts=no ./build/matrix-mul-col-major 100 2> matrix-mul-col-major.raw.mem
```

These commands use the lackey tool of `valgrind` to do a memory trace for the executables. It then simulates running the executable and keeps track of all types of memory accesses
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

The following command, using `awk`, shows how to filter the output of `valgrind` to a format usable by the cache module given as part of this lab.

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

### Testing Full, Data and Instruction Caches

In this lab we will compare the performance of Full caches (caching both data and instrucitons), data caches and instruction caches. Modern processors have data and instruciton caches and we want to explore here how we can use these two separate caches to pontentially be cheaper than full caches with similar performance.

In order to test these three types of caches, we'll need to filter the memory traces differently. For the Full cache we'll use all the appresses from the trace with the I and L prefixes. This filtering will mix both data and instruciton addresses. To test the Data and Instruction caches separately, we'll filter only the L and I addresses respectively.

To create the full cache address capture you run the `awk` command from above:

```sh
awk '{if($1 == "L" || $1 == "I") {split($2, a, ","); print a[1];}}' hello.raw.mem > hello.LI.mem
```

The LI extention to the memory trace will mark this file as that for testing Full cache performance.

To create the data cache address capture, run the following `awk` command:

```sh
awk '{if($1 == "L") {split($2, a, ","); print a[1];}}' hello.raw.mem > hello.L.mem
```

To create the instruction cache address capture, run the following `awk` command:

```sh
awk '{if($1 == "I") {split($2, a, ","); print a[1];}}' hello.raw.mem > hello.I.mem
```

### Using the Cache Simulator

The cache simulator provided reads addresses from a memory trace file and simulates multiple cache configurations and reports the miss rate (# misses / total accesses). This simulator has been tested with all the following attributes:
* 32-bit addresses
* **Block Size:** 16 elements
* **Replacement Policies:** LRU, FIFO
* **Cache Sizes:** 1024, 2048, 4096, 8192, 16384 locations
* **Associativity:** Direct Mapped, 2-way, 4-way, and 8-way

The input to synthesize the simulator will be the following, given as arguments on the command line:
* Associativity as 1, 2, 4, or 8
* Cache size as 1024, 2048, 4096, 8192 or 16384
* Replacement policy as LRU or FIFO 
* An input file produced by `valgrind` and filtered with `awk` with a memory trace from the executables described above.

You can change the configuration in the cache_tb.v file as well. The following code produces the same configuration as the iverilog command above:

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
    parameter TRACE_FILE    = "./trace.mem"
);
```
If you do make the changes in `cache_tb.v` rather than change the parameters on the command line, then you should use the following command:

```sh
iverilog -o lab06_sim cache.v cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v
```

However, you can also easily configure the simulator using the command line to synthesize a test bench that prints out performance data. For example, this command line would create a 2-way set associative, 16KB (notice the cache size in the command below is 8K not 16K, why?) cache that uses a LRU replacement policy:

```sh
iverilog -o lab06_sim -Pcache_tb.ASSOCIATIVITY=2 -Pcache_tb.CACHE_SIZE=8192 -Pcache_tb.REPLACEMENT=\"LRU\" -Pcache_tb.TRACE_FILE=\"hello.mem\" cache.v cache_tb.v set.v encoder.v lru_replacement.v fifo_replacement.v
```

This command line would then produce a simulation which when run would output the miss rate, as specified below, for a 2-way cache of size 8192 blocks using the LRU replacement policy for the addresses in the file named trace.mem that is part of this lab.

Notice that it is the same command as above, with the `-Pcache_tb.Xs` removed. Adding `-Pcach_tb.X=Y` overrides the values in the .v file

You only need to modify the parameters ASSOCIATIVITY, CACHE_SIZE and REPLACEMENT. Leave all other parameters the same.
To see the output for any configuration type the command: vvp cache_testbench.

The output from the simulator has the following format.
* First output is the associativity, 1, 2, 4, or 8, on it’s own line
* Next output is the cache size, 1024, 2048, 4096, 8192 or 16384, on it’s own line
* Next output is the replacement policy, LRU or FIFO, on it’s own line
* Finally, the output is the miss rate as a percentage, for example 5.72.

The follwwing output shows the cample output of the test bench:

```sh
Performance data for hello_cpp.LI.mem
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

## Deliverables

You will turn in a lab report that compares the caching miss rate for two hello world programs, one written in C the other in C++, and then output of running the matrix multiplication programs . Next, your report will identify the best cache configuration for each program based on the miss rate and the cost of the configuration. For the purposes of estimating the cost different configurations, you can assume a linear growth of cost for adding more cache. So as the size of the cache doubles the cost doubles. However, in the case of associativity, you can assume a non-linear growth. Since associativity does synthesize more registers or use more resources of a programmable device, but not at the same rate as adding more memory, assume that double the associativity increases the cost by 10%. For example, 2-way associativity is only 10% more expensive than than 4-way associativity.

You will also provide information comparing the various configurations you test and their costs and performance. Based on this information you will provide one configuration that you believe is the best combinaiton of low cost and good performance. 

As an example. You could compare the performance and cost of a full cache (that caches both data and instructions) of one size, say 32K, versus two separate caches, one for data and one for instructions. These two caches do not need to be the same size. For example, you could have a data cache of 16K and an instruction cache of 8K. You would then run the simulation for each of these configurations and not the output. From this you get an understanding of the miss rates for the full cache and the combination of the separate caches. For example if the output for simulating the full cache for one of the memory traces is the following:

```sh
Performance data for hello_cpp.LI.mem
misses:           60000
total accesses: 2750000
Miss rate:         2.18
Way bits:             2
Set bits:            10
Tag bits:            18
Associativity:        2
Cache Size:       32768
Replacement:        LRU
```

And the output for the data cache is:

```sh
Performance data for hello_cpp.L.mem
misses:           30000
total accesses:  550000
Miss rate:         5.45
Way bits:             2
Set bits:             9
Tag bits:            19
Associativity:        2
Cache Size:       16384
Replacement:        LRU
```

And the output for the instruction cache is:

```sh
Performance data for hello_cpp.I.mem
misses:           30000
total accesses: 2200000
Miss rate:         1.36
Way bits:             2
Set bits:             8
Tag bits:            20
Associativity:        2
Cache Size:        8192
Replacement:        LRU
```

To compare the overall performance we need to combine the last two results and compare that result to the results from the first. For the data above, the overall performance of the two caches is (30000 + 30000) / (550000 + 2200000) = 60000 / 2750000 =  2.18. So if this were actual output (it's not) of the simulator, these two configurations have the same performance. However, the separate caches would cost less, becuase it has a total cache size of 24K, whereas the full cache is 32K. So for 25% less cost you get the same performace.

Your job for this lab is to do similar analysis for each program over varying configurations where you change the Cache Size, Associativity and Replacement policy.

### Producing the Data Graphs

You should provide at least one graph of the data from all the configurations tested for one of the executables described above. You can provide charts for more than one executable, but you 
must do at least one. You only need to produce this graph for one replacement policy. This graph can be produced in any software you are familiar with, for example Excel or a Jupyter notebook. This graph should have separate lines for each of the associativity sizes, 1, 2, 4, and 8. The X-axis should be the size of the cache, and the Y-axis should be the miss rate.

### The Lab Report

Finally, create a file called REPORT.md and use GitHub markdown to write your lab report. This lab
report will contain the information described above. Your charts can just be .png or .jpg files added to the repository. While your grade will be entirely based on this report, don't feel like
you need to overload the grader with information by writing a lot of text. Instead specify which configurations you chose and justify your answer by comparing the performance and cost.  Additionally, describe your observations across the 4 executables and if there is a common theme among the configurations you choose. 

Don't forget to include at least one chart in this lab report.

## Submission:

Each student **must** turn in their repository from GitHub to Gradescope. The contents of which should be:
- A REPORT.md file with your name and email address, and the content described above
- All Verilog file(s) used in this lab (implementation and test benches).

**If your file does not synthesize or simulate properly, you will receive a 0 on the lab.**
