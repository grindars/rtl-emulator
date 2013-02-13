module UT88 (
    input CLK,
    input RESET,

    input CLK_VIDEO,
    output HSYNC,
    output VSYNC,
    output [2:0] VGA_R,
    output [2:0] VGA_G,
    output [1:0] VGA_B,

    input KEY_STB,
    input [11:0] KEY_OP,
    output KEY_BUSY
);

    wire WAIT, INT, NMI, BUSRQ, M1, MREQ, IORQ, RD, WR, RFSH, HALT, BUSAK;
    wire [7:0] DI, DO, IRAM_DO, BOOTSTRAP_DO, IROM_DO, VIDEO_DO, KEYBOARD_DO;
    wire [7:0] TAPE_DO;
    wire [15:0] A;

    wire SEL_IRAM, SEL_BOOTSTRAP, SEL_IROM, SEL_VIDEO, SEL_KEYBOARD, SEL_TAPE;
    wire WAIT_IRAM, WAIT_VIDEO;

    wire TAPE_IN, TAPE_OUT;

    TV80SI cpu (
        .CLK(CLK),
        .RESET(RESET),
        .WAIT(WAIT),
        .INT(INT),
        .NMI(NMI),
        .BUSRQ(BUSRQ),
        .DI(DI),
        .M1(M1),
        .MREQ(MREQ),
        .IORQ(IORQ),
        .RD(RD),
        .WR(WR),
        .RFSH(RFSH),
        .HALT(HALT),
        .BUSAK(BUSAK),
        .A(A),
        .DO(DO)
    );

    Decoder decoder (
        .CLK(CLK),
        .RESET(RESET),
        .A(A),
        .MREQ(MREQ),
        .IORQ(IORQ),
        .SEL_IRAM(SEL_IRAM),
        .SEL_BOOTSTRAP(SEL_BOOTSTRAP),
        .SEL_IROM(SEL_IROM),
        .SEL_VIDEO(SEL_VIDEO),
        .SEL_KEYBOARD(SEL_KEYBOARD),
        .SEL_TAPE(SEL_TAPE)
    );

    I8080Bootstrap # (
        .VECTOR(16'hF800)
    ) bootstrap (
        .CS(SEL_BOOTSTRAP),
        .DO(BOOTSTRAP_DO),
        .A(A[1:0])
    );

    IRAM #(
        .WIDTH(8),
        .DEPTH(16)
    ) iram (
        .CLK(CLK),
        .RESET(RESET),
        .CS(SEL_IRAM),
        .RD(RD),
        .WR(WR),
        .WAIT(WAIT_IRAM),
        .A(A),
        .DI(DO),
        .DO(IRAM_DO)
    );

    ROM #(
        .DEPTH(11),
        .WIDTH(8),
        .INIT_FILE("roms/monitorf.dat")
    ) irom (
        .CLK(CLK),
        .RESET(RESET),
        .A(A[10:0]),
        .DO(IROM_DO),
        .CS(SEL_IROM)
    );

    VideoController video (
        .CLK(CLK),
        .CLK_VIDEO(CLK_VIDEO),
        .RESET(RESET),
        .CS(SEL_VIDEO),
        .WR(WR),
        .A(A[10:0]),
        .DIN(DO),
        .DOUT(VIDEO_DO),
        .WAIT(WAIT_VIDEO),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

    KeyboardController keyboard (
        .CLK(CLK),
        .RESET(RESET),
        .DI(DO),
        .DO(KEYBOARD_DO),
        .A(~A[1:0]),
        .CS(SEL_KEYBOARD),
        .RD(RD),
        .WR(WR),
        .KEY_STB(KEY_STB),
        .KEY_BUSY(KEY_BUSY),
        .KEY_OP(KEY_OP)
    );

    TapeInterface tape (
        .CLK(CLK),
        .RESET(RESET),
        .RD(RD),
        .WR(WR),
        .CS(SEL_TAPE),
        .DIN(DO),
        .DOUT(TAPE_DO),
        .TAPE_IN(TAPE_IN),
        .TAPE_OUT(TAPE_OUT)
    );

    assign WAIT = WAIT_IRAM || WAIT_VIDEO;
    assign INT = 1'b0;
    assign NMI = 1'b0;
    assign BUSRQ = 1'b0;

    assign DI =
        SEL_BOOTSTRAP ? BOOTSTRAP_DO :
        SEL_IRAM ? IRAM_DO :
        SEL_IROM ? IROM_DO :
        SEL_VIDEO ? VIDEO_DO :
        SEL_KEYBOARD ? KEYBOARD_DO :
        SEL_TAPE ? TAPE_DO :
        8'hFF;
/*
    always @ (posedge CLK)
    begin
        if(IORQ)
            $write("IO ");
        else
            $write("   ");

        if(MREQ)
            $write("MEM ");
        else
            $write("    ");

        if(M1)
            $write("M1 ");
        else
            $write("   ");

        if(RD)
            $write("RD ");
        else
            $write("   ");

        if(WR)
            $write("WR ");
        else
            $write("   ");

        $write("%h -> [%h] -> %h ", DO, A, DI);

        if(WAIT)
            $write("WAIT");
        else
            $write("    ");

        $write("\n");
    end
*/
endmodule
