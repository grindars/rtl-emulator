module CGROM (
    input CLK,
    input RESET,

    input [10:0] A,
    output reg [7:0] DO
);

    reg [7:0] CGROM [0:2047];

    always @ (posedge CLK)
        if(RESET)
            DO <= 8'h00;
        else
            DO <= CGROM[A];

    initial
        $readmemh("roms/font.dat", CGROM);

endmodule
