module pcie_arbiter(
    clk,
    rst_n,
    pci_req,
    pci_frame,
    pci_grnt
);

    parameter CHANNELS = 8;
    input                       clk;
    input                       rst_n;
    input [CHANNELS-1:0]        pci_req;
    input                       pci_frame;

    output reg [CHANNELS-1:0]   pci_grnt;


    reg     [1:0]               cstate; // IDLE-0, REQ Granted - 1, WAIT for TR-2, TR-3
    reg     [1:0]               nstate;

    reg     [CHANNELS-1:0]      pci_grnt_n;

    reg                         req_granted;

    reg     [CHANNELS-1:0]      last_grant;

    reg     [3:0]               expire_counter;

    wire                        expired;

    assign expired = (expire_counter == 4'd15);

    always@(*) begin
        nstate = 2'd0;
        case(cstate)
            2'd0 : begin
                if(req_granted)
                    nstate = 2'd1;
                else
                    nstate = 2'd0;
            end
            2'd1 : begin
                nstate = 2'd2;
            end
            2'd2 : begin
                if(expired)
                    nstate = 2'd0;
                else if(pci_frame)
                    nstate = 2'd3;
                else
                    nstate = 2'd2;
            end
            2'd3 : begin
                if(pci_frame)
                    nstate = 2'd3;
                else
                    nstate = 2'd0;
            end
        endcase
    end

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            cstate <= 2'd0;
        else
            cstate <= nstate;
    end

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            expire_counter <= 4'd0;
        else
            if(cstate == 2'd2)
                expire_counter <= expire_counter + 4'd1;
            else
                expire_counter <= 4'd0;
    end

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            last_grant <= 8'd0;
        else
            if(cstate == 2'd1)
                last_grant <= pci_grnt_n;
    end

    always@(*) begin
        pci_grnt_n = 8'd0;
        if(cstate == 2'd0) begin
            if(pci_req[7] == 1'b1)
                pci_grnt_n = 8'b10000000;
            else if(pci_req[6] == 1'b1)
                pci_grnt_n = 8'b01000000;
            else if(pci_req[5] == 1'b1)
                pci_grnt_n = 8'b00100000;
            else begin
                if(~last_grant[4] & pci_req[4])
                    pci_grnt_n = 8'b00010000;
                else if(~last_grant[3] & pci_req[3])
                    pci_grnt_n = 8'b00001000;
                else if(~last_grant[2] & pci_req[2])
                    pci_grnt_n = 8'b00000100;
                else if(~last_grant[1] & pci_req[1])
                    pci_grnt_n = 8'b00000010;
                else if(~last_grant[0] & pci_req[0])
                    pci_grnt_n = 8'b00000001;
            end
        end
        else begin
            pci_grnt_n = pci_grnt;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(~rst_n)
            pci_grnt <= 8'd0;
        else
            pci_grnt <= pci_grnt_n;
    end

    always@(*) begin
        if((cstate == 2'b0) & (pci_req != 8'd0 ))
            req_granted = 1'b1;
        else
            req_granted = 1'b0;
    end

endmodule