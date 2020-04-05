`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
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

reg    [32-1:0] result;
reg             zero;
reg             cout;
reg             overflow;

parameter And = 4'b0000, Or = 4'b0001, Add = 4'b0010,
          Sub = 4'b0110, Nor = 4'b1100, Slt = 4'b0111;
		  
reg [32-1:0] cin;
reg [2-1:0] less;
reg [3-1:0] operation;

always@( posedge clk or negedge rst_n ) 
begin
	if(!rst_n) begin
		result <= 0;
		zero <= 0;
		cout <= 0;
		overflow <= 0;
		
		cin<= 0;
		less[0] <= cout;
		less[1] <= 0;
		operation <= 0;		
	end
	else begin
		case(ALU_control)
			And: operation <= 3'b000;
			Or: operation <= 3'b001;
			Add: operation <= 3'b010;
			Sub: operation <= 3'b011;
			Nor: operation <= 3'b100;
		endcase
	end
end

genvar idx;
generate
	for (idx = 1; idx < 31; idx = idx + 1)
	begin:
		alu_top
		alu_1bit(
			.src1(src1[idx]),
			.src2(src2[idx]),
			.less(less[idx]),
			.A_invert(~src1[idx]),
			.B_invert(~src2[idx]),
			.cin(cin[idx - 1]),
			.operation(operation),
			.result(result[idx]),
			.cout(cin[idx])
		);
	end
endgenerate

endmodule
