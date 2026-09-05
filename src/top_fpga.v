module top_fpga (

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

    wire        gated_clk;

    wire        clock_enable;
    wire        idle;

    wire [1:0]  state;

    wire [15:0] counter;
    wire [15:0] previous_counter;

    wire        count_tick;


    // =========================================================
    // CLOCK CONTROLLER
    // =========================================================
    // SW0 = Sleep Request
    // SW1 = Wake Request
    //
    // clock_enable = 1 -> system clock allowed
    // clock_enable = 0 -> system clock stopped
    //
    // idle = 1 -> system is sleeping
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
    // GLITCH-FREE FPGA CLOCK GATING
    // =========================================================