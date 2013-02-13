

module VRAM (
    input CLK,
    input RESET,
    input CS,
    input WR,
    input [10:0] A,
    input [7:0] DIN,
    output reg [7:0] DOUT,
    output WAIT,

    input CLK_VIDEO,
    input [10:0] CHAR_A,
    output reg [7:0] CHAR
);

    reg [7:0] VRAM [0:2047];
    wire VRAM_SEL;
    reg CYCLE;
    wire CS, EN;

    always @ (posedge CLK)
    begin
        if(EN)
        begin
            if(WR)
            begin
                VRAM[A] <= DIN;
                DOUT <= DIN;
            end
            else
                DOUT <= VRAM[A];
        end

        if(RESET)
            DOUT <= 8'hFF;
    end

    always @ (posedge CLK)
        if(RESET)
            CYCLE <= 1'b0;
        else
            CYCLE <= CS;

    assign WAIT = CS && !CYCLE;
    assign EN = WAIT;

    always @ (posedge CLK_VIDEO)
        CHAR <= VRAM[CHAR_A];

    assign VRAM_SEL = CS && !RESET;

endmodule
