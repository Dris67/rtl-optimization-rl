module barrel_shifter(input [7:0] in, input [2:0] ctrl, output [7:0] out);
  wire [7:0] s1=ctrl[0] ? {1'b0,in[7:1]} : in;
  wire [7:0] s2=ctrl[1] ? {2'b0,s1[7:2]} : s1;
  assign out=ctrl[2] ? {4'b0,s2[7:4]} : s2;
endmodule
