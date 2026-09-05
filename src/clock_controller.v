module clock_controller (
    input  wire clk,
    input  wire reset,
    input  wire sleep_req,
    input  wire wake_req,

    output reg  clock_enable,
    output reg  idle,
    output reg  [1:0] state
);

    // FSM states
    localparam ACTIVE = 2'b00;
    localparam IDLE   = 2'b01;
    localparam WAKE   = 2'b10;

    // Synchronizers for asynchronous external inputs
    reg sleep_meta;
    reg sleep_sync;

    reg wake_meta;
    reg wake_sync;

    // Synchronize SLEEP request
    always @(posedge clk) begin
        if (reset) begin
            sleep_meta <= 1'b0;
            sleep_sync <= 1'b0;
        end
        else begin
            sleep_meta <= sleep_req;
            sleep_sync <= sleep_meta;
        end
    end

    // Synchronize WAKE request
    always @(posedge clk) begin
        if (reset) begin
            wake_meta <= 1'b0;
            wake_sync <= 1'b0;
        end
        else begin
            wake_meta <= wake_req;
            wake_sync <= wake_meta;
        end
    end

    // Clock gating controller FSM
    always @(posedge clk) begin

        if (reset) begin

            state         <= ACTIVE;
            clock_enable  <= 1'b1;
            idle          <= 1'b0;

        end
        else begin

            case (state)

                ACTIVE: begin

                    clock_enable <= 1'b1;
                    idle         <= 1'b0;

                    if (sleep_sync) begin
                        state <= IDLE;
                    end
                    else begin
                        state <= ACTIVE;
                    end

                end

                IDLE: begin

                    clock_enable <= 1'b0;
                    idle         <= 1'b1;

                    if (wake_sync) begin
                        state <= WAKE;
                    end
                    else begin
                        state <= IDLE;
                    end

                end

                WAKE: begin

                    clock_enable <= 1'b1;
                    idle         <= 1'b0;

                    state <= ACTIVE;

                end

                default: begin

                    state        <= ACTIVE;
                    clock_enable <= 1'b1;
                    idle         <= 1'b0;

                end

            endcase

        end

    end

endmodule