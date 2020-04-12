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

module alu_bottom(
			   src1,       //1 bit source 1 (input)
               src2,       //1 bit source 2 (input)
               less,       //1 bit less     (input)
               A_invert,   //1 bit A_invert (input)
               B_invert,   //1 bit B_invert (input)
               cin,        //1 bit carry in (input)
               operation,  //operation      (input)
               result,     //1 bit result   (output)
               cout,       //1 bit carry out(output)
			   set,        //1 bit set      (output)                     //to set the less input of 1st alu_top 
			   overflow    //1 bit overflow (output)                     //to set overflow
               );

input         src1;
input         src2;
input         less;
input         A_invert;
input         B_invert;
input         cin;
input [3-1:0] operation;

output        result;
output        cout;
output        set;
output        overflow;

reg           result, cout, set, overflow;

parameter AND = 3'b001, 
          OR  = 3'b010,
          ADD = 3'b011,
		  SUB = 3'b100,
		  NOR = 3'b101,
		  SLT = 3'b110;

always@(*)
begin
	case(operation)
		AND: 
			begin
				result = src1 & src2;
				cout = 1'b0;
				set = 1'b0;
				overflow = 1'b0;
			end
		OR: 
			begin
				result = src1 | src2;
				cout = 1'b0;
				set = 1'b0;
				overflow = 1'b0;
			end
		ADD: 
			begin
				result = src1 ^ src2 ^ cin;
				cout = (src1 & src2) | (cin & (src1 | src2));
				set = 1'b0;
				overflow = (src1 ^ src2)? 1'b0:                            //positive add negative or negative add positive will not overflow
				           (src1 ^ src2 ^ cin == src1)? 1'b0:              //C = A + B. if signbit of C not equals to signbit of A, which means overflow
						   1'b1;
			end
		SUB:                                                               //sub equals to add 2'complement(~src2 + cin, where cin = 1)
			begin
				result = src1 ^ B_invert ^ cin;
				cout = (src1 & B_invert) | (cin & (src1 | B_invert));
				set = 1'b0;
				overflow = (src1 ^ B_invert)? 1'b0:
				           (src1 ^ B_invert ^ cin == src1)? 1'b0:
						   1'b1;
			end
		NOR:
			begin
				result = A_invert & B_invert;
				cout = 1'b0;
				set = 1'b0;
				overflow = 1'b0;
			end
		SLT:
			begin
				result = less;
				cout = 1'b0;
				set = (src1 ^ src2)? ~(src1 < src2):                       //if signbit of src1 and src2 are not equal, then I can judge set volume directly.
									 src1 ^ B_invert ^ cin;                //otherwise, I need to get the signbit of src1 SUB src2
				overflow = 1'b0;
			end
		default:
			begin
				result = 1'b0;
				cout = 1'b0;
				set = 1'b0;
				overflow = 1'b0;
			end
	endcase
end



endmodule