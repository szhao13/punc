//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire            clk,            // Clock
	input  wire            rst,            // Reset

	// Add more ports here
	// Input Signals from Datapath
	input [2:0] 		   cond,
	input [15:0]		   ir, 

	// Memory Controls 
	output reg 			   d_w_en,
	output reg 	   [2:0]   d_r_addr_sel,
	output reg 	   [2:0]   d_w_addr_sel,
	output reg 	   		   d_w_data_sel,

	// Register File Controls
	output reg 			   rf_w_en,
	output reg 	   [2:0]   rf_r_addr_0_sel,
	output reg 	   		   rf_r_addr_1_sel,
	output reg             rf_w_addr_sel,
	output reg 	   [2:0]   rf_w_data_sel,

	// Instruction Register Controls
	output reg             ir_ld,

	// Program Counter Controls
	output reg             pc_ld,
	output reg             pc_inc,  

	// Temporary Register Controls
	output reg 			   temp_ld,

	// Status Register Controls
	output reg 			   status_w_en,

	// ALU Input Controls
	output reg 			   alu_in_0_sel,
	output reg 	   [2:0]   alu_in_1_sel,
	output reg 	   [2:0]   alu_sel

	);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_FETCH     = 6'd0;
	localparam STATE_DECODE	   = 6'd1;
	localparam STATE_EXECUTE   = 6'd2;
	localparam STATE_EXECUTE_I = 6'd3;
	localparam STATE_ADD	   = 6'd6;
	localparam STATE_AND       = 6'd7;
	localparam STATE_BRR	   = 6'd8;
	localparam STATE_BRI	   = 6'd9;
	localparam STATE_JMP	   = 6'd10;
	localparam STATE_JSR	   = 6'd11;
	localparam STATE_JSRR	   = 6'd12;
	localparam STATE_LD	       = 6'd13;
	localparam STATE_LDI1	   = 6'd14;
	localparam STATE_LDI2	   = 6'd15;	
	localparam STATE_LDR	   = 6'd16;
	localparam STATE_LEA	   = 6'd17;
	localparam STATE_NOT	   = 6'd18;
	localparam STATE_RET	   = 6'd19;
	localparam STATE_ST 	   = 6'd20;
	localparam STATE_STI1	   = 6'd21;
	localparam STATE_STI2	   = 6'd22;
	localparam STATE_STR	   = 6'd23;
	localparam STATE_HALT	   = 6'd24;

	// State, Next State
	reg [5:0] state, next_state;

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		d_r_addr_sel    = `D_R_ADDR_SEL_PC;
		d_w_addr_sel    = 3'd0;
		d_w_en		    = 1'd0;
		rf_w_addr_sel   = 1'd0;
		rf_r_addr_0_sel = 3'd0;
		rf_r_addr_1_sel = 3'd0;
  		rf_w_data_sel   = 3'd0;
  		rf_w_en		    = 1'd0;
  		ir_ld           = 1'd0;
  		pc_ld           = 1'd0;
  		pc_inc          = 1'd0;
  		temp_ld 		= 1'd0;
  		status_w_en 	= 1'd0;
  		alu_in_0_sel    = `ALU_IN_0_SEL_RF0;
  		alu_in_1_sel    = `ALU_IN_1_SEL_RF1;

		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				d_r_addr_sel = `D_R_ADDR_SEL_PC;
				ir_ld      = 1'd1;		
			end
			STATE_DECODE: begin
				pc_inc	   = 1'd1;
			end
			STATE_EXECUTE: begin
				case (ir[`OC])
					// Add two values and write to rf, imm5 bit determines ADDI vs ADDR
					`OC_ADD: begin
						rf_r_addr_0_sel   = `RF_R_ADDR_0_SEL_SR1;				
						if (!ir[`USE_IMM5]) begin
							rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_SR2;
						end
						else begin
							alu_in_1_sel  	= `ALU_IN_1_SEL_IMM5;
						end
						rf_w_en 	  	  = 1'b1;
						rf_w_addr_sel 	  = `RF_W_ADDR_SEL_DR;
						rf_w_data_sel 	  = `RF_W_DATA_SEL_ALU;
						alu_sel		  	  = `ALU_FN_ADD;
						status_w_en 	  = 1'd1;
					end
					// Bitwise logical AND two values and Write to rf, imm5 bit determines ANDI vs ANDR
					`OC_AND: begin
						if (!ir[`USE_IMM5]) begin
							rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_SR2;	
						end
						else begin
							alu_in_1_sel 	= `ALU_IN_1_SEL_IMM5;
						end
						rf_w_en 	  	  = 1'b1;
						rf_w_data_sel 	  = `RF_W_DATA_SEL_ALU;
						alu_sel		  	  = `ALU_FN_AND; 
						status_w_en 	  = 1'd1;
					end
					// Branch to instruction in PC based on condition codes
					`OC_BR: begin
						if ((ir[`IR_N] && cond[`COND_N]) 
						|| (ir[`IR_Z] && cond[`COND_Z]) 
						|| (ir[`IR_P] && cond[`COND_P])) begin
							pc_ld = 1'b1;
         					alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
         					alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET9;
         					alu_sel 		= `ALU_FN_ADD;
         				end
         			end
         			// Jump to contents of base reg/contents of R7, for JMP/RET respectively 
	         		`OC_JMP: begin
	         			pc_ld = 1'b1;
	         			// RET instruction (special case of JMP)
	         			if (ir[`BASE_REG] == 3'b111) begin
	         				rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_REG7;
	         			end
	         			else begin
	         				rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_BASE_REG;
	         			end
	         			alu_in_0_sel 	= `ALU_IN_0_SEL_RF0;
	         			alu_sel 		= `ALU_FN_PASS;
	         		end
	    			// Doesn't work
	         		// JSR and JSRR both covered here
	         		`OC_JSR: begin
	         			// JSRR
	         			if (!ir[`IS_JSR]) begin
	         				rf_w_addr_sel 	= `RF_W_ADDR_SEL_REG7;	  
	         			    rf_w_data_sel 	= `RF_W_DATA_SEL_PC;
	         				rf_w_en			= 1'd1;
	         				pc_ld 			= 1'd1;
	         				rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_BASE_REG;
	         				alu_in_0_sel 	= `ALU_IN_0_SEL_RF0;
	         				alu_sel 		= `ALU_FN_PASS;
	         			end
	         			// JSR
	         			else begin
	         				rf_w_addr_sel 	= 3'd7;	  
	         			    rf_w_data_sel 	= `RF_W_DATA_SEL_PC;
	         				rf_w_en			= 1'd1;	         				
	         				pc_ld 			= 1'd1;
	         				alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
	         				alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET11;
	         				alu_sel 		= `ALU_FN_ADD;
	         			end

	         		end
	         		`OC_LD: begin
	         			alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
	         			alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET9;
	         			alu_sel 		= `ALU_FN_ADD;
	         			d_r_addr_sel 	= `D_R_ADDR_SEL_ALU;
	         			rf_w_data_sel 	= `RF_W_DATA_SEL_MEM;
	         			rf_w_en			= 1'd1;
	         			status_w_en 	= 1'd1;
	         		end
	         		`OC_LDI: begin
	         			alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
	         			alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET9;
	         			alu_sel 		= `ALU_FN_ADD;
	         			d_r_addr_sel 	= `D_R_ADDR_SEL_ALU;
	         			temp_ld			= 1'd1;
	         		end
	         		`OC_LDR: begin
	         			rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_BASE_REG;
	         			alu_in_0_sel 	= `ALU_IN_0_SEL_RF0;
	         			alu_in_1_sel 	= `ALU_IN_1_SEL_OFFSET6;
	         			alu_sel 		= `ALU_FN_ADD;
	         			d_r_addr_sel 	= `D_R_ADDR_SEL_ALU;
	         			rf_w_addr_sel 	= `RF_W_ADDR_SEL_DR;
	         			rf_w_data_sel 	= `RF_W_DATA_SEL_MEM;
	         			rf_w_en			= 1'd1;
	         			status_w_en 	= 1'd1;
	         		end	
	         		`OC_LEA: begin
	         			alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
	         			alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET9;
	         			alu_sel 		= `ALU_FN_ADD;
	         			rf_w_data_sel 	= `RF_W_DATA_SEL_ALU;
	         			rf_w_en 		= 1'd1;
	         			status_w_en 	= 1'd1;
	         		end         			         		
	         		// Jump to subroutine
	         		// `OC_JSR: begin
	         		// 	rf_w_data_sel = `RF_W_DATA_SEL_PC;

	         		// end
	         		`OC_NOT: begin
						if (!ir[`USE_IMM5]) begin
							rf_r_addr_1_sel = `RF_R_ADDR_1_SEL_SR2;	
						end
						else begin
							alu_in_1_sel 	= `ALU_IN_1_SEL_IMM5;
						end
						rf_w_en 	  	= 1'd1;
						rf_w_data_sel 	= `RF_W_DATA_SEL_ALU;
						alu_sel			= `ALU_FN_NOT;
					end	
					`OC_ST: begin
						rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_SR;
						alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
						alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET9;
						alu_sel 		= `ALU_FN_ADD;
						d_w_addr_sel	= `D_W_ADDR_SEL_ALU;
						d_w_data_sel 	= `D_W_DATA_SEL_RF0;
						d_w_en			= 1'd1;
					end
					`OC_STI: begin
						alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
						alu_in_1_sel 	= `ALU_IN_1_SEL_PCOFFSET9;
						alu_sel 		= `ALU_FN_ADD;
						d_r_addr_sel	= `D_R_ADDR_SEL_ALU;
						temp_ld 		= 1'd1;
					end 
					`OC_STR: begin
						rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_SR;
						alu_in_0_sel 	= `ALU_IN_0_SEL_PC;
						alu_in_1_sel 	= `ALU_IN_1_SEL_OFFSET6;
						alu_sel 		= `ALU_FN_ADD;
						d_w_addr_sel 	= `D_W_ADDR_SEL_ALU;
						d_w_data_sel 	= `D_W_DATA_SEL_RF0;
						d_w_en 			= 1'd1;
					end
	         		`OC_HLT: begin

	         		end
	         		default: begin

	         		end
	         	endcase
	    	end
	    	STATE_EXECUTE_I: begin
	    		case (ir[`OC])
	    			`OC_LDI: begin	
	         			d_r_addr_sel 	= `D_R_ADDR_SEL_TEMP;
	         			rf_w_data_sel 	= `RF_W_DATA_SEL_MEM;
	         			rf_w_addr_sel 	= `RF_W_ADDR_SEL_DR;
	         			rf_w_en			= 1'd1;
						status_w_en 	= 1'd1;
	    			end
	    			`OC_STI: begin
	    				rf_r_addr_0_sel = `RF_R_ADDR_0_SEL_SR;
	    				alu_in_0_sel 	= `ALU_IN_0_SEL_RF0;
	    				alu_sel 		= `ALU_FN_PASS;
	    				d_w_addr_sel 	= `D_W_ADDR_SEL_TEMP;
	    				d_w_data_sel 	= `D_W_DATA_SEL_RF0;
	    				d_w_en 			= 1'd1;
	    			end
	    		endcase
	    		
	        end
	    endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = state;

		// Add your next-state logic here
		case (state)
			STATE_FETCH: begin
				next_state = STATE_DECODE;
			end
			STATE_DECODE: begin
				next_state = STATE_EXECUTE;
			end	
			STATE_EXECUTE: begin
				if (ir[`OC] == `OC_LDI || ir[`OC] == `OC_STI) begin
					next_state = STATE_EXECUTE_I;
			end
			else if (ir[`OC] == `OC_HLT) begin
				next_state = STATE_EXECUTE;
			end
			else begin
				next_state = STATE_FETCH;
			end
		end
		STATE_EXECUTE_I: begin
			next_state = STATE_FETCH;
		end
	endcase
end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Add your initial state here
			state <= STATE_FETCH;
		end
		else begin
			// Add your next state here
			state <= next_state;
		end
	end

endmodule
