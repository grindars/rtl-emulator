module IRAM (
    CLK, RESET, CS, RD, WR, WAIT,
    A, DI, DO
);
    parameter WIDTH = 8;
    parameter DEPTH = 16;

    input CLK;
    input RESET;
    input CS;
    input RD;
    input WR;
    output WAIT;
    input [DEPTH - 1:0] A;
    input [WIDTH - 1:0] DI;
    output reg [WIDTH - 1:0] DO;

    reg [WIDTH - 1:0] MEM [0:(1 << DEPTH) - 1];
    reg CYCLE;
    wire SELECTED, EN;

    always @ (posedge CLK)
    begin
        if(EN)
        begin
            if(WR)
            begin
                MEM[A] <= DI;
                DO <= DI;
            end
            else
            begin
                DO <= MEM[A];
            end
        end

        if(RESET)
            DO <= 0;
    end

    always @ (posedge CLK)
        if(RESET)
            CYCLE <= 1'b0;
        else
            CYCLE <= SELECTED;

    assign SELECTED = (RD || WR) && CS;
    assign WAIT = SELECTED && !CYCLE;
    assign EN = WAIT;

    integer i;
    initial
    begin
        for(i = 0; i < 1 << DEPTH; i = i + 1)
            MEM[i] = 0;
    end

endmodule