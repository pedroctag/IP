# RV32IFC RISC-V Project

This project consists of a partial implementation of a RISC-V processor core, with support for the F (Single-Precision Floating-Point) and C (Compressed instructions) ISA extentions.
In addition to the RTL implementation, this repository also contains the logic synthesis, STA and UVM verification enviroments developed for the project.\
The following tools were used for RTL design and simulation:
- VS Code;
- TerosHDL;
- Cadence Xcelium;
- ModelSim.

Cadence Genus wes used for logic synthesis.\
The UVM enviroment was developed using:
- VS Code;
- Spike;
- Windows Subsystem for Linux (required for Windows);
- Cadence Xcelium;
- ModelSim.

## General enviroment configuration

Most of the RTL was written in Verilog using VS Code with the TerosHDL extension configured to work with ModelSim or Cadence Xcelium. One of the development machines had access to the Cadence toolchain, while the other did not. Nevertheless, most of the project can be verified using the free version of ModelSim. This combo made easy to test the individual modules with an integrated enviroment using common testbenches. To set up TerosHDL, follow the officcial documentation:\
https://terostechnology.github.io/terosHDLdoc/docs/category/installation-checklist.

The UVM enviroment requires additional setup, mainly for the golden sequence generation. Since the primary development enviroment was Windows, the first requirement was to install Windows Subsystem fo Linux installed. After that, install RISC-V GNU Toolchain and Spike  by following the installation guides:
- RISC-V GNU Toolchain: https://github.com/riscv-collab/riscv-gnu-toolchain
- Spike: https://github.com/riscv-software-src/riscv-isa-sim

Additional installation instructions for tools such as ModelSim are widely available online and are therefore not covered in this document.

## Architecture

The architecture consists of a five-stage pipeline (Fetch, Decode, Execute, Memory and Writeback). The following figure ilustrates the processor architecture.
<img width="1272" height="692" alt="image" src="https://github.com/user-attachments/assets/f8c13fb2-4d35-478d-ad89-5bfb599ce295" />

The data memory is a 32-bit, byte addressable memory, while the instruction memory is organized as a 32-bit aligned memory. To support compressed instructions, a bypass path allows the next instruction to be accessed in advance, in this way, the architecture can determine whether the next instruction is compressed, allowing the instruction to be decoded correctly and increment the program counter by 2 bytes or 4 bytes. Although the implementation does not include a dedicated prefetch buffer, the bypass path provides the same functionality without introducing an additional pipeline stage or an extra cycle of latency. As a result, the instruction memory behaves as a 16-bit aligned memory while remaining physically organized as a 32-bit word-aligned memory.being organized as a 32-bit memory.

### Fetch
This stage fetches the next instruction to be executed. The muxes and adders are used to handle branches, jumps and compressed instructions. The Cflag module reads the two least significant bits of the instruction and sets the isCompressed flag if those bits are different from 2'b11.
### Decode
This stage generates the control signals to the rest for the pipeline, making sure that the data follows the correct path, it also contains the register files for integer and floating-point source and destination registers. The Instruction Align and Decompressor handle the compressed instructions, the instruction align module aligns the instruction, if it is not aligned (compressed instructions may not be 32-bit aligned), while the decompressor decodes the compressed instruction to an equivalent 32-bit RISC-V instruction.
### Execute
This stage executes the instruction, it contains the ALU and FPU, that can do operations with values from the register files or immediate values encoded in the instruction. This stage also contains the branch unit, that handle the branch flag in respect of the instruction being executed and the result of the ALU.
### Memory
This stage performs data memory access for the store and load operations.
### Writeback
This stage uses one mux and the controls signals for the writeback in the register files, wich marks the end of the pipeline and, therefore the end of the instruction.

In addition of the stages, the processor includes a Hazard Unit for Read After Write(RAW) hazards. It monitors the destination register (Rd), both source registers (Rs) and Write Enable signals between stages. When a hazard is detected, the unit makes the appropriate correction, beeing a stall, a forward or a flush.

## Synthesis and STA

## UVM and Testing



This is the final project for CI-Digital, a specialization course coordenated by Softex and executed by Inatel, UNIFEI, Institute HBR, UEMA and CEPEDI.
