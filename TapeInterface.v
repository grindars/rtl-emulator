module TapeInterface (
    input CLK,
    input RESET,

    input RD,
    input WR,
    input CS,
    input [7:0] DIN,
    output reg [7:0] DOUT,

    input TAPE_IN,
    output reg TAPE_OUT
);

    always @ (posedge CLK)
        if(RESET)
        begin
            DOUT <= 8'hFF;
            TAPE_OUT <= 1'b0;
        end
        else
        begin
            if(CS && RD)
                DOUT <= { 7'b0, TAPE_IN };
            else
                DOUT <= 8'hFF;

            if(CS && WR)
                TAPE_OUT <= DIN[0];
        end

endmodule
