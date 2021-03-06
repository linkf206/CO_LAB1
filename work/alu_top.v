`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// student ID:0710003 
// name:林克帆 
// 
// Create Date:    10:58:01 10/10/2013
// Design Name: 
// Module Name:    alu_top 
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

module alu_top(
			   src1,       //1 bit source 1 (input)
               src2,       //1 bit source 2 (input)
               less,       //1 bit less     (input)
               A_invert,   //1 bit A_invert (input)
               B_invert,   //1 bit B_invert (input)
               cin,        //1 bit carry in (input)
               operation,  //operation      (input)
               result,     //1 bit result   (output)
               cout        //1 bit carry out(output)
               );

input         src1;
input         src2;
input         less;
input         A_invert;
input         B_invert;
input         cin;
input [3-1:0] operation;                                                    //there are six types of operation, so operation is 3bit

output        result;
output        cout;

reg           result, cout;

parameter AND = 3'b001, 
          OR  = 3'b010,
          ADD = 3'b011,
		  SUB = 3'b100,
		  NOR = 3'b101,
		  SLT = 3'b110;

always@(*)																	//because alu_top will work if src1, src2, less, cin, operation change. So I use *(it means all inputs) to trigger always block
begin
	case(operation)
		AND: 
			begin
				result = src1 & src2;
				cout = 1'b0;
			end
		OR: 
			begin
				result = src1 | src2;
				cout = 1'b0;
			end
		ADD: 
			begin
				result = src1 ^ src2 ^ cin;
				cout = (src1 & src2) | (cin & (src1 | src2));
			end
		SUB:  																//sub equals to add 2'complement(~src2 + cin, where cin = 1)
			begin
				result = src1 ^ B_invert ^ cin;
				cout = (src1 & B_invert) | (cin & (src1 | B_invert));
			end
		NOR:																//A nor B = not (A or B) = (not A) and (not B)
			begin
				result = A_invert & B_invert;
				cout = 1'b0;
			end
		SLT:																//SLT need SUB to check, so SLT cout == SUB cout
			begin
				result = less;
				cout = (src1 & B_invert) | (cin & (src1 ^ B_invert));
			end
		default:
			begin
				result = 1'b0;
				cout = 1'b0;
			end
	endcase
end



endmodule