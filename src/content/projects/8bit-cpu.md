---
name: "8bit-cpu"
description: "A minimal abstraction 8Bit CPU built entirely from single bit logic gates to understand computer architecture from first principles."
tags: ["cpu", "logic-gates", "computer-architecture", "education", "hardware"]
heroImage: "/src/assets/projects/8bit-cpu.webp"
---

# Minimal Abstraction 8Bit CPU

This project was sparked by the university courses INCO Information Theory and Encodings and GED Basics of Electrical and Digital Technology. They triggered a strong interest in low level systems and computer architecture.

A friend recommended the game [Turing Complete](https://store.steampowered.com/app/1444480/Turing_Complete/), which acts as an educational CPU design environment. Instead of providing explicit instructions, it forces you to derive solutions from truth tables and first principles. Concepts like opcodes, instruction decoding and control logic are introduced gradually and implicitly.

The game encourages the use of custom components. For example, once a half adder is built, it can be abstracted and reused instead of manually placing the same logic gates again. While this is practical, I deliberately avoided most abstraction.

My goal was to design a CPU where all inner workings are visible at once. The emulator does not support inlining components, so every single bit level component was placed and wired manually. This took several dozen hours.

The result is a fully functional 8Bit CPU architecture called OVERTURE within TC. It is a predecessor to the more advanced LEG which mainly differs in the size of the instructions.

Emulation performance is predictably poor, as the game cannot apply meaningful shortcuts, but the design fulfills the original goal of maximum transparency.

Because everything is built from single bit components, the design could theoretically be translated into real hardware or even implemented in Minecraft redstone.

## Architecture Highlights

- 8Bit registers built from individual latches
- Custom opcode decoding and control logic
- Boolean and arithmetic ALU operations
- Dedicated program counter and instruction flow control
- Fully manual wiring without higher level abstraction

## Architecture Images

### Register Close Up
![8Bit register built from individual latches](../../assets/projects/8-bit-cpu/cpu_register_closeup.webp)

### Architecture Overview
![Complete OVERTURE CPU architecture showing all components](../../assets/projects/8-bit-cpu/cpu_architecture_overview.webp)

### Adder and Inverter Circuit
![Custom adder and inverter logic circuits](../../assets/projects/8-bit-cpu/cpu_adder_invertor_circuit.webp)

### Opcode and Logic Unit
![Opcode decoding and control logic unit](../../assets/projects/8-bit-cpu/cpu_opcode_logic_unit.webp)

### ALU Boolean Operations
![Arithmetic Logic Unit performing boolean operations](../../assets/projects/8-bit-cpu/cpu_alu_boolean.webp)

### Program Counter
![Program counter and instruction flow control](../../assets/projects/8-bit-cpu/cpu_program_counter.webp)
