`timescale 1ns / 1ps

module top_fpgam_tb;

    // =========================================================
    // TESTBENCH SIGNALS
    // =========================================================

    reg CLK100MHZ;
    reg BTNC;
    reg [3:0] SW;

    wire [15:0] LED;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;


    // =========================================================
    // DUT - DEVICE UNDER TEST
    // =========================================================

    top_fpgam DUT (

        .CLK100MHZ (CLK100MHZ),
        .BTNC      (BTNC),
        .SW        (SW),

        .LED       (LED),
        .seg       (seg),
        .an        (an),
        .dp        (dp)

    );


    // =========================================================
    // 100 MHz CLOCK
    // 10 ns PERIOD
    // =========================================================

    initial begin

        CLK100MHZ = 1'b0;

        forever #5 CLK100MHZ = ~CLK100MHZ;

    end


    // =========================================================
    // MAIN TEST
    // =========================================================

    initial begin

        // -----------------------------------------------------
        // INITIAL CONDITIONS
        // -----------------------------------------------------

        BTNC = 1'b1;

        SW = 4'b0000;

        $display("==========================================");
        $display(" LOW POWER CLOCK GATING TESTBENCH");
        $display("==========================================");


        // -----------------------------------------------------
        // RESET
        // -----------------------------------------------------

        #100;

        BTNC = 1'b0;

        #100;

        $display("");
        $display("RESET RELEASED");
        $display("State       = %b", DUT.state);
        $display("Clock Enable= %b", DUT.clock_enable);
        $display("Idle        = %b", DUT.idle);


        // -----------------------------------------------------
        // TEST 1 : ACTIVE MODE
        // SW0 = 0
        // SW1 = 0
        // -----------------------------------------------------

        SW = 4'b0000;

        $display("");
        $display("------------------------------------------");
        $display("TEST 1 : ACTIVE MODE");
        $display("SW = %b", SW);
        $display("------------------------------------------");

        #200;


        // -----------------------------------------------------
        // SPEED UP COUNTER FOR SIMULATION
        // -----------------------------------------------------
        // Force divider close to terminal count.
        // This avoids waiting 50 million cycles.
        // -----------------------------------------------------

        force DUT.counter_block.divider = 26'd49_999_998;

        #20;

        release DUT.counter_block.divider;

        #100;


        $display("Counter       = %d", DUT.counter);
        $display("Previous      = %d", DUT.previous_counter);
        $display("Count Tick    = %b", DUT.count_tick);
        $display("Clock Enable  = %b", DUT.clock_enable);
        $display("Idle          = %b", DUT.idle);


        // -----------------------------------------------------
        // TEST 2 : SLEEP
        // SW0 = 1
        // SW1 = 0
        // -----------------------------------------------------

        SW = 4'b0001;

        $display("");
        $display("------------------------------------------");
        $display("TEST 2 : SLEEP REQUEST");
        $display("SW = %b", SW);
        $display("------------------------------------------");

        #100;


        $display("State         = %b", DUT.state);
        $display("Clock Enable  = %b", DUT.clock_enable);
        $display("Idle          = %b", DUT.idle);
        $display("Counter       = %d", DUT.counter);

        #200;

        $display("Counter after sleep = %d", DUT.counter);


        // -----------------------------------------------------
        // TEST 3 : WAKE
        // SW0 = 0
        // SW1 = 1
        // -----------------------------------------------------

        SW = 4'b0010;

        $display("");
        $display("------------------------------------------");
        $display("TEST 3 : WAKE REQUEST");
        $display("SW = %b", SW);
        $display("------------------------------------------");

        #200;


        $display("State         = %b", DUT.state);
        $display("Clock Enable  = %b", DUT.clock_enable);
        $display("Idle          = %b", DUT.idle);


        // -----------------------------------------------------
        // SPEED UP COUNTER AGAIN
        // -----------------------------------------------------

        force DUT.counter_block.divider = 26'd49_999_998;

        #20;

        release DUT.counter_block.divider;

        #100;


        $display("Counter after wake = %d", DUT.counter);


        // -----------------------------------------------------
        // TEST 4 : NORMAL ACTIVE AGAIN
        // -----------------------------------------------------

        SW = 4'b0000;

        $display("");
        $display("------------------------------------------");
        $display("TEST 4 : NORMAL ACTIVE");
        $display("SW = %b", SW);
        $display("------------------------------------------");

        #200;


        $display("State         = %b", DUT.state);
        $display("Clock Enable  = %b", DUT.clock_enable);
        $display("Idle          = %b", DUT.idle);
        $display("Counter       = %d", DUT.counter);


        // -----------------------------------------------------
        // END SIMULATION
        // -----------------------------------------------------

        #200;

        $display("");
        $display("==========================================");
        $display(" SIMULATION COMPLETE");
        $display("==========================================");

        $finish;

    end


    // =========================================================
    // MONITOR IMPORTANT SIGNALS
    // =========================================================

    initial begin

        $monitor(
            "TIME=%0t | SW=%b | STATE=%b | CE=%b | IDLE=%b | COUNTER=%d | TICK=%b | LED15=%b",
            $time,
            SW,
            DUT.state,
            DUT.clock_enable,
            DUT.idle,
            DUT.counter,
            DUT.count_tick,
            LED[15]
        );

    end

endmodule