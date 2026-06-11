module Dflip(
    input clk,rst,
    input load,
    input D,
    input pass,
    input en,
    output reg Q
);

always@(posedge clk or posedge rst)

begin
  if (rst)
    Q <= 1'b0;
  else if (load)
    Q <= D;         // highest priority — load seed
  else if (en)
    Q <= pass;      // shift value only if en is 1
end

endmodule
