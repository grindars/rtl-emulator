module i8255(
    input CLK,
    input RESET,
    input [7:0] DIN,
    output reg [7:0] DOUT,
    input [1:0] A,
    input CS,
    input WR,
    input [7:0] PA_I,
    output [7:0] PA_O,
    output reg [7:0] PA_D,
    input [7:0] PB_I,
    output [7:0] PB_O,
    output reg [7:0] PB_D,
    input [7:0] PC_I,
    output [7:0] PC_O,
    output reg [7:0] PC_D
);

    wire [7:0] PA, PB, PC;
    reg [7:0] PA_REG, PB_REG, PC_REG, CTRL;

    always @ (CS or A or DOUT or PA or PB or PC or CTRL)
        casez({CS, A})
        3'b0zz: DOUT = 8'hFF; // Deselected
        3'b100: DOUT = PA;    // Port A
        3'b101: DOUT = PB;    // Port B
        3'b110: DOUT = PC;    // Port C
        3'b111: DOUT = CTRL;  // Control register
        endcase

    always @ (posedge CLK)
        if(RESET)
        begin
            PA_REG <= 8'hFF;
            PB_REG <= 8'hFF;
            PC_REG <= 8'hFF;
            CTRL   <= 8'h9B;
        end
        else if(WR && CS)
            casez({ A, DIN[7], DIN[0] })
            4'b00zz: PA_REG <= DIN; // Port A
            4'b01zz: PB_REG <= DIN; // Port B
            4'b10zz: PC_REG <= DIN; // Port C
            4'b111z: CTRL   <= DIN; // Control
            4'b1100: PC_REG <= PC_REG & ~(1 << DIN[3:1]); // Bit reset
            4'b1101: PC_REG <= PC_REG | (1 << DIN[3:1]);     // Bit set
            endcase

    assign PA = (PA_O & PA_D) | (PA_I & ~PA_D);
    assign PB = (PB_O & PB_D) | (PB_I & ~PB_D);
    assign PC = (PC_O & PC_D) | (PC_I & ~PC_D);

    // TODO: only mode 0 implemented
    // synthesis translate_off
    always @ (posedge CLK)
        if(CS && WR && A == 2'b11 && DIN[7] == 1'b0 && (DIN[2] != 1'b0 || DIN[6:5] != 2'b00))
            $write("i8255: Attempted to set non-zero mode\n");
    // synthesis translate_on

    assign PA_O = PA_REG;
    assign PB_O = PB_REG;
    assign PC_O = PC_REG;

    always @ (CTRL or PA_D)
        if(CTRL[4])
            PA_D[7:0] = 8'b0000_0000;
        else
            PA_D[7:0] = 8'b1111_1111;

    always @ (CTRL or PB_D)
        if(CTRL[1])
            PB_D[7:0] = 8'b0000_0000;
        else
            PB_D[7:0] = 8'b1111_1111;

    always @ (CTRL or PC_D)
    begin
        if(CTRL[0])
            PC_D[3:0] = 4'b0000;
        else
            PC_D[3:0] = 4'b1111;

        if(CTRL[3])
            PC_D[7:4] = 4'b0000;
        else
            PC_D[7:4] = 4'b1111;
    end
endmodule
