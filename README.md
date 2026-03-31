# Design and Verification of Synchronous FIFO using SystemVerilog

## Project Overview

This project implements a parameterized synchronous FIFO (First-In-First-Out) buffer using SystemVerilog.

The FIFO is designed using modular RTL architecture and verified through a structured testbench environment including generator, driver, monitor, and scoreboard.

The design supports safe data transfer between producer and consumer modules while preserving data order and preventing overflow/underflow conditions.

---

## Why FIFO is Important

Without FIFO:

* A fast producer can overflow a slow consumer
* A slow producer can starve a fast consumer

FIFO solves this by acting as an intermediate temporary storage buffer.

---

## Features

* Parameterized Data Width
* Parameterized FIFO Depth
* Full Flag
* Empty Flag
* Almost Full Flag
* Almost Empty Flag
* Overflow Detection
* Underflow Detection
* Simultaneous Read/Write Support

---

## FIFO Architecture

Modules used:

* fifo_top.sv → top integration
* fifo_ctrl.sv → control logic
* fifo_mem.sv → memory block
* fifo_tb.sv → testbench

Architecture:

Write Pointer → Memory → Read Pointer

Control logic handles:

* count management
* pointer increment
* status flag generation

---

## Verification Architecture

Verification components:

* Generator
* Driver
* Monitor
* Scoreboard

Flow:

Generator → Driver → DUT → Monitor → Scoreboard

Scoreboard compares expected data with actual FIFO output.

---

## Simulation Results

Verified scenarios:

* Normal Write Operation
* Normal Read Operation
* Simultaneous Read/Write
* Full Condition
* Empty Condition
* Overflow Protection
* Underflow Protection

Waveforms confirm FIFO maintains correct data sequence.

---

## Synthesis Results

Tool: Xilinx Vivado

Results:

* LUT Usage: Low
* Register Usage: Low
* Timing Violations: None
* FPGA Friendly Lightweight Design

---

## Tools Used

* SystemVerilog
* Xilinx Vivado
* Vivado Simulator

---

## Folder Structure

```bash
FIFO_Project/
│── rtl/
│   ├── fifo_top.sv
│   ├── fifo_ctrl.sv
│   ├── fifo_mem.sv
│
│── tb/
│   ├── fifo_tb.sv
│
│── docs
│	 ├── FIFO_report
│── results/
│   ├── rtl_schematics.png
│   ├── scoreboard_log.png
│	 ├── timing_report.png
│   ├── underflow.png
|   ├── utilization_report.png
│   ├── waveform.png
│── README.md
```

---

## Future Scope

* Asynchronous FIFO
* AXI FIFO
* Dual Clock FIFO
* UVM Verification
* Assertion-Based Verification

---

## Author

Mohammad Rehan

B.Tech ECE
NIT Mizoram
