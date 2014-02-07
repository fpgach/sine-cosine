`timescale 1ns / 1ps

module testgen;

	// Inputs
	reg clk;
    reg [31:0] out_freq;
    reg [31:0] discr_freq;
    

	// Outputs
	wire [15:0] sin;
	wire [15:0] cos;

	// Instantiate the Unit Under Test (UUT)
	cordic_gen uut (
		.clk(clk),
        .out_freq(out_freq),
        .discr_freq(discr_freq),
		.sin(sin),
		.cos(cos)
	);
    reg[31:0] cnt = 32'b0;
    reg[ 1:0] freq = 2'b0;
    wire    [19:0] arg = uut.my_arg;
    
    initial begin
        out_freq = 50;
        forever #25000000 out_freq <= out_freq + 50;
    end
	initial begin
		// Initialize Inputs
		clk = 0;
        discr_freq = 8000;
        forever #(100/2) clk = ~clk;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
	end
      
endmodule

