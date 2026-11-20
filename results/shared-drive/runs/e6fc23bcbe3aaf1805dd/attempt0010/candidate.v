module counter_12(input rst_n,clk,valid_count, output reg [3:0] out);
  wire wrap = valid_count && out == 4'd11;
  always @(posedge clk or negedge rst_n)
    if (!rst_n) out <= 4'b0;
    else out <= wrap ? 4'b0 : out + {3'b0,valid_count};
endmodule
