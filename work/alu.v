`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// student ID:0710003
// name:林克帆
//
// Create Date:    15:15:11 08/18/2013
// Design Name:
// Module Name:    alu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module alu(
           clk,           // system clock              (input)
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
			  //bonus_control, // 3 bits bonus control input(input) 
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );

input           clk;
input           rst_n;
input  [32-1:0] src1;
input  [32-1:0] src2;
input   [4-1:0] ALU_control;
//input   [3-1:0] bonus_control; 

output [32-1:0] result;
output          zero;
output          cout;
output          overflow;


wire    [32-1:0] result;
wire             zero;
wire             cout;
wire             overflow;

parameter And = 4'b0000, Or  = 4'b0001, Add = 4'b0010,
          Sub = 4'b0110, Nor = 4'b1100, Slt = 4'b0111;
		  
wire [31-1:0] t_cout;                                 //the cout of each alu_top
wire [32-1:0] cin;									  //the cin of each alu_top and alu_bottom
wire          set;									  //the less input of 1st alu_top
reg   [3-1:0] operation;
reg  [32-1:0] r_src1, r_src2;                         //register the volume og src1 and src2
reg           cin0;                                   //the cin of 1st alu_top

assign cin = t_cout << 1;							  //each alu_top cin is the previous alu_top cout
assign zero = ~(| result);							  //if result == 0, then zero =1; otherwise, zero = 0

always@( posedge clk or negedge rst_n ) 
begin
	if(!rst_n) begin								  //initail set
		operation = 3'b000;
		r_src1 = 0;
		r_src2 = 0;
		cin0 = 0;
	end
	else begin
		case(ALU_control)
			And: 
			begin
				operation = 3'b001;
				cin0 = 0;
			end
			Or:  
			begin
				operation = 3'b010;
				cin0 = 0;
			end
			Add: 
			begin
				operation = 3'b011;
				cin0 = 0;
			end
			Sub: 
			begin
				operation = 3'b100;
				cin0 = 1;							  //2'complement is ~src2 + 1, so cin = 1	
			end
			Nor: 
			begin
				operation = 3'b101;
				cin0 = 0;
			end
			Slt: 
			begin
				operation = 3'b110;
				cin0 = 1;
			end
			default: operation = 3'b111;
		endcase
		
		r_src1 = src1;
		r_src2 = src2;
	end
end

genvar idx;
generate
	for (idx = 0; idx < 32; idx = idx + 1)
	begin: BLOCK
		if(idx == 0)								 //the 1st alu_top	
			begin
				alu_top alu_topI(				
					.src1(r_src1[idx]),
					.src2(r_src2[idx]),
					.less(set),
					.A_invert(~r_src1[idx]),
					.B_invert(~r_src2[idx]),
					.cin(cin0),
					.operation(operation),
					.result(result[idx]),
					.cout(t_cout[idx])
				);
			end
		else if(idx == 31)							 //the alu_bottom
			begin
				alu_bottom alu_bottomI(
					.src1(r_src1[idx]),
					.src2(r_src2[idx]),
					.less(1'b0),
					.A_invert(~r_src1[idx]),
					.B_invert(~r_src2[idx]),
					.cin(cin[idx]),
					.operation(operation),
					.result(result[idx]),
					.cout(cout),
					.set(set),
					.overflow(overflow)
				);
			end
		else										 //the other alu_top	
			begin
				alu_top alu_topI(
					.src1(r_src1[idx]),
					.src2(r_src2[idx]),
					.less(1'b0),
					.A_invert(~r_src1[idx]),
					.B_invert(~r_src2[idx]),
					.cin(cin[idx]),
					.operation(operation),
					.result(result[idx]),
					.cout(t_cout[idx])
				);
			end
	end
endgenerate

endmodule