module top_fpgam (
    input  wire        CLK100MHZ,
    input  wire        BTNC,
    input  wire [3:0]  SW,

    output wire [15:0] LED,
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    // =========================================================
    // INTERNAL SIGNALS
    // =========================================================

    wire gated_clk;
    wire clock_enable;
    wire idle;

    wire [1:0] state;

    wire [15:0] counter;
    wire [15:0] previous_counter;

    wire count_tick;


    // =========================================================
    // CLOCK CONTROLLER
    // =========================================================

    clock_controller controller (
        .clk          (CLK100MHZ),
        .reset        (BTNC),

        .sleep_req    (SW[0]),
        .wake_req     (SW[1]),

        .clock_enable (clock_enable),
        .idle         (idle),
        .state        (state)
    );


    // =========================================================
    // BUFGCE CLOCK GATING
    // =========================================================

    clock_gate_bufgce clock_gate (
        .clk          (CLK100MHZ),
        .clock_enable (clock_enable),
        .gated_clk    (gated_clk)
    );


    // =========================================================
    // FUNCTIONAL COUNTER
    // =========================================================

    functional_counter counter_block (
        .gated_clk        (gated_clk),
        .reset            (BTNC),

        .counter          (counter),
        .previous_counter (previous_counter),
        .count_tick       (count_tick)
    );


    // =========================================================
    // 4-DIGIT 7-SEGMENT DISPLAY
    // =========================================================

    seven_segment display (
        .clk   (CLK100MHZ),
        .reset (BTNC),
        .value (counter),

        .seg   (seg),
        .an    (an),
        .dp    (dp)
    );


    // =========================================================
    // LED STATUS INDICATORS
    // =========================================================

    // LED0 = Clock Enable
    assign LED[0] = clock_enable;

    // LED1 = Idle / Sleep
    assign LED[1] = idle;

    // LED2 = Sleep Request
    assign LED[2] = SW[0];

    // LED3 = Wake Request
    assign LED[3] = SW[1];

    // LED4 = Counter Tick
    assign LED[4] = count_tick;

    // LED5 = Counter LSB
    // Changes every 0.5 second
    assign LED[5] = counter[0];

    // LED6 = FSM State bit 0
    assign LED[6] = state[0];

    // LED7 = FSM State bit 1
    assign LED[7] = state[1];

    // LED8 = Counter Changed
    assign LED[8] = (counter != previous_counter);

    // LED9 = Counter Same
    // Useful for demonstrating counter freeze
    assign LED[9] = (counter == previous_counter);

    // LED10 = System Active
    assign LED[10] = clock_enable & ~idle;

    // LED11 = Sleep Mode
    assign LED[11] = idle;

    // LED12 = Wake Request
    assign LED[12] = SW[1];

    // LED13 = Counter MSB
    assign LED[13] = counter[13];

    // LED14 = System Indicator
    assign LED[14] = 1'b1;

    // LED15 = PASS Indicator
    //
    // PASS if:
    // 1. System is running normally
    // OR
    // 2. System is sleeping and counter is frozen
    assign LED[15] =
           (clock_enable & ~idle) |
           (idle & (counter == previous_counter));

endmodule