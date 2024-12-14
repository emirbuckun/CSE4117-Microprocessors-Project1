# CSE4117-Microprocessors-Project

## Project Description

This project involves the design and implementation of a microprocessor system using SystemVerilog. The system includes a CPU, memory, dual timer, and a seven-segment display controller.

## Setup Instructions

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/CSE4117-Microprocessors-Project.git
   ```
2. Navigate to the project directory:
   ```sh
   cd CSE4117-Microprocessors-Project
   ```
3. Ensure you have the necessary tools installed (e.g., ModelSim, Quartus).

## Usage

1. Compile the SystemVerilog files using your preferred simulation tool.
2. Run the simulation to verify the functionality of the microprocessor system.
3. Modify the `program.asm` file to change the program loaded into the memory.
4. Use the `assembler.c` to convert the assembly code into machine code and update `ram.dat`.

## File Descriptions

- `src/seven_segment_display.sv`: Module for controlling the seven-segment display.
- `src/ram.dat`: Memory initialization file.
- `src/program.asm`: Assembly code for the microprocessor.
- `src/main.sv`: Top-level module integrating all components.
- `src/dual_timer.sv`: Module for generating 1-second and 5-second pulses.
- `src/bird_cpu.sv`: CPU module implementing the microprocessor.
- `src/assembler.c`: C program to assemble the assembly code into machine code.
