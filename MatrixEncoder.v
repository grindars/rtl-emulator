(* priority_extract = "force" *)
module MatrixEncoder (
    input [7:0] SEL_MASK,
    output reg [2:0] SELECTED_ROW
);

    always @ (SEL_MASK or SELECTED_ROW)
        if(!SEL_MASK[0])
            SELECTED_ROW = 3'h0;
        else if(!SEL_MASK[1])
            SELECTED_ROW = 3'h1;
        else if(!SEL_MASK[2])
            SELECTED_ROW = 3'h2;
        else if(!SEL_MASK[3])
            SELECTED_ROW = 3'h3;
        else if(!SEL_MASK[4])
            SELECTED_ROW = 3'h4;
        else if(!SEL_MASK[5])
            SELECTED_ROW = 3'h5;
        else if(!SEL_MASK[6])
            SELECTED_ROW = 3'h6;
        else if(!SEL_MASK[7])
            SELECTED_ROW = 3'h7;
        else
            SELECTED_ROW = 3'h0;
endmodule
