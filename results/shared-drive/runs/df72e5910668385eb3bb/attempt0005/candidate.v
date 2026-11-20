module arbiter(input [7:0] req, output [7:0] grant);
  assign grant = req & (~req + 8'd1);
endmodule
