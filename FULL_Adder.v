module FULL_Adder(

input A,B,CIN,

output Y,CARRY);

assign Y  = A ^ B ^ CIN ;

assign CARRY = (A & B)| (( A | B) & CIN) ;

endmodule