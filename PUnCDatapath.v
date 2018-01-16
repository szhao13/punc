//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

module PUnCDatapath(
   // External Inputs
   input  wire        clk,            // Clock
   input  wire        rst,            // Reset

   // DEBUG Signals
   input  wire [15:0] mem_debug_addr,
   input  wire  [2:0] rf_debug_addr,
   output wire [15:0] mem_debug_data,
   output wire [15:0] rf_debug_data,
   output wire [15:0] pc_debug_data,

   // Add more ports here
   // Memory Controls
   input  wire        d_w_en,
   input  wire  [2:0] d_r_addr_sel,
   input  wire  [2:0] d_w_addr_sel,
   input  wire  	  d_w_data_sel,

   // Register File Controls
   input  wire        rf_w_en,
   input  wire  [2:0] rf_r_addr_0_sel,
   input  wire  	  rf_r_addr_1_sel,
   input  wire  	  rf_w_addr_sel,
   input  wire  [2:0] rf_w_data_sel,

   // Instruction Register Controls
   input  wire        ir_ld,

   // Program Counter Controls
   input  wire        pc_ld,
   input  wire        pc_inc,

   // Temporary Register Controls
   input  wire 		  temp_ld,

	// Status Register Controls
   input wire 		  status_w_en,
   // ALU Controls
   input  wire  	  alu_in_0_sel,
   input  wire  [2:0] alu_in_1_sel, 
   input  wire  [2:0] alu_sel,   

   // Output Instruction Register to Control
   output reg 	[15:0] ir,
   // Output Status to Control
   output reg    [2:0] cond

   );
   // Local Registers
   reg  [15:0] pc;
   reg   [2:0] dr;
   reg   [2:0] sr;
   reg   [2:0] sr1;
   reg   [2:0] sr2; 
   reg   [2:0] base_reg;
   reg  [15:0] pcoffset9;  
   reg  [15:0] pcoffset11;
   reg  [15:0] offset6;
   reg  [15:0] imm5;
   reg  [15:0] temp;
   // Declare other local wires and registers here

   // Memory Read/Write Channels
   wire  [15:0] d_w_addr;
   wire  [15:0] d_r_addr;
   wire  [15:0] d_w_data;
   wire  [15:0] d_r_data;

   // Register File Read/Write Channels
   wire  [2:0] rf_r_addr_0;
   wire  [2:0] rf_r_addr_1;
   wire  [2:0] rf_w_addr;
   wire [15:0] rf_w_data;
   wire [15:0] rf_data_0;
   wire [15:0] rf_data_1;
   // ALU Wires
   wire [15:0] alu_in_0;
   wire [15:0] alu_in_1;
   wire [15:0] alu_out;

   // Assign PC debug net
   assign pc_debug_data = pc;


   //----------------------------------------------------------------------
   // Memory Module
   //----------------------------------------------------------------------

   	assign d_r_addr = 	(d_r_addr_sel == `D_R_ADDR_SEL_ALU)  ? alu_out :
   					 	(d_r_addr_sel == `D_R_ADDR_SEL_TEMP) ? temp    :
   					 	(d_r_addr_sel == `D_R_ADDR_SEL_MEM)  ? alu_out : 
   						(d_r_addr_sel== `D_R_ADDR_SEL_PC)   ? pc      : pc;

   	assign d_w_addr = 	(d_w_addr_sel == `D_W_ADDR_SEL_ALU)  ? alu_out :
   						(d_w_addr_sel == `D_W_ADDR_SEL_TEMP) ? temp    :
   						(d_w_addr_sel == `D_W_ADDR_SEL_MEM)  ? alu_out : 
   						(d_w_addr_sel == `D_R_ADDR_SEL_PC) ? pc      : pc;                  
   	assign d_w_data = 	(d_w_data_sel == `D_W_DATA_SEL_RF0) ? rf_data_0 :
   						(d_w_data_sel == `D_W_DATA_SEL_ALU) ? alu_out : 1'd0;

   // 1024-entry 16-bit memory (connect other ports)
   Memory mem(
   	.clk      (clk),
   	.rst      (rst),
   	.r_addr_0 (d_r_addr),
   	.r_addr_1 (mem_debug_addr),
   	.w_addr   (d_w_addr),
   	.w_data   (d_w_data),
   	.w_en     (d_w_en),
   	.r_data_0 (d_r_data),
   	.r_data_1 (mem_debug_data)
   	);

   //----------------------------------------------------------------------
   // Register File Module
   //----------------------------------------------------------------------


   	assign rf_r_addr_0 = 	(rf_r_addr_0_sel == `RF_R_ADDR_0_SEL_BASE_REG) ? base_reg : 
   							(rf_r_addr_0_sel == `RF_R_ADDR_0_SEL_SR) ? sr :
   							(rf_r_addr_0_sel == `RF_R_ADDR_0_SEL_SR1) ? sr1 :
   							(rf_r_addr_0_sel == `RF_R_ADDR_0_SEL_REG7) ? 3'd7 : 3'd0 ;
                      // {{11{ir[`IMM5_SIGN]}}, ir[`IMM5]} : 16`d0;

  	assign rf_r_addr_1 = 	(rf_r_addr_1_sel == `RF_R_ADDR_1_SEL_SR1) ? sr1 :
                      		(rf_r_addr_1_sel == `RF_R_ADDR_1_SEL_SR2) ? sr2 : 3'd0;
    
    assign rf_w_addr = (rf_w_addr_sel == `RF_W_ADDR_SEL_DR) ? dr : 
    				   (rf_w_addr_sel == `RF_W_ADDR_SEL_REG7) ? 3'd7 : 1'd0;



    assign rf_w_data = 	(rf_w_data_sel == `RF_W_DATA_SEL_ALU) ? alu_out  :
                      	(rf_w_data_sel == `RF_W_DATA_SEL_MEM) ? d_r_data :
                      	(rf_w_data_sel == `RF_W_DATA_SEL_PC) ? pc_ld : 3'd0; //* ask - really pc_ld?
                        // ? {{8{1'b0}}, ir[`CONSTANT]} : 16'd0;

   // HINT: {{8{1'b0}}, ir[`CONSTANT]} pads the most significant bits with zeros
   // You can use this syntax to sign-extend.

   // 8-entry 16-bit register file (connect other ports)
   RegisterFile rfile(
   	.clk      (clk),
   	.rst      (rst),
   	.r_addr_0 (rf_r_addr_0),
   	.r_addr_1 (rf_r_addr_1),
   	.r_addr_2 (rf_debug_addr),
   	.w_addr   (rf_w_addr),
   	.w_data   (rf_w_data),
   	.w_en     (rf_w_en),
   	.r_data_0 (rf_data_0),
   	.r_data_1 (rf_data_1),
   	.r_data_2 (rf_debug_data)
   	);

   //----------------------------------------------------------------------
   // Add all other datapath logic here
   //----------------------------------------------------------------------
   //----------------------------------------------------------------------
   // Instruction Register
   //----------------------------------------------------------------------

   	always @(posedge clk) begin
   		if (rst) begin
   			ir <= 16'd0;
   		end
   		else if (ir_ld) begin
	   		ir <= d_r_data[15:0];
	   		dr <= d_r_data[`DR];
	   		sr1 <= d_r_data[`SR1];
	   		sr2 <= d_r_data[`SR2];
	   		base_reg <= d_r_data[`BASE_REG];
	   		sr <= d_r_data[`SR];
	   		offset6 <= {{10{d_r_data[5]}}, d_r_data[`OFFSET6]};
	        // Sign extend for pcoffset9, pcoffset11, imm5
	        pcoffset9 <= {{7{d_r_data[8]}}, d_r_data[`PCOFFSET9]};
	        pcoffset11 <= {{5{d_r_data[10]}}, d_r_data[`PCOFFSET11]};
	        imm5 <= {{11{d_r_data[`IMM5_SIGN]}}, d_r_data[`IMM5]};
	    end
    end


   //----------------------------------------------------------------------
   // Program Counter
   //----------------------------------------------------------------------

	always @(posedge clk) begin
	   	if (rst) begin
	   		pc <= 16'd0;
	   	end
	   	else if (pc_ld) begin
	   		pc <= alu_out;
	   	end
	   	else if (pc_inc) begin
	   		pc <= pc + 16'd1;
	   	end
	end

   //----------------------------------------------------------------------
   // Status Register
   //----------------------------------------------------------------------

	always @(posedge clk) begin
		if (rst) begin
			cond <= 3'b000;
		end
   		if (status_w_en) begin
   			// check sign of 2's complement bit
   			cond[`COND_N] <= (rf_w_data[15] == 1'b1);
   			cond[`COND_Z] <= (rf_w_data == 16'd0);
   			cond[`COND_P] <= (rf_w_data[15] == 1'b0 && rf_w_data != 16'd0);
   		end
   	end

   //----------------------------------------------------------------------
   // Temporary Register
   //----------------------------------------------------------------------

   	always @( * ) begin
   		if (temp_ld) begin
   			temp = d_r_data;
   		end
   	end
   //----------------------------------------------------------------------
   // ALU
   //----------------------------------------------------------------------

   	assign alu_in_0 = 	(alu_in_0_sel == `ALU_IN_0_SEL_PC) ? pc :
   						(alu_in_0_sel == `ALU_IN_0_SEL_RF0) ? rf_data_0 : rf_r_addr_0;
   	assign alu_in_1 = 	(alu_in_1_sel == `ALU_IN_1_SEL_IMM5) ? imm5 : 
   						(alu_in_1_sel == `ALU_IN_1_SEL_OFFSET6) ? offset6 :
   						(alu_in_1_sel == `ALU_IN_1_SEL_PCOFFSET9) ? pcoffset9 : 
   						(alu_in_1_sel == `ALU_IN_1_SEL_PCOFFSET11) ? pcoffset11 : 
   						(alu_in_1_sel == `ALU_IN_1_SEL_RF1) ? rf_data_1 : rf_data_1;

   	assign alu_out = 	(alu_sel == `ALU_FN_ADD)     ? alu_in_0 + alu_in_1 :
   						(alu_sel == `ALU_FN_SUBTR)   ? alu_in_0 - alu_in_1 :
   						(alu_sel == `ALU_FN_AND)     ? alu_in_0 & alu_in_1 : 
   						(alu_sel == `ALU_FN_NOT)     ? ~alu_in_0 : 
   						(alu_sel == `ALU_FN_PASS)    ? alu_in_0  : 0;



endmodule
