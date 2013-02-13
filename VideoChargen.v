module VideoChargen (
    input CLK,
    input RESET,

    input HSYNC_IN,
    input VSYNC_IN,
    input HBLANK,
    input VBLANK,
    input [9:0] H_POS,
    input [9:0] V_POS,

    output [10:0] CHAR_A,
    input [7:0] CHAR,

    output [10:0] CGROM_A,
    input [7:0] CHAR_DATA,

    output HSYNC,
    output VSYNC,
    output OUT

);

    reg HSYNC_1, HSYNC_2, VSYNC_1, VSYNC_2;
    reg BLANK_1, BLANK_2, INVERT_1;

    reg [2:0] H_POS_1, H_POS_2;
    reg [3:0] V_POS_1;

    always @ (posedge CLK)
    begin
        HSYNC_1 <= HSYNC_IN;
        HSYNC_2 <= HSYNC_1;
        VSYNC_1 <= VSYNC_IN;
        VSYNC_2 <= VSYNC_1;
        BLANK_1 <= HBLANK || VBLANK;
        BLANK_2 <= BLANK_1;

        H_POS_1 <= H_POS[2:0];
        H_POS_2 <= H_POS_1;

        V_POS_1 <= V_POS[3:0];

        INVERT_1 <= CHAR[7];
    end

    assign HSYNC = HSYNC_2;
    assign VSYNC = VSYNC_2;

/* verilator lint_off WIDTH */
    assign CGROM_A = CHAR[6:0] * 16 + V_POS_1;
    assign CHAR_A  = H_POS / 8 + V_POS / 16 * 64;
/* verilator lint_on WIDTH */

    assign OUT = BLANK_2 ? 1'b0 : (CHAR_DATA[7 - H_POS_2] ^ INVERT_1);

endmodule
