---
name: "ram"
description: "Basic 64 Byte RAM component built from single bit logic gates to understand how memory works internally."
tags: ["ram", "memory", "logic-gates", "computer-architecture", "hardware"]
heroImage: "/src/assets/projects/ram.webp"
---

# Basic 64 Byte RAM Component

I like having many tabs open. Was wondering how RAM works internally. I like to learn by doing so I have a naive (emulated) hardware implementation.

This project was built in the same spirit as the [8Bit CPU](/projects/8bit-cpu) project - understanding computer fundamentals by building them from first principles using single bit logic gates.

The result is a functional 64 byte RAM module constructed entirely from basic logic components, demonstrating the core concepts of memory addressing, data storage, and retrieval at the hardware level.

More info on [Reddit](https://www.reddit.com/r/TuringComplete/comments/1mvqjvt/64bytes_of_ram_made_of_1bit_logic_gates/).

## Key Concepts

- Memory addressing and decoding
- Data storage using latches
- Read and write operations
- Built entirely from single bit logic gates
- No higher level abstractions

## Architecture Images

### RAM Overview
![Complete 64 byte RAM module showing all components](../../assets/projects/8-bit-cpu/ram_overview.webp)

### Memory Cells Close Up
![Individual memory cells built from latches](../../assets/projects/8-bit-cpu/ram_close_up_memory_cells.webp)

### Row and Column Switching Logic
![Address decoding and row/column selection logic](../../assets/projects/8-bit-cpu/ram_row_col_switching_logic.webp)
