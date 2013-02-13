module RowRAM (
    input CLK,
    input RESET,
    input [2:0] A,
    input WR,
    input [7:0] DI,
    output reg [7:0] DO,

    input [7:0] KEY_SEL,
    output reg [7:0] KEY_VAL
);

    reg [7:0] RAM [0:7];
    wire [2:0] ROW_A;

    MatrixEncoder enc (
        .SEL_MASK(KEY_SEL),
        .SELECTED_ROW(ROW_A)
    );

    always @ (posedge CLK)
        if(RESET)
            DO <= 8'h00;
        else
        begin
            DO <= RAM[A];

            if(WR)
            begin
                RAM[A] <= DI;
            end
        end

    always @ (posedge CLK)
        if(RESET)
            KEY_VAL <= 8'h00;
        else
            KEY_VAL <= RAM[ROW_A];

endmodule
