module VideoController (
    input CLK,
    input CLK_VIDEO,
    input RESET,
    input CS,
    input WR,
    input [10:0] A,
    input [7:0] DIN,
    output [7:0] DOUT,
    output WAIT,

    output HSYNC,
    output VSYNC,
    output [2:0] VGA_R,
    output [2:0] VGA_G,
    output [1:0] VGA_B
);

    wire [10:0] CHAR_A, CGROM_A;
    wire [7:0] CHAR, CHAR_DATA;
    wire [9:0] H_POS, V_POS;
    wire HBLANK, VBLANK, HSYNC_PRE, VSYNC_PRE, OUT;

    assign VGA_R = OUT ? 3'b110 : 3'b000;
    assign VGA_G = OUT ? 3'b110 : 3'b000;
    assign VGA_B = OUT ? 2'b11  : 2'b00;

    VRAM vram (
        .CLK(CLK),
        .RESET(RESET),
        .CS(CS),
        .WR(WR),
        .A(A),
        .DIN(DIN),
        .DOUT(DOUT),
        .WAIT(WAIT),
        .CLK_VIDEO(CLK_VIDEO),
        .CHAR_A(CHAR_A),
        .CHAR(CHAR)
    );

    VideoSync # (
        .H_VISIBLE(512),
        .H_FRONT(16),
        .H_SYNC(96),
        .H_BACK(176),

        .V_VISIBLE(480),
        .V_FRONT(10),
        .V_SYNC(2),
        .V_BACK(33)
    ) sync (
        .CLK(CLK_VIDEO),
        .RESET(RESET),

        .HSYNC(HSYNC_PRE),
        .VSYNC(VSYNC_PRE),

        .HBLANK(HBLANK),
        .VBLANK(VBLANK),
        .H_POS(H_POS),
        .V_POS(V_POS)
    );

    VideoChargen chargen (
        .CLK(CLK_VIDEO),
        .RESET(RESET),

        .HSYNC_IN(HSYNC_PRE),
        .VSYNC_IN(VSYNC_PRE),
        .HBLANK(HBLANK),
        .VBLANK(VBLANK),

        .H_POS(H_POS),
        .V_POS(V_POS),

        .CHAR_A(CHAR_A),
        .CHAR(CHAR),

        .CGROM_A(CGROM_A),
        .CHAR_DATA(CHAR_DATA),

        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .OUT(OUT)
    );

    CGROM rom (
        .CLK(CLK_VIDEO),
        .RESET(RESET),

        .A(CGROM_A),
        .DO(CHAR_DATA)
    );

endmodule
