module fifo(input clk,rst,wr_en,rd_en, input [7:0] din,
    output reg [7:0] dout, output full,empty);
  reg [7:0] words [0:3];
  reg [2:0] count;
  wire push=wr_en & ~full, pop=rd_en & ~empty;
  wire [1:0] tail=count[1:0] - {1'b0,pop};
  assign full=(count==3'd4);
  assign empty=(count==3'd0);
  integer i;
  always @(posedge clk)
    if (rst) begin count<=0; dout<=0; end
    else begin
      if (pop) dout<=words[0];
      for(i=0;i<4;i=i+1)
        if (push && tail==i) words[i]<=din;
        else if (pop && i<3) words[i]<=words[(i+1)%4];
      if (push ^ pop) count<=pop ? count-3'd1 : count+3'd1;
    end
endmodule
