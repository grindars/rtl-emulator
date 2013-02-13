module TV80SI (
    input CLK,
    input RESET,
    input WAIT,
    input INT,
    input NMI,
    input BUSRQ,
    input [7:0] DI,
    output M1,
    output MREQ,
    output IORQ,
    output RD,
    output WR,
    output RFSH,
    output HALT,
    output BUSAK,
    output [15:0] A,
    output [7:0] DO
);

    wire nM1, nMREQ, nIORQ, nRD, nWR, nRFSH, nHALT, nBUSAK;

    tv80s #(
        .Mode(0),
        .T2Write(0),
        .IOWait(0)
    ) tv80 (
        .m1_n(nM1),
        .mreq_n(nMREQ),
        .iorq_n(nIORQ),
        .rd_n(nRD),
        .wr_n(nWR),
        .rfsh_n(nRFSH),
        .halt_n(nHALT),
        .busak_n(nBUSAK),
        .A(A),
        .dout(DO),
        .reset_n(~RESET),
        .clk(CLK),
        .wait_n(~WAIT),
        .int_n(~INT),
        .nmi_n(~NMI),
        .busrq_n(~BUSRQ),
        .di(DI)
    );

    assign M1 = ~nM1;
    assign MREQ = ~nMREQ;
    assign IORQ = ~nIORQ;
    assign RD = ~nRD;
    assign WR = ~nWR;
    assign RFSH = ~nRFSH;
    assign HALT = ~nHALT;
    assign BUSAK = ~nBUSAK;

endmodule
