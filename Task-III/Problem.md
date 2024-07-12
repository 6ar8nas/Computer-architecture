# Task 3

Implement a step-by-step interrupt processing procedure on the i8086 microprocessor that recognizes INC r/m and DEC r/m instructions. The procedure should:

1. Trigger an interrupt (INT 01h) before the execution of the INC or DEC instruction.
1. Verify that the interrupt occurred just before the execution of the INC or DEC instruction.
1. Display an alert containing all instruction details: address, opcode of the command, mnemonics and operands.