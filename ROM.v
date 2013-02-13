module ROM(
    CLK,
    RESET,
    A,
    DO,
    CS
);

    parameter DEPTH = 8;
    parameter WIDTH = 8;
    parameter INIT_FILE = "";

    input      CLK;
    input      RESET;
    input      [DEPTH - 1:0] A;
    output reg [WIDTH - 1:0] DO;
    input      CS;

    reg        [WIDTH - 1:0] MEM [0:(1 << DEPTH) - 1];

    always @ (posedge CLK)
        if(RESET)
            DO <= 8'hFF;
        else
        begin
            DO <= MEM[A];
        end

    integer i;
    initial
        $readmemh(INIT_FILE, MEM);

endmodule
