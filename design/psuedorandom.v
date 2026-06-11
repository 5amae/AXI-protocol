


module s_axil #(
    parameter C_AXIL_ADDR_WIDTH = 4,
    parameter C_AXIL_DATA_WIDTH = 32
)(
    input aclk,
    input aresetn,

    // AXI-Lite Slave Interface
    // write adress channel
    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_awaddr,     //input from the CU saying which register should be written, like either start stop seed or taps
    input                       s_axi_awvalid,       // when the CU gives a valid signal only then is the input taken when ready =1
    output reg                  s_axi_awready,       //ready signal given by the axilight

//write data channel
    input  [C_AXIL_DATA_WIDTH-1:0] s_axi_wdata,      // the value that is supposed to be written into that adress
    input                       s_axi_wvalid,        // the value is only taken when the cu gives the valid signal
    output reg                  s_axi_wready,        // the axi sends the ready signal when its not conducting any operation


    //write response channel
    output reg [1:0]            s_axi_bresp,         // sends out the response signal saying if the data it recieved is correct and the adress it recieved it is also correct
    output reg                  s_axi_bvalid,        //sends out the valid signal tot eh cu so the signal can be sent only when cu is free and accepts sending the ready
    input                       s_axi_bready,        // input signal recieved by the axi light


//read adress channel
    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_araddr,     //gives the adress value like 0x04 or 0x08 from which the cu wants to read
    input                       s_axi_arvalid,
    output reg                  s_axi_arready,       //same ready and valid signals sent when both cu and slave axi are ready


//read data channel
    output reg [C_AXIL_DATA_WIDTH-1:0] s_axi_rdata,  // what data is stored in that particular register
    output reg [1:0]            s_axi_rresp,         // outputs whether the output given was correct or there was any error
    output reg                  s_axi_rvalid,        // same old valid and ready signals
    input                       s_axi_rready,        // 

    // AXI - Stream Master Interface
    output reg [C_AXIL_DATA_WIDTH-1:0] m_axis_tdata, // sending the histobinner the data only when
    output reg                    m_axis_tvalid,     //the valid signal is out
    input                         m_axis_tready      //and this recieves the ready signals
);

   //Address map for these registers

    // 0x00 - start_reg
    // 0x04 - stop_reg
    // 0x08 - seed_reg
    // 0x0C - taps_reg

    // Registers
    reg start_reg;
    reg stop_reg;
    reg [7:0] seed_reg;
    reg [7:0] taps_reg;
    reg load;
    reg ready;
    wire valid;
    wire [7:0] Q;
    reg [3:0] accepted_addr;
    reg [31:0] accepted_data;
    reg [3:0] recieved_addr;
    reg [31:0] recieved_data;
    reg addr_loaded;
    reg data_loaded;
    reg addr_taken;
    reg error;
    reg write_done;
    reg write_in_progress;
    


//write adress channel 

always@(posedge aclk)
begin
    if(aresetn == 0)
        begin
        s_axi_awready <= 0;
        addr_loaded <=0;
        taps_reg <=0;
        seed_reg<=0;
        start_reg<=0;
        stop_reg<=0;
        end
    else 
        begin
        if(s_axi_awvalid==1 && addr_loaded==0 &&write_in_progress ==0)  //when this recieves the write address valid signal and sends the ready signal
            begin                                 // simultaneously it accepts the adress into the register load_address
            s_axi_awready <= 1;
            accepted_addr <= s_axi_awaddr;
            addr_loaded <=1;
            
            end
        else 
            begin
            s_axi_awready <= 0;
            end
        end
end

always@(posedge aclk)
begin
    if(aresetn == 0)    // similar to reading the address this accepts the data that needs to be accepted into the address
        begin
        s_axi_wready <= 0;
        data_loaded <=0;
        end
    else 
        begin
        if(s_axi_wvalid==1 && data_loaded==0 &&write_in_progress ==0) //declaring the ready signal when valid is given
            begin
            s_axi_wready <= 1;
            accepted_data <= s_axi_wdata; //transfer the data
            data_loaded <= 1;
            
            end
        else 
            begin
            s_axi_wready <= 0; // in all other cases other than this ready =0
            end
        end
end


always@(posedge aclk)begin
if(data_loaded==1 && addr_loaded ==1)// only when both the address and data are loaded is the value actually written
begin
    
     write_in_progress <=1;
    case(accepted_addr)
    
        
    4'b0000:
        begin
            start_reg <= accepted_data[0]; //loading data to the address
            error <=0;

        end
    4'b0100:
        begin
            stop_reg <= accepted_data[0];
            error <=0;
        end
    4'b1000:
        begin
            seed_reg <= accepted_data[7:0];
            load <= 1;
            error <=0;
          
        end
    4'b1100:
        begin
            taps_reg <= accepted_data[7:0];
            error <=0;
            
        end
    default:
        begin
            error <=1;
            
        end
    
    endcase
    write_in_progress <=0;
end
end


always @(posedge aclk) begin
    if (!aresetn)
        load <= 0;
    else if (load)
        load <= 0;  // clearing load after one cycle
end




always @(posedge aclk)
begin
    if (aresetn == 0)
     begin
        write_done <= 0;
        write_in_progress <=0;
    end
    else if (data_loaded == 1 && addr_loaded == 1 ) 
    begin
        write_done <= 1; 
        data_loaded<=0;
        addr_loaded<=0; 
        
        // Set write_done when write is actually performed, this can be used for the response block
    end
end




always@(posedge aclk)
begin
    if(aresetn ==0)
    begin
        s_axi_bresp <=0;
        s_axi_bvalid <=0;
        
    end
    else 
    begin 
        if(write_done ==1 && s_axi_bvalid==0) // setting the valid signal only when write_done is 1
        begin
            s_axi_bvalid <= 1;
            s_axi_bresp <= (error ==1) ? 2'b10 : 2'b00; // if adress given is not applicable then error is given as 1 which in 
           
        end                                              // turn sets the value of response and sends it back to the CU
        else if(s_axi_bready==1 && s_axi_bvalid == 1)  
            begin
                write_done <=0;
                s_axi_bvalid <=0;
               
           
        end
        
    end
end

//read address channel
always@(posedge aclk)
begin
    if(aresetn == 0)
        begin
        s_axi_arready <= 0;
        addr_taken <=0;
        end
    else 
        begin
        if(s_axi_arvalid==1 && s_axi_arready==0)  //when this recieves the write address valid signal and sends the ready signal
            begin                                 // simultaneously it accepts the adress into the register load_address
            s_axi_arready <= 1;
            recieved_addr <= s_axi_araddr;
            addr_taken <=1;
            end
        else
            begin
            s_axi_arready <= 0;
            end
        end
end
reg addr_err;
reg [31:0] the_written_data;

always@(posedge aclk)
begin
    if(addr_taken ==1)
    begin
        case(recieved_addr)
    
        
    4'b0000:
        begin
            the_written_data <= start_reg; //loading data to the address
            addr_err <=0;

        end
    4'b0100:
        begin
            the_written_data <= stop_reg;
            addr_err <=0;
        end
    4'b1000:
        begin
            the_written_data <= seed_reg;
            addr_err <=0;
          
        end
    4'b1100:
        begin
            the_written_data <= taps_reg;
            addr_err <=0;
            
        end
    default:
        begin
            addr_err <=1;
            the_written_data <=0;
            
        end
    
    endcase
    addr_taken <= 0;
end
end

always@(posedge aclk)
begin
    if(aresetn == 0)
    begin
        s_axi_rdata <=0;
        s_axi_rresp <=0;
        s_axi_rvalid <=0;
    end
    else if(addr_taken == 0 && s_axi_rvalid==0)
    begin
        s_axi_rvalid <= 1;
        s_axi_rdata <= the_written_data;
        s_axi_rresp <= (addr_err == 1) ? 2'b10 :2'b00;
        
        
    end
    else if(s_axi_rvalid ==1 && s_axi_rready==1)
    begin
        
        s_axi_rvalid <= 0;
    end
end








 always@(posedge aclk)
begin
    if(aresetn ==0)
    begin
        m_axis_tvalid <=0;
        m_axis_tdata <=0;
        
    end
    else 
    begin 
        if(m_axis_tvalid ==0) 
        begin
            m_axis_tdata <= {{24{1'b0}},Q};
          //  m_axis_tvalid <=the_LFSRvalid; 
           
        end
        else if(m_axis_tvalid ==1 && m_axis_tready == 1)  
            begin
                
                m_axis_tvalid <=0;
            end
  
    end
end
// requires work

wire [31:0] to_ram_data;
wire to_ram_valid;
wire from_ram_ready;
wire [31:0] sent_number;
wire ready1;
wire valid1;
wire ready2;
wire valid2;

LFSR m_LFSR(
    .rst(~aresetn),
    .clk(aclk),
    .load(load),
    .start(start_reg),
    .stop(stop_reg),
    .seed(seed_reg),
    .taps(taps_reg),
    .ready(ready1),
    .valid(valid1),
    .Q(Q)
);

s_m_hist m_s_m_hist (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata({{24{1'b0}},Q}),
        .s_axis_tvalid(valid1),
        .s_axis_tready(ready1),
        .m_axis_tdata(to_ram_data),
        .m_axis_tvalid(valid2),
        .m_axis_tready(ready2)
    );

axi_ram m_axi_ram (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(to_ram_data),
        .s_axis_tvalid(valid2),
        .s_axis_tready(ready2),
        .m_axis_tdata(sent_number)
    );

//reqiores work

endmodule