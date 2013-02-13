module VideoSync (
    CLK,
    RESET,

    HSYNC,
    VSYNC,

    HBLANK,
    VBLANK,

    H_POS,
    V_POS
);

`include "math.v"

`define H_TOTAL (H_FRONT + H_VISIBLE + H_BACK + H_SYNC)
`define V_TOTAL (V_FRONT + V_VISIBLE + V_BACK + V_SYNC)

    parameter H_VISIBLE = 1;
    parameter H_FRONT   = 1;
    parameter H_SYNC    = 1;
    parameter H_BACK    = 1;

    parameter V_VISIBLE = 1;
    parameter V_FRONT   = 1;
    parameter V_SYNC    = 1;
    parameter V_BACK    = 1;

    parameter H_WIDTH = CLogB2(`H_TOTAL);
    parameter V_WIDTH = CLogB2(`V_TOTAL);

    input CLK;
    input RESET;
    output HSYNC;
    output VSYNC;
    output HBLANK;
    output VBLANK;

    reg [H_WIDTH - 1:0] H_COUNT;
    reg [V_WIDTH - 1:0] V_COUNT;

    output [H_WIDTH - 1:0] H_POS;
    output [V_WIDTH - 1:0] V_POS;

    always @ (posedge CLK)
        if(RESET)
        begin
            H_COUNT <= 0;
            V_COUNT <= 0;
        end
        else
        begin
            if(H_COUNT == `H_TOTAL - 1)
            begin
                H_COUNT <= 0;

                if(V_COUNT == `V_TOTAL - 1)
                    V_COUNT <= 0;
                else
                    V_COUNT <= V_COUNT + 1;
            end
            else
                H_COUNT <= H_COUNT + 1;
        end

    assign HBLANK = (H_COUNT < H_FRONT) || (H_COUNT >= H_FRONT + H_VISIBLE);
    assign VBLANK = (V_COUNT < V_FRONT) || (V_COUNT >= V_FRONT + V_VISIBLE);
    assign HSYNC  = !(H_COUNT >= `H_TOTAL - H_SYNC);
    assign VSYNC  = !(V_COUNT >= `V_TOTAL - V_SYNC);
    assign H_POS = H_COUNT - H_FRONT;
    assign V_POS = V_COUNT - V_FRONT;

endmodule
