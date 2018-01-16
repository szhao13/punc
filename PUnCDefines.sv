//==============================================================================
// Global Defines for Six-Instruction Programmable Processor
//==============================================================================

//------------------------------------------------------------------------------
// Control Signals
//------------------------------------------------------------------------------

// Register File
`define RF_R_ADDR_0_SEL_A 	 1'b0
`define RF_RP_ADDR_0_SEL_B	 1'b1

// changed
// Data Block
`define RF_W_DATA_SEL_PC     2'b11
`define RF_W_DATA_SEL_MEM    2'b10
`define RF_W_DATA_SEL_ALU    2'b01
`define RF_W_DATA_SEL_TEMP   2'b00
`define RF_R_DATA_0_SEL		 1'b1
`define RF_R_DATA_1_SEL		 1'b0

// changed
// ALU		 
`define ALU_FN_PASS          2'b00
`define ALU_FN_ADD           2'b01
`define ALU_FN_AND			 2'b10
`define ALU_FN_NOT			 2'b11

// PC IR Adder // changed
`define PC_IR_PASS_PC		 2'b10
`define PC_IR_PASS_IR		 2'b01
`define PC_IR_ADD			 2'b11

// Data Block Read Address // changed
`define D_R_ADDR_0_SEL_LOOP  1'b0
`define D_R_ADDR_0_SEL_NEXT  1'b1
//------------------------------------------------------------------------------
// Opcodes
//------------------------------------------------------------------------------
`define OC 15:12

// `define OC_LOAD 	4'b0000
// `define OC_STORE 	4'b1001
`define OC_ADD 		4'b0001
`define OC_AND		4'b0101
`define OC_BR		4'b0000
`define OC_JMP		4'b1100
`define OC_JSR		4'b0100
`define OC_JSRR		4'b0100
`define OC_LD		4'b0010
`define OC_LDI		4'b1010
`define OC_LDR		4'b0110
`define OC_LEA		4'b1110
`define OC_NOT		4'b1001
`define OC_RET		4'b1100
`define OC_RTI		4'b1000
`define OC_ST		4'b0011
`define OC_STI		4'b1011
`define OC_STR		4'b0111
`define OC_HALT		4'b1111


`define REG_A			11:9
`define REG_B			8:6
`define USE_IMM5    	5
`define REG_C			3:0
`define BASE_R			8:6
`define COND_N			11
`define COND_Z			10
`define COND_P			9
`define PC_OFFSET_11 	10:0
`define PC_OFFSET_9		8:0
`define OFFSET_6 		5:0
`define IMM5 	    	4:0
`define IMM5_SIGN		4
