# RV32IFC RISC-V Project

This project consists of a partial implementation of a RISC-V processor core, with support for the F (Single-Precision Floating-Point) and C (Compressed instructions) ISA extensions.
In addition to the RTL implementation, this repository also contains the logic synthesis, STA and UVM verification environments developed for the project.\
The following tools were used for RTL design and simulation:
- VS Code;
- TerosHDL;
- Cadence Xcelium;
- ModelSim.

Cadence Genus was used for logic synthesis.\
The UVM environment was developed using:
- VS Code;
- Spike;
- Windows Subsystem for Linux (required for Windows);
- Cadence Xcelium;
- ModelSim.

## General environment configuration

Most of the RTL was written in Verilog using VS Code with the TerosHDL extension configured to work with ModelSim or Cadence Xcelium. One of the development machines had access to the Cadence toolchain, while the other did not. Nevertheless, most of the project can be verified using the free version of ModelSim. This setup made it easy to test the individual modules with an integrated environment using common testbenches.

> [!NOTE]
> To set up TerosHDL, follow the official documentation: https://terostechnology.github.io/terosHDLdoc/docs/category/installation-checklist.

The UVM environment requires additional setup, mainly for the golden sequence generation. Since the primary development environment was Windows, the first requirement was to install Windows Subsystem for Linux. After that, install RISC-V GNU Toolchain and Spike

>[!NOTE]
> To set up both tools, follow the installation guides:
> - RISC-V GNU Toolchain: https://github.com/riscv-collab/riscv-gnu-toolchain
> - Spike: https://github.com/riscv-software-src/riscv-isa-sim

Additional installation instructions for tools such as ModelSim are widely available online and are therefore not covered in this document.

## Architecture

The architecture consists of a five-stage pipeline (Fetch, Decode, Execute, Memory and Writeback). The following figure illustrates the processor architecture.
<img width="1272" height="692" alt="image" src="https://github.com/user-attachments/assets/f8c13fb2-4d35-478d-ad89-5bfb599ce295" />

The data memory is a 32-bit, byte addressable memory, while the instruction memory is organized as a 32-bit aligned memory. To support compressed instructions, a bypass path allows the next instruction to be accessed in advance, in this way, the architecture can determine whether the next instruction is compressed, allowing the instruction to be decoded correctly and increment the program counter by 2 bytes or 4 bytes. Although the implementation does not include a dedicated prefetch buffer, the bypass path provides the same functionality without introducing an additional pipeline stage or an extra cycle of latency. As a result, the instruction memory behaves as a 16-bit aligned memory while remaining physically organized as a 32-bit word-aligned memory.

### Fetch
This stage fetches the next instruction to be executed. The muxes and adders are used to handle branches, jumps and compressed instructions. The Cflag module reads the two least significant bits of the instruction and sets the isCompressed flag if those bits are different from 2'b11.
### Decode
This stage generates the control signals for the rest of the pipeline, making sure that the data follows the correct path, it also contains the register files for integer and floating-point source and destination registers. The Instruction Align and Decompressor handle the compressed instructions, the Instruction Align module aligns the instruction, if it is not aligned (compressed instructions may not be 32-bit aligned), while the decompressor decodes the compressed instruction to an equivalent 32-bit RISC-V instruction.
### Execute
This stage executes the instruction, it contains the ALU and FPU, that can perform operations with values from the register files or immediate values encoded in the instruction. This stage also contains the branch unit, that handles the branch flag based on the instruction being executed and the result of the ALU.
### Memory
This stage performs data memory access for the store and load operations.
### Writeback
This stage uses one mux and the control signals for the writeback in the register files, which marks the end of the pipeline and, therefore, the end of the instruction.

In addition to the pipeline stages, the processor includes a Hazard Unit for Read After Write (RAW) hazards. It monitors the destination register (Rd), both source registers (Rs) and Write Enable signals between stages. When a hazard is detected, the unit makes the appropriate correction, being a stall, a forwarding or a flush.

### Testbench
The testbench consists of a loading stage and an execution stage. Since no IP is used in the design, the instruction memory has an unusual asynchronous write operation. The right way to run the testbench is to keep the reset and the write-enable signals asserted while the instructions are placed on the data input bus, this is achieved with a "for" loop. After that stage, the reset and write-enable are deasserted and execution begins. One unfortunate effect of that approach is that the gate-level simulation cannot load the instructions. The reason for this behavior is that, in the transition from one instruction to the next, the rapid changes in the state of the bus corrupt the data being written. Changing the write-enable along with the clock signal also is not possible, since the simulator enters an infinite loop once the signal changes state.

 **Test Run**
 
 The assembly program used for to test the testbench is shown below:
```assembly
c.li        x5, 17
c.slli      x5, 12
addi        x5, x5, 2000
addi        x5, x5, 458
c.li        x6, 5
c.slli      x6, 15
lui         x7, 1048516
lui         x8, 66
fcvt.s.w    f1, x5
fcvt.s.w    f2, x6
fcvt.s.w    f3, x7
fcvt.s.w    f4, x8
lui         x10, 227328
addi        x10, x10, 0x74
fmv.w.x     f9, x10
fmul.s      f1, f1, f9
fmul.s      f2, f2, f9
fmul.s      f3, f3, f9
fmul.s      f4, f4, f9
fadd.s      f5, f1, f2
fadd.s      f6, f5, f3
fadd.s      f7, f6, f4
fsw         f7, 0(x31)
fcvt.w.s    x9, f7
sw          x9, 4(x31)
end:
beq         x0, x0, end
```

The screenshot results for RFX, RFF and data memory contents are shown below

<img width="792" height="282" alt="image" src="https://github.com/user-attachments/assets/4abeb13b-dd32-4fbe-81e9-f575ed29d48e" />
<img width="792" height="354" alt="image" src="https://github.com/user-attachments/assets/2a6ed709-adb3-4ab0-956b-81fe21809529" />
<img width="412" height="279" alt="image" src="https://github.com/user-attachments/assets/3b849df6-bd26-4370-8821-09e931d629ef" />

## Synthesis and STA

The design was synthesized using Cadence Genus under three different scenarios:
- Baseline: 33 MHz;
- PPA1: 50 MHz;
- PPA2: 100 MHz.
  
The timing constraints used during synthesis are:

|Parameter|Setup uncertainty|Transition|Source Latency|Net Latency|Input Delay|Output Delay|Output Load|Min. Input Transition|Max. Output Transition|
|---------|-----------------|----------|--------------|------------|----------|------------|-----------|---------------------|----------------------|
|Value|10%|10%|5%|3%|30%|30%|0.04pF|1%|10%|

> [!NOTE]
> All the reports with the results for area, timing, power and QoR, as well as netlists, SDF and SDC files are available in the SYNTHESIS/Sim directory.

### Results
||Baseline|PPA1|PPA2|
|-|-|-|-|
|Slack|6440.1 ps|1016.7 ps|14.6 ps|
|Area|315,991.926 µm²|316,312.448 µm²|317,246.519 µm²|
|Power|0.804 mW|0.934 mW|1.976 mW|

The critical path reported by Cadence Genus is shown below:
<img width="1198" height="553" alt="image" src="https://github.com/user-attachments/assets/1f112681-c670-43fa-a8ca-8b2593d6c961" />

The critical path starts at the RdM signal, which is an input to the Hazard Unit. Inside this module, the forwarding logic determines the control signals for the multiplexers. Once the multiplexers have settled, the critical path follows the main data path all the way to the input multiplexer of the PC register.

## UVM and Testing

> [!IMPORTANT]
> All the scripts and files use paths relative to the development machines, to use the tools provided in this project, all paths must be updated.

The UVM was developed in two stages, one using ModelSim, the other, Cadence Xcelium. Each simulator was used for a different pourpose.
The free version of ModelSim does not support randomization, coverage and assertions, as a result, the functional coverage was collected using Cadence Xcelium (which was available to me) and the ModelSim stage was responsible for comparing the design against the Spike simulator.

The Spike simulator was installed in Ubuntu running under WSL on Windows, to run the test, the assembly code is compiled into a .elf executable with the RISC-V GNU toolchain and then this ELF is hexdumped into a .txt. The .elf is then loaded into the Spike simulator, logging the results of the run. This log is simplified, and it is used as one of the inputs to the UVM environment. The other input is the .txt created with the hexdump.
This text file contains the instructions executed in the simulator that are loaded, line by line into the instruction memory of the design. After that, the run phase releases the reset signal and the processor core executes the loaded program. Every time a Write Enable (from memory or register file) is asserted, the UVM scoreboard compares the values produced by the design against the values produced by the Spike simulator. At the end, the matches and mismatches are counted and a result is shown.

For the functional coverage analysis, all instructions from the assembly program, together with 1,023 randomly generated instructions with valid opcodes, were loaded and executed. Covergroups were used to measure the coverage of control signals, hazard logic, branch logic, registers, and opcodes.

> [!NOTE]
> The Bash script to run the compilation process, the hexdump, the Spike simulation and the Python script to simplify the Spike log can be found in the Script directory. These files were originally on Ubuntu.

> [!IMPORTANT]
> There are two tb directories (tb and tb_). Each one is used with a different simulation software, the tb (without the underscore) is used in Cadence Xcelium and won't work with the free version of ModelSim. The tb_ (with the underscore) works with the free version of ModelSim, but, the coverage test is not included. Originally the porject is set to work with Cadence Xcelium, to use the free version of ModelSim the directory must be renamed (the tb_ needs to be changed to tb) and the line containing the checker.sv in the file files.f must be commented.

### Results
**Golden Model**
|Executed Instructions | Matches | Mismatches | Success Rate |
|-|-|-|-|
|363|356|7|98.07%|

The mismatches here were caused by the difference between the design and the simulator addresses. The RTL data memory is truncated in 16 address bits, while the simulator uses 32, with the data starting in 0x80000000, which is a problem with instructions like JAL (the loaded memory address does not match the simulator). This can be verified with the following lines from the transcript file:
```log
scoreboard [FAIL] 347 Expected: Reg x30=0x800004ea | Returned: Reg x30=0x4ea
scoreboard [FAIL] 349 Expected: Reg x30=0x800004ee | Returned: Reg x30=0x4ee
scoreboard [FAIL] 351 Expected: Reg x31=0x80000508 | Returned: Reg x31=0x508
scoreboard [FAIL] 352 Expected: Reg x31=0x800004f2 | Returned: Reg x31=0x4f2
scoreboard [FAIL] 359 Expected: Reg x7=0x8000052a  | Returned: Reg x7=0x52a
```
Another source of mismatch is from the F.ADD instruction. The floating-point adder does not use the last three bits during the rounding stage in order to run synthesis. As a result, a rounding difference occurs in some cases, as shown below. Note that this issue generates two mismatches because the incorrect result is subsequently stored in memory
```log
scoreboard [FAIL] 306 Expected: Reg f7=0x407e6767          | Returned: Reg f7=0x407e6768
scoreboard [FAIL] 307 Expected: RAM[0x80010000]=0x407e6767 | Returned: RAM[0x80010000]=0x407e6768
```

**Functional Coverage**

Functional coverage was obtained by executing a total of 1,353 instructions: 330 instructions from the golden model test program and an additional 1,023 randomly generated valid RISC-V instructions. Covergroups were used to measure the coverage of opcodes, register accesses, control signals, hazard logic, branch logic, and compressed instruction support.

| Category | Coverage |
|----------|---------:|
| **OVERALL SYSTEM COVERAGE** | **92.83%** |
| **INSTRUCTIONS AND REGISTERS** | **100.00%** |
| -Opcodes (R, I, S, B, U, J) | 100.00% |
| - Destination Registers (0–31) | 100.00% |
| **CONTROL SIGNALS** | **69.17%** |
| - ALU Control | 80.00% |
| - FPU Control | 16.67% |
| - Input Selectors (Imm, Result) | 80.00% |
| - Write Signals (MemWrite, RegWrite) | 100.00% |
| **BRANCHES AND FLAGS** | **100.00%** |
| - ALU Flags (Zero, Negative) | 100.00% |
| - Branch Taken | 100.00% |
| **HAZARD UNIT** | **95.00%** |
| - Basic Forwarding (A and B) | 100.00% |
| - Stalls and Flushes | 100.00% |
| - Cross Coverage: Forwarding A × B | 100.00% |
| - Cross Coverage: Stall × Forwarding | 100.00% |
| - Cross Coverage: Flush × Stall | 75.00% |
| **PREFETCH AND COMPRESSED INSTRUCTIONS** | **100.00%** |
| - Compressed Instructions | 100.00% |
| - Misaligned Fetch (PC1) | 100.00% |

## Acknowledgements

This project was developed as the final project for CI-Digital, a specialization program coordinated by Softex and delivered by Inatel, UNIFEI, Institute HBR, UEMA, and CEPEDI.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
