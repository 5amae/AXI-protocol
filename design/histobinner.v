module s_m_hist (

    input aclk,
    input aresetn,

    // AXI-Stream Slave

    input [31:0]s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,

    // AXI-Stream Master 

    output reg [31:0]m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready
    
);
wire [31:0] debug_counting0, debug_counting1;
wire [31:0] debug_counting2, debug_counting3;
wire [31:0] debug_counting4, debug_counting5;
wire [31:0] debug_counting6, debug_counting7;
wire [31:0] debug_counting8, debug_counting9;
wire [31:0] debug_counting10, debug_counting11;
wire [31:0] debug_counting12, debug_counting13;
wire [31:0] debug_counting14;



reg [31:0] counting [14:0];
integer i,j;
reg sending;

always@(posedge aclk)
begin
    if(aresetn == 0)
        begin
        s_axis_tready <=0;
        i <=0;
        j<=0;
        for (integer k = 0; k < 15; k = k + 1)
        begin 
            counting[k] <= 32'b0; 
        end
    
        end
    else 
        begin
        if(s_axis_tvalid==1 && i<15 && sending==0)  // when the psuedorandom sends valid, and nothing is being sent to ram
        // AND less than 15 values are stored give ready to tthe psuedoranom
        //only then give ready to accept data
         begin               

            s_axis_tready <= 1;
            i <= i+1;//increment the value of i after every value sent to the storing registersso we can store cleanly


            if(s_axis_tdata>=1 && s_axis_tdata<=32)begin
            counting[i]  <= {{4'b0000},{s_axis_tdata[27:0]}};//if the value is between this then add this to the start of the sent information for easy storage in ram
            end
            else if(s_axis_tdata>=33 && s_axis_tdata<=64)begin
            counting[i]  <= {{4'b0001},{s_axis_tdata[27:0]}};
            end
            else if(s_axis_tdata>=65 && s_axis_tdata<=96)begin
            counting[i]  <= {{4'b0010},{s_axis_tdata[27:0]}};
            end
            else if(s_axis_tdata>=97 && s_axis_tdata<=128)begin
            counting[i]  <= {{4'b0011},{s_axis_tdata[27:0]}};
            end
            else if(s_axis_tdata>=129 && s_axis_tdata<=160)begin
            counting[i]  <= {{4'b0100},{s_axis_tdata[27:0]}};
            end
            else if(s_axis_tdata>=161 && s_axis_tdata<=192)begin
            counting[i]  <= {{4'b0101},{s_axis_tdata[27:0]}};
            end
            else if(s_axis_tdata>=193 && s_axis_tdata<=224)begin
            counting[i]  <= {{4'b0110},{s_axis_tdata[27:0]}};
            end
            else if(s_axis_tdata>=225 && s_axis_tdata<=256)begin
            counting[i]  <= {{4'b0111},{s_axis_tdata[27:0]}};
            end
            

            end
        else 
            begin
            s_axis_tready <= 0;// if sending==1 or valid is not there or if i>14 any of the cases this isnt ready
            end
        end
end

assign debug_counting0 = counting[0];
assign debug_counting1 = counting[1];
assign debug_counting2 = counting[2];
assign debug_counting3 = counting[3];
assign debug_counting4 = counting[4];
assign debug_counting5 = counting[5];
assign debug_counting6 = counting[6];// just for checking if what values getting into the coutning array is valid
assign debug_counting7 = counting[7];
assign debug_counting8 = counting[8];
assign debug_counting9 = counting[9];
assign debug_counting10 = counting[10];
assign debug_counting11 = counting[11];
assign debug_counting12 = counting[12];
assign debug_counting13 = counting[13];
assign debug_counting14 = counting[14];

always@(posedge aclk)
begin
    if(aresetn ==0)
    begin
        m_axis_tvalid <=0;
        sending <=0;
    end
    else if (i >=14 && sending ==0)// only start sending values wgen i=14 and we arent currently sending
    begin
        j<=0; // initiating the sending integer
        s_axis_tready <= 0; //i wont recieve signals from the lfsr
        m_axis_tvalid <= 1; // i will start sending signals to ram to store
        sending <=1;
    end
    else if(i==0 && sending ==0)
    begin
        s_axis_tready <= 1;// in the other cases tell the lfsr its ready to accpet more values (included above but fine)
    end
    else if(sending ==1)
    begin
        s_axis_tready <=0;// obv if we are sending data i dont want more data
    end
end

always@(posedge aclk)
begin
    if(sending==1 && j<=14 && m_axis_tready==1)// here i am sending data and clearing the data from our temp registers simultaneously
    begin
    // we are sending info and ram is ready and the index is less than 14 or 14 which means i havent sent 15 values yet
    m_axis_tdata <= counting[j];//send what is stored
    m_axis_tvalid<=1;// set as valid so it accepts the data
    j <= j+1;// increment the integer
    end
    else if(sending==1 && j>14)// if j exceeds 14
    begin
        if(m_axis_tready ==1) //and if ram is still saying its ready to accept values
        begin
            m_axis_tvalid <=0;// tell it that its not valid now
            i <=0;// re initialize i and j
            sending <=0;// stop sending
            j<=0;
        end
    end
end


endmodule