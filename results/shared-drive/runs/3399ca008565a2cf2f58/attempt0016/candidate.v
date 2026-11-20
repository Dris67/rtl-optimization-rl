module barrel_shifter(input [7:0] in, input [2:0] ctrl, output [7:0] out);
  assign out[0] = (in[0] & (ctrl == 3'd0)) | (in[1] & (ctrl == 3'd1)) | (in[2] & (ctrl == 3'd2)) | (in[3] & (ctrl == 3'd3)) | (in[4] & (ctrl == 3'd4)) | (in[5] & (ctrl == 3'd5)) | (in[6] & (ctrl == 3'd6)) | (in[7] & (ctrl == 3'd7));
  assign out[1] = (in[1] & (ctrl == 3'd0)) | (in[2] & (ctrl == 3'd1)) | (in[3] & (ctrl == 3'd2)) | (in[4] & (ctrl == 3'd3)) | (in[5] & (ctrl == 3'd4)) | (in[6] & (ctrl == 3'd5)) | (in[7] & (ctrl == 3'd6));
  assign out[2] = (in[2] & (ctrl == 3'd0)) | (in[3] & (ctrl == 3'd1)) | (in[4] & (ctrl == 3'd2)) | (in[5] & (ctrl == 3'd3)) | (in[6] & (ctrl == 3'd4)) | (in[7] & (ctrl == 3'd5));
  assign out[3] = (in[3] & (ctrl == 3'd0)) | (in[4] & (ctrl == 3'd1)) | (in[5] & (ctrl == 3'd2)) | (in[6] & (ctrl == 3'd3)) | (in[7] & (ctrl == 3'd4));
  assign out[4] = (in[4] & (ctrl == 3'd0)) | (in[5] & (ctrl == 3'd1)) | (in[6] & (ctrl == 3'd2)) | (in[7] & (ctrl == 3'd3));
  assign out[5] = (in[5] & (ctrl == 3'd0)) | (in[6] & (ctrl == 3'd1)) | (in[7] & (ctrl == 3'd2));
  assign out[6] = (in[6] & (ctrl == 3'd0)) | (in[7] & (ctrl == 3'd1));
  assign out[7] = (in[7] & (ctrl == 3'd0));
endmodule
