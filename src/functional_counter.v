module functional_counter (
    input  wire        gated_clk,
    input  wire        reset,

    output reg [15:0] counter,
    output reg [15:0] previous_counter,
    output reg        count_tick
);

    reg [25:0] divider;

    always @(posedge gated_clk) begin

        if (reset) begin
            divider          <= 26'd0;
            counter          <= 16'd0;
            previous_counter <= 16'd0;
            count_tick       <= 1'b0;
        end

        else begin

            count_tick <= 1'b0;

            if (divider == 26'd49_999_999) begin

                divider <= 26'd0;

                previous_counter <= counter;
                counter <= counter + 16'd1;

                count_tick <= 1'b1;

            end

            else begin
                divider <= divider + 1'b1;
            end

        end

    end

endmodule