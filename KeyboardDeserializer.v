module KeyboardDeserializer (
    input CLK,
    input RESET,

    input KEY_STB,
    input [11:0] KEY_OP,
    output reg KEY_BUSY,

    output reg [7:0] KEY_MOD,
    output [2:0] ROW_A,
    output reg ROW_WR,
    input [7:0] ROW_DI,
    output [7:0] ROW_DO
);

`define STATE_IDLE      2'b00
`define STATE_ROWWRITE  2'b01
`define STATE_WAITEND   2'b10

    reg [1:0] STATE;

    always @ (posedge CLK)
        if(RESET)
        begin
            STATE <= `STATE_IDLE;
            KEY_BUSY <= 1'b0;
            KEY_MOD <= 8'hFF;
            ROW_WR <= 1'b0;
        end
        else
            case(STATE)
            `STATE_IDLE:
                if(KEY_STB)
                begin
                    KEY_BUSY <= 1'b1;

                    if(KEY_OP[11])
                    begin
                        KEY_MOD <= KEY_OP[7:0];
                        STATE <= `STATE_WAITEND;
                    end
                    else
                    begin
                        ROW_WR <= 1'b1;
                        STATE <= `STATE_ROWWRITE;
                    end
                end

            `STATE_ROWWRITE: STATE <= `STATE_WAITEND;
            `STATE_WAITEND:
            begin
                ROW_WR <= 1'b0;
                KEY_BUSY <= 1'b0;
                if(!KEY_STB)
                    STATE <= `STATE_IDLE;
            end
            2'b11: ;
            endcase

    assign ROW_A = KEY_OP[10:8];
    assign ROW_DO = KEY_OP[7:0];

endmodule
