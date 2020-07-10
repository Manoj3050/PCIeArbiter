module tb_pcie_arbiter();

    parameter CHANNELS = 8;
    reg                       clk;
    reg                       rst_n;
    reg [CHANNELS-1:0]        pci_req;
    reg                       pci_frame;

    wire [CHANNELS-1:0]   pci_grnt;

    pcie_arbiter inst(
        clk,
        rst_n,
        pci_req,
        pci_frame,
        pci_grnt
    );

    initial begin
        
        clk = 0;
        rst_n = 1;
        pci_req = 0;
        pci_frame = 0;
        #100;
        rst_n = 0;
        #100;
        rst_n = 1;
        @(posedge clk);
        pci_req = 8'b10010000;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        pci_frame = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        pci_frame = 0;
        pci_req = 8'b0010100;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        pci_frame = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        pci_frame = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        pci_frame = 1;
        $finish;

    end

    always #5 clk = ~clk;
endmodule