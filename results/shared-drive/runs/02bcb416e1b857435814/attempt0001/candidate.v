module multi_8bit(input [7:0] A,B, output [15:0] product);
  wire [15:0] p0 = ({8'b0,A} & {16{B[0]}}) << 0;
  wire [15:0] p1 = ({8'b0,A} & {16{B[1]}}) << 1;
  wire [15:0] p2 = ({8'b0,A} & {16{B[2]}}) << 2;
  wire [15:0] p3 = ({8'b0,A} & {16{B[3]}}) << 3;
  wire [15:0] p4 = ({8'b0,A} & {16{B[4]}}) << 4;
  wire [15:0] p5 = ({8'b0,A} & {16{B[5]}}) << 5;
  wire [15:0] p6 = ({8'b0,A} & {16{B[6]}}) << 6;
  wire [15:0] p7 = ({8'b0,A} & {16{B[7]}}) << 7;
  assign product = ((p0+p1)+(p2+p3)) + ((p4+p5)+(p6+p7));
endmodule
