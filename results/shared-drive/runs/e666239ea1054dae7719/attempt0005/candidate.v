module arbiter(input [7:0] req, output [7:0] grant);
  wire [3:0] lo = req[3:0], hi = req[7:4];
  assign grant[3:0] = lo & (~lo + 4'd1);
  assign grant[7:4] = (hi & (~hi + 4'd1)) & {4{lo == 4'b0}};
endmodule
