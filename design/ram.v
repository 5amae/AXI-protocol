module axi_ram (

    input aclk,
    input aresetn,

    input [31:0]s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,
    output reg [31:0]m_axis_tdata
);

reg [31:0] storing;
reg [7:0] mem [0:288];
integer a;
integer i,j,k,l,m,n,o,p;

always@(posedge aclk)
begin
    if(aresetn ==0)
    begin
        for (a = 0; a <= 287; a = a + 1)
        begin
            mem[a] <= 8'b0; // Clear each memory location
        end
    s_axis_tready<=0;
    i<=32;
    j<=64;
    k<=96;
    l<=128;
    m<=160;
    n<=192;
    o<=224;
    p<=256;
    end
    else if(s_axis_tvalid ==1)
    begin
        storing <=s_axis_tdata;
        s_axis_tready <= 1;

    end
end

always@(posedge aclk)
begin
    if(s_axis_tvalid ==1 && s_axis_tready ==1) // pretty self explanatory code
    begin
    
    case(storing[31:28])
    4'b0000:if (i < 63 && storing!=8'b0)
    begin
        mem[0] <= mem[0] +1;
        mem[i] <= storing[7:0]; // i is for storing the number of times it is iterated almost like count only u can check it in the output
        i <= i+1;
        s_axis_tready <= 0;
    end
    4'b0001:if (j < 95)
    begin
        mem[4] <= mem[4] +1;
        mem[j] <= storing[7:0];
        j <= j+1;
        s_axis_tready <= 0;
    end
    4'b0010:if (k < 127)
    begin
        mem[8] <= mem[8] +1;
        mem[k] <= storing[7:0];  // i suggest using iverilog to check the output

        k <=k+1;
        s_axis_tready <= 0;
    end
    4'b0011:if (l < 159)
    begin
        mem[12] <= mem[12] +1;
        mem[l] <= storing[7:0];
        l <=l +1;
        s_axis_tready <= 0;
    end
    4'b0100:if (m < 191)
    begin
        mem[16] <= mem[16] +1;
        mem[m] <= storing[7:0];
        m <=m+1;
        s_axis_tready <= 0;
    end
    4'b0101:if (n < 223)
    begin
        mem[20] <= mem[20] +1;
        mem[n] <= storing[7:0];
        n <=n+1;
        s_axis_tready <= 0;
    end
    4'b0110:if (o < 255)
    begin
        mem[24] <= mem[24] +1;
        mem[o] <= storing[7:0];
        o <= o+1;
        s_axis_tready <= 0;
    end
    4'b0111:if (p < 287)
    begin
        mem[28] <= mem[28] +1;
        mem[p] <= storing[7:0];
        p <= p+1;
        s_axis_tready <= 0;
    end
    endcase
    end
end

task print_memory;
    integer addr;
    integer file;
    begin
        file = $fopen("ram_contents.txt", "w"); 
        if (file) begin
            $fwrite(file, "          Address   value\n");
            for (addr = 0; addr < 288; addr = addr + 1) begin
                $fwrite(file, "%d:        %h\n",addr, mem[addr]); 
            end
            $fclose(file); 
        end else begin
            $display("unable to open ram_contents.txt"); /// all this works only in icarus so pls try in this only
        end
    end
endtask





endmodule