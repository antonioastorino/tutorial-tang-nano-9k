// Register file definitions

// Register width
`define REG_WIDTH      32

// Number of registers
`define REG_COUNT      32

// Address width (log2 of REG_COUNT)
`define REG_ADDR_WIDTH 5

// ABI register names -- conventional names used in assembly and toolchains
`define REG_ZERO 5'd0   // x0  - hardwired zero
`define REG_RA   5'd1   // x1  - return address
`define REG_SP   5'd2   // x2  - stack pointer
`define REG_GP   5'd3   // x3  - global pointer
`define REG_TP   5'd4   // x4  - thread pointer
`define REG_T0   5'd5   // x5  - temporary / alternate link register
`define REG_T1   5'd6   // x6  - temporary
`define REG_T2   5'd7   // x7  - temporary
`define REG_S0   5'd8   // x8  - saved register / frame pointer (FP)
`define REG_S1   5'd9   // x9  - saved register
`define REG_A0   5'd10  // x10 - function argument / return value
`define REG_A1   5'd11  // x11 - function argument / return value
`define REG_A2   5'd12  // x12 - function argument
`define REG_A3   5'd13  // x13 - function argument
`define REG_A4   5'd14  // x14 - function argument
`define REG_A5   5'd15  // x15 - function argument
`define REG_A6   5'd16  // x16 - function argument
`define REG_A7   5'd17  // x17 - function argument
`define REG_S2   5'd18  // x18 - saved register
`define REG_S3   5'd19  // x19 - saved register
`define REG_S4   5'd20  // x20 - saved register
`define REG_S5   5'd21  // x21 - saved register
`define REG_S6   5'd22  // x22 - saved register
`define REG_S7   5'd23  // x23 - saved register
`define REG_S8   5'd24  // x24 - saved register
`define REG_S9   5'd25  // x25 - saved register
`define REG_S10  5'd26  // x26 - saved register
`define REG_S11  5'd27  // x27 - saved register
`define REG_T3   5'd28  // x28 - temporary
`define REG_T4   5'd29  // x29 - temporary
`define REG_T5   5'd30  // x30 - temporary
`define REG_T6   5'd31  // x31 - temporary
