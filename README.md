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

The UVM environment requires additional setup, mainly for the golden sequence generation. Since the primary development environment was Windows, the first requirement was to install Windows Subsystem fo Linux. After that, install RISC-V GNU Toolchain and Spike

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
This stage generates the control signals for the rest for the pipeline, making sure that the data follows the correct path, it also contains the register files for integer and floating-point source and destination registers. The Instruction Align and Decompressor handle the compressed instructions, the Instruction Align module aligns the instruction, if it is not aligned (compressed instructions may not be 32-bit aligned), while the decompressor decodes the compressed instruction to an equivalent 32-bit RISC-V instruction.
### Execute
This stage executes the instruction, it contains the ALU and FPU, that can perform operations with values from the register files or immediate values encoded in the instruction. This stage also contains the branch unit, that handles the branch flag based on the instruction being executed and the result of the ALU.
### Memory
This stage performs data memory access for the store and load operations.
### Writeback
This stage uses one mux and the control signals for the writeback in the register files, which marks the end of the pipeline and, therefore the end of the instruction.

In addition to the pipeline stages, the processor includes a Hazard Unit for Read After Write (RAW) hazards. It monitors the destination register (Rd), both source registers (Rs) and Write Enable signals between stages. When a hazard is detected, the unit makes the appropriate correction, being a stall, a forwarding or a flush.

## Synthesis and STA

The design was synthesized using Cadence Genus under three different scenarios:
- Baseline: 33 kHz;
- PPA1: 100 kHz;
- PPA2: 150 kHz.
  
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

The UVM was developed in two stages, one using ModelSim, the other, Cadence Xcelium. Each simulator was used for a different purpose.
The free version of ModelSim does not support randomization, coverage and assertions, as a result, the functional coverage was collected using Cadence Xcelium (which was available to me) and the ModelSim stage was responsible for comparing the design against the Spike simulator.
The Spike simulator was installed in Ubuntu running under WSL on Windows, to run the test, the assembly code is compiled into an .elf executable with the RISC-V GNU toolchain and then this ELF is hexdumped into a .txt. The .elf is then loaded into the Spike simulator, logging the results of the run. This log is simplified, and it is used as one of the inputs to the UVM environment. The other input is the .txt created with the hexdump.
This text file contains the instructions executed in the simulator that are loaded, line by line into the instruction memory of the design. After that, the run phase releases the reset signal and the processor core executes the loaded program. Every time a Write Enable (from memory or register file) is asserted, the UVM scoreboard compares the values produced by the design against the values produced by the Spike simulator. At the end, the matches and mismatches are counted and a result is shown.

This is the final project for CI-Digital, a specialization course coordinated by Softex and executed by Inatel, UNIFEI, Institute HBR, UEMA and CEPEDI.
