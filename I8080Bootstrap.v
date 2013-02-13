module I8080Bootstrap(
    input CS,
    output reg [7:0] DO,
    input [1:0] A
);

    parameter VECTOR = 16'hFF00;

    always @ (CS or DO or A)
        casez({ CS, A })
        3'b0zz: DO = 8'hFF;
        3'b100: DO = 8'hF3;
        3'b101: DO = 8'hC3;
        3'b110: DO = VECTOR[7:0];
        3'b111: DO = VECTOR[15:8];
        endcase

endmodule
