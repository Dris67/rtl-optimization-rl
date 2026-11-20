module multi_8bit(input [7:0] A,B, output [15:0] product);
  wire [11:0] lo = A * B[3:0];
  wire [11:0] hi = A * B[7:4];
  assign product = {4'b0,lo} + {hi,4'b0};
endmodule
