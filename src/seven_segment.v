module seven_segment (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] value,

    output reg [6:0]   seg,
    output reg [3:0]   an,
    output reg         dp
);

    reg [16:0] refresh_counter;
    reg [1:0]  digit_select;
    reg [3:0]  digit;

    //========================================================
    // 7-Segment refresh counter
    // 100 MHz clock
    // 100000 counts = 1 ms
    //========================================================
    always @(posedge clk) begin

        if (reset) begin
            refresh_counter <= 17'd0;
            digit_select    <= 2'd0;
        end

        else begin
            if (refresh_counter == 17'd99_999) begin
                refresh_counter <= 17'd0;
                digit_select    <= digit_select + 2'd1;
            end

            else begin
                refresh_counter <= refresh_counter + 1'b1;
            end
        end

    end


    //========================================================
    // Digit selection
    // Basys 3 seven segment is ACTIVE LOW
    //========================================================
    always @(*) begin

        case (digit_select)

            2'd0: begin
                an    = 4'b1110;
                digit = value[3:0];
            end

            2'd1: begin
                an    = 4'b1101;
                digit = value[7:4];
            end

            2'd2: begin
                an    = 4'b1011;
                digit = value[11:8];
            end

            2'd3: begin
                an    = 4'b0111;
                digit = value[15:12];
            end

            default: begin
                an    = 4'b1111;
                digit = 4'd0;
            end

        endcase

    end


    //========================================================
    // Seven segment decoder
    // Active LOW
    //========================================================
    always @(*) begin

        case (digit)

            4'd0:  seg = 7'b1000000;
            4'd1:  seg = 7'b1111001;
            4'd2:  seg = 7'b0100100;
            4'd3:  seg = 7'b0110000;
            4'd4:  seg = 7'b0011001;
            4'd5:  seg = 7'b0010010;
            4'd6:  seg = 7'b0000010;
            4'd7:  seg = 7'b1111000;
            4'd8:  seg = 7'b0000000;
            4'd9:  seg = 7'b0010000;

            4'd10: seg = 7'b0001000; // A
            4'd11: seg = 7'b0000011; // b
            4'd12: seg = 7'b1000110; // C
            4'd13: seg = 7'b0100001; // d
            4'd14: seg = 7'b0000110; // E
            4'd15: seg = 7'b0001110; // F

            default: seg = 7'b1111111;

        endcase

    end


    //========================================================
    // Decimal point
    // Basys 3 DP is ACTIVE LOW
    // 1 = OFF
    // 0 = ON
    //========================================================
    always @(*) begin
        dp = 1'b1;
    end

endmodule