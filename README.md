# Lab 4 - The Datapath Control and ALU Control Units 

## Introduction

In this lab, you will be building a single cycle version of the MIPS datapath. The datapath is composed of many components interconnected. They include an ALU, Registers, Memory, and most importantly the Program Counter (PC). The program counter is the only clocked component within this design and specifies the memory address of the current instruction. Every cycle the PC will be moved to the location of the next instruction. The MIPS architecture is BYTE ADDRESSABLE. Remember this when handling the PC, and the memory (which is WORD ADDRESSABLE).

## Prelab

You will need to submit several tests for your prelab. These must be submitted on ilearn prior to coming to the lab (check online for due dates). These tests will each consist of an init.coe, a corresponding .asm file and a processor_tb.v file for each.your test file (init.coe a corresponding .asm file and a processor_tb.v). The tests you should write are:


**`individualInstructions.asm`**
```asm
lw $v0, X($zero)
lw $v1, Y($zero)
add $a0, $v0, $v1
addi $a0, $v0, Z
...
```

Where X and Y are the address of data you have placed in your .coe file and Z is the immediate you are using. The numbers corresponding to the register numbers are in a table at the end of the document.

**`program.asm`**

```asm
# An entire program where each instruction
# has an effect on the final outcome.
# The result will be verified through 
# inspection of the write_reg_data value during
# execution of the last instruction (see below)
```

**`individualInstructions.coe`**

```asm
100011 00000 00010 XXXXXXXXXXXXXXXX
100011 00000 00011 YYYYYYYYYYYYYYYY
000000 00010 00011 00100 00000 000000
001000 00010 00100 ZZZZZZZZZZZZZZZZ
```

The spaces are added for clarity and should be removed before running. The X’s, Y’s, and Z’s should also be replaced with there corresponding values. 
program.coe
Machine language translation of the program from above. 

See testbench example files below.

Your init.coe should demonstrate that you have read through the lab specifications and understand the goal of this lab. You do not need to begin designing yet, but this testbench will be helpful during the lab while you are designing. 

The component connections (shown below) are outlined in the CS161 notes.
![](./assets/single_cycle_datapath.png)


You will need to submit your testbench on ilearn prior to coming to lab (check online for due
dates). Your testbench should demonstrate that you have read through the lab specifications
and understand the goal of this lab. You will need to consider the boundary cases. You do not
need to begin designing yet, but this testbench will be helpful during the lab while you are
designing.

You will submit the entire lab repository to Gradescope. Part of your score will come from the fact
that it properly sythesizes. The other part of your score will be based on the completeness of your
tests, which the TA and I will grade.

## Recommended Iterative Development

### Step 1: 

Count up the PC and check that each instruction is correct (`instr_opcode`, `reg1_addr`, `reg2_addr`, `write_reg_addr`)

Modules: 
- Instruction memory* ([`cpumemory.v`](./cpumemory.v))
- PC Register ([`gen_register.v`](./gen_register.v))
- PC adder (optional)

### Step 2:
Verify that the control signals are still correct on the `controlUnit` from the previous lab. Verify that you can read values from the registers (at this point they will most likely be all 0’s). You should now be able to get defined values for all debug signals (including `reg1_data`, `reg2_data`, `write_reg_data`). The data values will most likely be all 0’s since no data manipulation is being done yet.

### Step 3:

Add the `aluControlUnit` from the previous lab as well as the ALU. There won’t be any change in the debug signals yet, but verify that the ALU output is defined. 

### Step 4:
Connect the Data Memory* to the ALU and the CPU registers. At this point your data signals (reg1_data, reg2_data, write_reg_data) should be correct for all non-branch instructions. 

* Data and Instruction memory are unified for our processor. The CPU_memory module is a dual-port memory unit that allows simultaneous reads of instructions as well as a read/write of data through separate ports. In step 1 you will only have the instruction ports connected, now you’ll connect the rest of them.

### Step 5:
Add the modules for the branching hardware. This may involve breaking some connections from step 1 to insert the proper hardware for branching. You should not have any undefined signal before this step, so it shouldn’t be too difficult to trace down any introduced high Z or undefined signals. 
## Deliverables

For the turn-in of this lab, you should have a working **single-cycle datapath**. The true inputs to the top module ([`processor.v`](./processor.v)) are only a `clk`, and `rst` signals, although you will need to have the debug signals correctly connected as well. The datapath should be programmed by a “`.coe`” file that holds MIPS assembly instructions. This file is a paramter to the top module, but defaults to “`init.coe`”.

For this lab, you are not required to build all the datapath components (in black in the image above) but you are required to connect them together in the datapath template provided (datapath.v). You will be connecting this datapath and your aluControlUnit.v and controlUnit.v from Lab 03 in the top-level module ([`processor.v`](./processor.v)). All of the files can be found here. If you need more functionality you will have to build the components yourself. To use the given components you only need to copy the given Verilog files into your project. By default, the architecture's memory loads data from an “`init.coe`” file. The programming occurs when the rst signal is held high. A sample init.coe file is given but does not fully test the datapath. You will have to extend it. For convenience, the assembly for the `init.coe` file can be found here.  The last instruction of the program is a `lw` to load the final value from memory into register `$t0` and is used to verify correct functionality in the test bench (see below). If you add a similar line to your own program it will make testing easier. .

### Architecture Case Study

For the lab this week you are also expected to perform a simple case study. It is meant to show
how important understanding a computer's architecture is, and the compiler is when developing
efficient code. For this study, you are to compare and analyze the execution time of the two
programs given [here](./case_study.tar.gz). You should run a number of experiments varying the input size from 100
to 30,000. Based on the results you are to write a report of your findings. The report should
contain a graph of your data and a useful analysis of it. You should draw conclusions based on
your findings. Reports that simply restate what is in the graph will not get credit. To make it
clear, make sure you used the concepts you have learned so far in 161 and 161L when
explaining the differences in performance. If a confusing or fuzzy explanation is given you will
get low or no marks. The report should be a part of REPORT.md.

### Producing the Waveform

Once you've synthesized the code for the test-bench and the `aluControlUnit` and `controlUnit` modules, you can run
the test-bench simulation script to make sure all the tests pass. This simluation run should
produce the code to make a waveform. Use techniques you learned in the first lab to produce a
waveform for this lab and save it as a PNG. 

You don't need to add a marker this time. Also, I've provided a .gtkw.

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
