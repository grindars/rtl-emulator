module KeyboardController (
    input CLK,
    input RESET,
    input [7:0] DI,
    output [7:0] DO,
    input [1:0] A,
    input CS,
    input RD,
    input WR,

    input KEY_STB,
    input [11:0] KEY_OP,
    output KEY_BUSY
);

// Key operation layout:
// [11:11] - select
//            0 - RAM
//            1 - modifier
// [10:8]  - address (don't care for modifier)
// [7:0]   - data

    wire [7:0] KEY_SEL, KEY_VAL, KEY_MOD;
    wire [2:0] ROW_A;
    wire ROW_WR;
    wire [7:0] ROW_DI, ROW_DO;

    i8255 i8255 (
        .CLK(CLK),
        .RESET(RESET),
        .DIN(DI),
        .DOUT(DO),
        .A(A),
        .CS(CS),
        .WR(WR),
        .PA_I(8'b0000_0000),
        .PA_O(KEY_SEL),
        .PA_D(),
        .PB_I(KEY_VAL),
        .PB_O(),
        .PB_D(),
        .PC_I(KEY_MOD),
        .PC_O(),
        .PC_D()
    );

    RowRAM ram (
        .CLK(CLK),
        .RESET(RESET),
        .A(ROW_A),
        .DI(ROW_DI),
        .DO(ROW_DO),
        .WR(ROW_WR),
        .KEY_SEL(KEY_SEL),
        .KEY_VAL(KEY_VAL)
    );

    KeyboardDeserializer deser (
        .CLK(CLK),
        .RESET(RESET),
        .KEY_STB(KEY_STB),
        .KEY_OP(KEY_OP),
        .KEY_BUSY(KEY_BUSY),
        .KEY_MOD(KEY_MOD),
        .ROW_A(ROW_A),
        .ROW_WR(ROW_WR),
        .ROW_DI(ROW_DO),
        .ROW_DO(ROW_DI)
    );

endmodule
