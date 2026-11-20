module fifo(input clk, input rst, input wr_en, input rd_en,
  input [7:0] din, output reg [7:0] dout, output full, output empty);
  reg [7:0] mem [0:3];
  reg [1:0] wptr, rptr;
  reg [2:0] count;
  assign full = (count == 3'd4);
  assign empty = (count == 3'd0);
  always @(posedge clk) begin
    if (rst) begin
      wptr <= 0; rptr <= 0; count <= 0; dout <= 0;
    end else begin
      if (wr_en && !full) begin
        mem[wptr] <= din;
        wptr <= wptr + 1'b1;
      end
      if (rd_en && !empty) begin
        dout <= mem[rptr];
        rptr <= rptr + 1'b1;
      end
      case ({(wr_en && !full), (rd_en && !empty)})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end
endmodule
