`timescale 1ns / 1ps

module s_axil_tb;
    // Parameters
    parameter C_AXIL_ADDR_WIDTH = 4;
    parameter C_AXIL_DATA_WIDTH = 32;
    
    // Clock and Reset
    reg aclk;
    reg aresetn;
    
    // AXI-Lite Slave Interface Signals
    reg  [C_AXIL_ADDR_WIDTH-1:0] s_axi_awaddr;
    reg                          s_axi_awvalid;
    wire                         s_axi_awready;
    
    reg  [C_AXIL_DATA_WIDTH-1:0] s_axi_wdata;
    reg                          s_axi_wvalid;
    wire                         s_axi_wready;
    
    wire [1:0]                   s_axi_bresp;
    wire                         s_axi_bvalid;
    reg                          s_axi_bready;
    
    reg  [C_AXIL_ADDR_WIDTH-1:0] s_axi_araddr;
    reg                          s_axi_arvalid;
    wire                         s_axi_arready;
    
    wire [C_AXIL_DATA_WIDTH-1:0] s_axi_rdata;
    wire [1:0]                   s_axi_rresp;
    wire                         s_axi_rvalid;
    reg                          s_axi_rready;
    
    // AXI-Stream Master Interface
    wire [C_AXIL_DATA_WIDTH-1:0] m_axis_tdata;
    wire                         m_axis_tvalid;
    reg                          m_axis_tready;
    
    // Instantiate the DUT
    s_axil #(
        .C_AXIL_ADDR_WIDTH(C_AXIL_ADDR_WIDTH),
        .C_AXIL_DATA_WIDTH(C_AXIL_DATA_WIDTH)
    ) dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );
    
    // Clock Generation
    always #5 aclk = ~aclk;
    integer file;

    
    
    
    // Test sequence
    initial begin
        // VCD setup
        $dumpfile("waveform.vcd");
        $dumpvars(0, s_axil_tb);
        $dumpvars(1, dut);  // 
          


        // Initial values
        aclk = 0;
        aresetn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        m_axis_tready = 0;
        
        // Reset phase
        #20;
        aresetn = 1;
        
        // Write to start register (0x00)
        s_axi_awaddr = 4'h0;
        s_axi_awvalid = 1;
        #20;
        s_axi_wdata = 32'h1;
        s_axi_wvalid = 1;
        s_axi_bready = 1;
        wait (s_axi_awready && s_axi_wready);
        #10;
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        wait (s_axi_bvalid);
        #10;
        s_axi_bready = 0;
        
        // Read from start register (0x00)
        s_axi_araddr = 4'h0;
        s_axi_arvalid = 1;
        s_axi_rready = 1;
        wait (s_axi_arready);
        #10;
        s_axi_arvalid = 0;
        wait (s_axi_rvalid);
        #10;
        s_axi_rready = 0;
        
        // Write to seed register (0x08)
        s_axi_awaddr = 4'h8;
        s_axi_awvalid = 1;
        s_axi_wdata = 32'hF2;
        s_axi_wvalid = 1;
        s_axi_bready = 1;
        wait (s_axi_awready && s_axi_wready);
        #10;
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        wait (s_axi_bvalid);
        #10;
        s_axi_bready = 0;

        #100;
        
        // Write to taps register (0x0C)
        s_axi_awaddr = 4'hC;
        s_axi_awvalid = 1;
        s_axi_wdata = 32'hB2;
        s_axi_wvalid = 1;
        s_axi_bready = 1;
        wait (s_axi_awready && s_axi_wready);
        #10;
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        wait (s_axi_bvalid);
        #10;
        s_axi_bready = 0;
        
        // Read from seed register (0x08)
        s_axi_araddr = 4'h8;
        s_axi_arvalid = 1;
        s_axi_rready = 1;
        wait (s_axi_arready);
        #10;
        s_axi_arvalid = 0;
        wait (s_axi_rvalid);
        #10;
        s_axi_rready = 0;
        
        #3000;
        
         // Write to stop register (0x0C)
        s_axi_awaddr = 4'h4;
        s_axi_awvalid = 1;
        s_axi_wdata = 1'b1;
        s_axi_wvalid = 1;
        s_axi_bready = 1;
        wait (s_axi_awready && s_axi_wready);
        #10;
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        wait (s_axi_bvalid);
        #10;
        s_axi_bready = 0;

        #400;


        dut.m_axi_ram.print_memory();
    


        $finish;

    end
endmodule
