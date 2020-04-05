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

wire    [32-1:0] result;
wire             zero;
wire             cout;
wire             overflow;

parameter And = 4'b0000, Or = 4'b0001, Add = 4'b0010,
          Sub = 4'b0110, Nor = 4'b1100, Slt = 4'b0111;
		  
wire [32-1:0] cin;
reg [2-1:0] less;
reg [3-1:0] operation;

always@( posedge clk or negedge rst_n ) 
begin
	if(!rst_n) begin
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
			Slt: operation <= 3'b101;
		endcase
	end
end

alu_top alu_top0(
			.src1(src1[0]),
			.src2(src2[0]),
			.less(less[0]),
			.A_invert(~src1[0]),
			.B_invert(~src2[0]),
			.cin(cin[0]),
			.operation(operation),
			.result(result[0]),
			.cout(cin[1])
		);

genvar idx;
generate
	for (idx = 1; idx < 31; idx = idx + 1)
	begin: BLOCK1
		alu_top alu_topI(
			.src1(src1[idx]),
			.src2(src2[idx]),
			.less(less[1]),
			.A_invert(~src1[idx]),
			.B_invert(~src2[idx]),
			.cin(cin[idx]),
			.operation(operation),
			.result(result[idx]),
			.cout(cin[idx+1])
		);
	end
endgenerate

alu_top alu_top31(
			.src1(src1[31]),
			.src2(src2[31]),
			.less(less[0]),
			.A_invert(~src1[31]),
			.B_invert(~src2[31]),
			.cin(cin[31]),
			.operation(operation),
			.result(result[31]),
			.cout(cout)
		);

endmodule
