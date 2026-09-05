module clock_gate_bufgce (
    input  wire clk,
    input  wire clock_enable,
    output wire gated_clk
);

    BUFGCE clock_gate_inst (
        .I  (clk),
        .CE (clock_enable),
        .O  (gated_clk)
    );

endmodule