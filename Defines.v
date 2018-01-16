//==============================================================================
// Global Defines for PUnC LC3 Computer
//==============================================================================

// Add defines here that you'll use in both the datapath and the controller

//------------------------------------------------------------------------------
// Opcodes
//------------------------------------------------------------------------------
`define OC 15:12       // Used to select opcode bits from the IR

`define OC_ADD 4'b0001 // Instruction-specific opcodes
`define OC_AND 4'b0101
`define OC_BR  4'b0000
`define OC_JMP 4'b1100
`define OC_JSR 4'b0100
`define OC_LD  4'b0010
`define OC_LDI 4'b1010
`define OC_LDR 4'b0110
`define OC_LEA 4'b1110
`define OC_NOT 4'b1001
`define OC_ST  4'b0011
`define OC_STI 4'b1011
`define OC_STR 4'b0111
`define OC_HLT 4'b1111

`define USE_IMM5 5'd5  // Bit for distinguishing ADDR/ADDI and ANDR/ANDI
`define IS_JSR   5'd11 // Bit for distinguishing JSR/JSRR

// Status Register Constants
`define IR_N 5'd11        // Location of special bits in BR instruction
`define IR_Z 5'd10
`define IR_P 5'd9
// Condition Signal Constants
`define COND_N 2'd2
`define COND_Z 2'd1
`define COND_P 2'd0

// Memory Control Constants
`define D_R_ADDR_SEL_PC			2'b00
`define D_R_ADDR_SEL_ALU	  	2'b01
`define D_R_ADDR_SEL_TEMP  		2'b10
`define D_R_ADDR_SEL_MEM		2'b11

`define D_W_ADDR_SEL_PC  		2'b00
`define D_W_ADDR_SEL_ALU	  	2'b01
`define D_W_ADDR_SEL_TEMP  		2'b10
`define D_W_ADDR_SEL_MEM		2'b11

`define D_W_DATA_SEL_ALU		2'b00
`define D_W_DATA_SEL_RF0		2'b01
`define D_W_DATA_SEL_BASE_REG 	2'b11

// Register File Control Constants
`define RF_W_DATA_SEL_ALU		2'b00
`define RF_W_DATA_SEL_PC		2'b01
`define RF_W_DATA_SEL_MEM		2'b10

`define RF_R_ADDR_0_SEL_BASE_REG 2'b00
`define RF_R_ADDR_0_SEL_SR 		 2'b01
`define RF_R_ADDR_0_SEL_SR1		 2'b10
`define RF_R_ADDR_0_SEL_REG7	 2'b11

`define RF_R_ADDR_1_SEL_SR1		 2'b00
`define RF_R_ADDR_1_SEL_SR2		 2'b01

`define RF_W_ADDR_SEL_DR		 2'b00 // necessary?
`define RF_W_ADDR_SEL_REG7 		 2'b01

// ALU Input Control Constants
`define ALU_IN_0_SEL_RF0	     1'b0
`define ALU_IN_0_SEL_PC		     1'b1
`define ALU_IN_1_SEL_RF1	     3'b000
`define ALU_IN_1_SEL_IMM5	     3'b001
`define ALU_IN_1_SEL_OFFSET6	 3'b010
`define ALU_IN_1_SEL_PCOFFSET9	 3'b011
`define ALU_IN_1_SEL_PCOFFSET11	 3'b100

`define ALU_FN_ADD		3'b000
`define ALU_FN_SUBTR  	3'b001
`define ALU_FN_AND  	3'b010
`define ALU_FN_NOT  	3'b011
`define ALU_FN_PASS  	3'b100


`define BASE_REG    8:6
`define DR		   11:9
`define SR 		   11:9
`define SR1		    8:6
`define SR2		    2:0
`define PCOFFSET9   8:0
`define PCOFFSET11 10:0
`define OFFSET6	    5:0
`define IMM5 		4:0
`define IMM5_SIGN   4
