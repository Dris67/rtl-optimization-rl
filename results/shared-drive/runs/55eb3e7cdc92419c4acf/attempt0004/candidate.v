module counter_12(input rst_n,clk,valid_count, output reg [3:0] out);
  wire wrap = out == 4'd11;
  wire [3:0] toggle = {(&out[2:0]),(&out[1:0]),out[0],1'b1};
  always @(posedge clk or negedge rst_n)
    if (!rst_n) out <= 4'b0;
    else if (valid_count) out <= wrap ? 4'b0 : (out ^ toggle);
endmodule
