# arm cpu

## Support Instructions

### Data Processing

* *Opcode* Rd, Rn, Src2
  * AND, SUB, ADD, ORR
* *Opcode* Rn, Src2
  * CMP, TST
* *Opcode* Rd, Rm, Rs/shamt5
  * LSL

### Memory

* *Opcode* Rd, [Rn]
  * STR, LDR

### Branch

* *Opcode* label
  * B

## Tables

### Main Decoder

| $Op$  | $Funct_5$ | $Funct_0$ | $\rm{Type}$ |       | $Branch$ | $MemtoReg$ | $MemW$ | $ALUSrc$ | $ImmSrc$ | $RegW$ | $RegSrc$ | $ALUOp$ |
| :---: | :-------: | :-------: | :---------: | :---: | :------: | :--------: | :----: | :------: | :------: | :----: | :------: | :-----: |
|  00   |     0     |     X     |    DPReg    |       |    0     |     0      |   0    |    0     |    XX    |   1    |    00    |    1    |
|  00   |     1     |     X     |    DPImm    |       |    0     |     0      |   0    |    1     |    00    |   1    |    X0    |    1    |
|  01   |     X     |     0     |     STR     |       |    0     |     X      |   1    |    1     |    01    |   0    |    10    |    0    |
|  01   |     X     |     1     |     LDR     |       |    0     |     1      |   0    |    1     |    01    |   1    |    X0    |    0    |
|  10   |     X     |     X     |      B      |       |    1     |     0      |   0    |    1     |    10    |   0    |    X1    |    0    |

### ALU Decoder

| $ALUOp$ | $Funct_{4:1} \rm{(cmd)}$ | $Funct_0 \rm{(S)}$ | $\rm{Type}$ |     | $ALUControl_{1:0}$ | $FlagW_{1:0}$ | $NoWrite$ | $Shift$ |
| :-----: | :----------------------: | :----------------: | :---------: | --- | :----------------: | :-----------: | :-------: | :-----: |
|    0    |            X             |         X          |    NotDP    |     |         00         |      00       |     0     |    0    |
|    1    |           0100           |         0          |     ADD     |     |         00         |      00       |     0     |    0    |
|    ^    |            ^             |         1          |      ^      |     |         ^          |      11       |     0     |    0    |
|    ^    |           0010           |         0          |     SUB     |     |         01         |      00       |     0     |    0    |
|    ^    |            ^             |         1          |      ^      |     |         ^          |      11       |     0     |    0    |
|    ^    |           0000           |         0          |     AND     |     |         10         |      00       |     0     |    0    |
|    ^    |            ^             |         1          |      ^      |     |         ^          |      10       |     0     |    0    |
|    ^    |           1100           |         0          |     ORR     |     |         11         |      00       |     0     |    0    |
|    ^    |            ^             |         1          |      ^      |     |         ^          |      10       |     0     |    0    |
|    ^    |           1010           |         1          |     CMP     |     |         01         |      11       |     1     |    0    |
|    ^    |           1000           |         1          |     TST     |     |         10         |      10       |     1     |    0    |
|    ^    |           1101           |         0          |     LSL     |     |         XX         |      00       |     0     |    1    |
|    ^    |            ^             |         1          |      ^      |     |         ^          |      10       |     0     |    1    |
