

module LFSR(
    input rst,clk,
    input load,
    input start,
    input stop,
    input [7:0] seed,
    input [7:0] taps,
    input ready,
    output reg valid,
    output [7:0] Q
);
wire feedback;


assign feedback = (Q[0] & taps[0])^(Q[1] & taps[1])^(Q[2] & taps[2])^(Q[3] & taps[3])^(Q[4] & taps[4])^(Q[5] & taps[5])^(Q[6] & taps[6])^(Q[7] & taps[7]);

Dflip D0(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[0]),
    .pass(feedback),
    .en(ready && start && !stop ),
    .Q(Q[0])
    );
Dflip D1(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[1]),
    .pass(Q[0]),
    .en(ready && start && !stop ),
    .Q(Q[1])
    );
Dflip D2(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[2]),
    .pass(Q[1]),
    .en(ready && start && !stop ),
    .Q(Q[2])
    );
Dflip D3(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[3]),
    .pass(Q[2]),
    .en(ready && start && !stop ),
    .Q(Q[3])
    );
Dflip D4(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[4]),
    .pass(Q[3]),
    .en(ready && start && !stop ),
    .Q(Q[4])
    );
Dflip D5(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[5]),
    .pass(Q[4]),
    .en(ready && start && !stop ),
    .Q(Q[5])
    );
Dflip D6(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[6]),
    .pass(Q[5]),
    .en(ready && start && !stop),
    .Q(Q[6])
    );
Dflip D7(
    .clk(clk),
    .rst(rst),
    .load(load),
    .D(seed[7]),
    .pass(Q[6]),
    .en(ready && start && !stop ),
    .Q(Q[7])
    );


reg running;
always @(posedge clk or posedge rst)
 begin
  if (rst==1)
  running <= 0; // obv if rst is given it starts from 0
  else if (start==1 && stop==0)
  running <= 1; // if start is given after resetting the signal generation will start
  else if (stop==1)
    running <= 0; // stop hlats the signals to whatever value it has kept
end

always @(posedge clk or posedge rst) 
begin
    if (rst)
        valid <= 0;  // Reset valid signal
    else if (running == 1)
        valid <= ~valid;  // Toggle valid every clock cycle
end


endmodule



