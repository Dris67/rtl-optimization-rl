module arbiter(input [7:0] req, output reg [7:0] grant);
  integer i;
  always @* begin
    grant = 8'd0;
    for (i = 7; i >= 0; i = i - 1)
      if (req[i]) grant = (8'b1 << i);
  end
endmodule
