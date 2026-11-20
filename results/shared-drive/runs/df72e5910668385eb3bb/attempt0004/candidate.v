module arbiter(input [7:0] req, output [7:0] grant);
  assign grant[0] = req[0];
  assign grant[1] = req[1] & ~(|req[0:0]);
  assign grant[2] = req[2] & ~(|req[1:0]);
  assign grant[3] = req[3] & ~(|req[2:0]);
  assign grant[4] = req[4] & ~(|req[3:0]);
  assign grant[5] = req[5] & ~(|req[4:0]);
  assign grant[6] = req[6] & ~(|req[5:0]);
  assign grant[7] = req[7] & ~(|req[6:0]);
endmodule
