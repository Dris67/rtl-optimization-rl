module fifo(input clk,rst,wr_en,rd_en, input [7:0] din,
    output reg [7:0] dout, output full,empty);
  reg [7:0] mem [0:3];
  reg [1:0] wptr,rptr;
  reg phase;
  wire push=wr_en & ~full, pop=rd_en & ~empty;
  assign full=(wptr==rptr) & phase;
  assign empty=(wptr==rptr) & ~phase;
  always @(posedge clk)
    if (rst) begin wptr<=0; rptr<=0; phase<=0; dout<=0; end
    else begin
      if (push) begin mem[wptr]<=din; wptr<=wptr+2'd1; end
      if (pop) begin dout<=mem[rptr]; rptr<=rptr+2'd1; end
      phase <= phase ^ (push & (&wptr)) ^ (pop & (&rptr));
    end
endmodule
