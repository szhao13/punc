//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here

	// From datapath to controller
	wire   [2:0]	cond;
	wire  [15:0] 	ir;

	// Fron controller to datapath
		// Instruction register Controls
	wire        	ir_ld;

	// Program Counter Controls
	wire        	pc_ld;
	wire        	pc_inc;   

	// Memory Controls 
	wire   [2:0]   	d_r_addr_sel;
	wire   [2:0]   	d_w_addr_sel;
	wire 			d_w_en;
	wire   			d_w_data_sel;

	// register File Controls
	wire   [2:0]	rf_w_data_sel;
	wire   [2:0]   	rf_r_addr_0_sel;
	wire   		   	rf_r_addr_1_sel;
	wire   			rf_w_addr_sel;
	wire 			rf_w_en;

	// Temporary register Controls
	wire  			temp_ld;
	// Status register Controls
	wire 			status_w_en;

	// ALU Input Controls
	wire 			alu_in_0_sel;
	wire   [2:0]   	alu_in_1_sel;
	
	// ALU Controls
	wire   [2:0]   	alu_sel;

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk            (clk),
		.rst            (rst),
		
		.cond           (cond),

		.ir             (ir),

		.d_w_en         (d_w_en),
		.d_r_addr_sel 	(d_r_addr_sel),
		.d_w_addr_sel   (d_w_addr_sel),
		.d_w_data_sel   (d_w_data_sel),

		.rf_w_en        (rf_w_en),
		.rf_r_addr_0_sel(rf_r_addr_0_sel),
		.rf_r_addr_1_sel(rf_r_addr_1_sel),
		.rf_w_addr_sel  (rf_w_addr_sel),
		.rf_w_data_sel  (rf_w_data_sel),

		.ir_ld          (ir_ld),

		.pc_ld          (pc_ld),	
		.pc_inc         (pc_inc),

		.temp_ld        (temp_ld),

		.status_w_en    (status_w_en),

		.alu_in_0_sel   (alu_in_0_sel),
		.alu_in_1_sel   (alu_in_1_sel),
		.alu_sel        (alu_sel)


		// Add more ports here

	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr (mem_debug_addr),
		.rf_debug_addr  (rf_debug_addr),
		.mem_debug_data (mem_debug_data),
		.rf_debug_data  (rf_debug_data),
		.pc_debug_data  (pc_debug_data),

		// Add more ports here
		.d_w_en         (d_w_en),
		.d_r_addr_sel 	(d_r_addr_sel),
		.d_w_addr_sel   (d_w_addr_sel),
		.d_w_data_sel   (d_w_data_sel),

		.rf_w_en        (rf_w_en),
		.rf_r_addr_0_sel(rf_r_addr_0_sel),
		.rf_r_addr_1_sel(rf_r_addr_1_sel),
		.rf_w_addr_sel  (rf_w_addr_sel),
		.rf_w_data_sel  (rf_w_data_sel),

		.ir_ld          (ir_ld),

		.pc_ld          (pc_ld),
		.pc_inc         (pc_inc),

		.temp_ld        (temp_ld),

		.status_w_en    (status_w_en),

		.alu_in_0_sel   (alu_in_0_sel),
		.alu_in_1_sel   (alu_in_1_sel),
		.alu_sel        (alu_sel),

		.cond           (cond),

		.ir             (ir)

	);

endmodule
