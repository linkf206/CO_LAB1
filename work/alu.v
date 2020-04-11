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
		   ,check         //check
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
output [4*32-1:0]  check;////////////////////////////////////


wire    [32-1:0] result;
wire             zero;
wire             cout;
wire             overflow;

parameter And = 4'b0000, Or  = 4'b0001, Add = 4'b0010,
          Sub = 4'b0110, Nor = 4'b1100, Slt = 4'b0111;
		  
wire [31-1:0] t_cout;
wire [32-1:0] cin;
wire          set;
reg   [3-1:0] operation;
reg  [32-1:0] r_src1, r_src2;
reg           cin0;
wire [4*32-1:0] checktop;/////////////////////////////////

assign cin = t_cout << 1;
assign cin[0] = operation[2];
assign zero = ~(| result);
assign check = checktop;//

always@( posedge clk or negedge rst_n ) 
begin
	if(!rst_n) begin
		operation <= 3'b000;
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
				cin0 = 1;
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
		if(idx == 0)
			begin
				alu_top alu_topI(
					.clk(clk),
					.src1(r_src1[idx]),
					.src2(r_src2[idx]),
					.less(set),
					.A_invert(~r_src1[idx]),
					.B_invert(~r_src2[idx]),
					.cin(cin0),
					.operation(operation),
					.result(result[idx]),
					.cout(t_cout[idx])
					,.checktop(checktop[4*idx+3 -:4])
				);
			end
		else if(idx == 31)
			begin
				alu_bottom alu_bottomI(
					.clk(clk),
					.src1(r_src1[idx]),
					.src2(r_src2[idx]),
					.less(1'b0),
					.A_invert(~r_src1[idx]),
					.B_invert(~r_src2[idx]),
					.cin(t_cout['d30]),
					.operation(operation),
					.result(result[idx]),
					.cout(cout),
					.set(set),
					.overflow(overflow)
					,.checktop(checktop[4*idx+3 -:4])
				);
			end
		else
			begin
				alu_top alu_topI(
					.clk(clk),
					.src1(r_src1[idx]),
					.src2(r_src2[idx]),
					.less(1'b0),
					.A_invert(~r_src1[idx]),
					.B_invert(~r_src2[idx]),
					.cin(t_cout[idx - 1]),
					.operation(operation),
					.result(result[idx]),
					.cout(t_cout[idx])
					,.checktop(checktop[4*idx+3 -:4])
				);
			end
	end
endgenerate

endmodule