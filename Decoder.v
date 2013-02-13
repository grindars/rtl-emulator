module Decoder (
    input CLK,
    input RESET,

    input [15:0] A,
    input MREQ,
    input IORQ,

    output SEL_IRAM,
    output SEL_BOOTSTRAP,
    output SEL_IROM,
    output SEL_VIDEO,
    output SEL_KEYBOARD,
    output SEL_TAPE
);

    `define SEL_RAM         3'b000
    `define SEL_BOOT        3'b001
    `define SEL_ROM         3'b010
    `define SEL_VIDEO       3'b011
    `define SEL_I8255       3'b100
    `define SEL_TAPE        3'b101
    `define SEL_NONE        3'b111

    reg BOOT_ACTIVE;
    reg [2:0] SEL_IDX;
    reg [7:0] SEL;

    always @ (SEL_IDX or SEL)
        case(SEL_IDX)
        3'b000: SEL = 8'b0000_0001;
        3'b001: SEL = 8'b0000_0010;
        3'b010: SEL = 8'b0000_0100;
        3'b011: SEL = 8'b0000_1000;
        3'b100: SEL = 8'b0001_0000;
        3'b101: SEL = 8'b0010_0000;
        3'b110: SEL = 8'b0100_0000;
        3'b111: SEL = 8'b1000_0000;
        endcase

    always @ (posedge CLK)
        if(RESET)
            BOOT_ACTIVE <= 1'b1;
        else if(SEL_IROM)
            BOOT_ACTIVE <= 1'b0;

    always @ (MREQ or IORQ or A or SEL_IDX or BOOT_ACTIVE)
        if(MREQ)
        begin
            if(A[15:11] == 5'b11111)
                SEL_IDX = `SEL_ROM;
            else if(A[15:12] == 4'b1110)
                SEL_IDX = `SEL_VIDEO;
            else if(A[15:2] == 14'b0 && BOOT_ACTIVE)
                SEL_IDX = `SEL_BOOT;
            else
                SEL_IDX = `SEL_RAM;
        end
        else if(IORQ)
        begin
            if(A[7:2] == 6'b00_0001)
                SEL_IDX = `SEL_I8255;
            else if(A[7:0] == 8'b10100001)
                SEL_IDX = `SEL_TAPE;
            else
            begin
                $write("Unhandled port I/O to address %h\n", A);

                SEL_IDX = `SEL_NONE;
            end
        end
        else
            SEL_IDX = `SEL_NONE;


    assign SEL_IRAM = SEL[0];
    assign SEL_BOOTSTRAP = SEL[1];
    assign SEL_IROM = SEL[2];
    assign SEL_VIDEO = SEL[3];
    assign SEL_KEYBOARD = SEL[4];

endmodule
