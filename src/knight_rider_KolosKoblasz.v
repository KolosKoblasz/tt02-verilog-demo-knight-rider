`default_nettype none

module knight_rider_KolosKoblasz # (
    parameter OUT_WIDTH = 8
) (
    input [7:0]               io_in,
    output [OUT_WIDTH-1:0]    io_out
);
    localparam RISING_EDGE  = 2'b10;

    localparam LEFT       = 1'b1;
    localparam RIGHT      = 1'b0;
    localparam LEFT_END   = 2'b10;
    localparam RIGHT_END  = 2'b01;

    // Assumed CLK frequency is 6KHz
    localparam CLK_FREQ         = 6000;
    localparam RATE_VERY_SLOW   = (CLK_FREQ    / 0.5) - 1;
    localparam RATE_SLOW        = (CLK_FREQ    / 1  ) - 1;
    localparam RATE_NORMAL      = (CLK_FREQ    / 2  ) - 1;
    localparam RATE_FAST        = (CLK_FREQ    / 4  ) - 1;
    localparam RATE_VERY_FAST   = (CLK_FREQ    / 8  ) - 1;

    // Input assignments
    wire clk         = io_in[0];
    wire reset       = io_in[1];
    wire change_rate = io_in[2];
    wire brightness  = io_in[3];

    // Input sync and edge detection
    reg [3:0]  change_rate_shr;
    reg [3:0]  brightness_shr;
    wire       next_rate;
    wire       next_brightness;

    // This shift register performs cdc syncronizations
    // 2 stages for syncing inputs to clk and
    // 2 stages for edge detection
    always @(posedge clk) begin
        if (reset) begin
            change_rate_shr <= 0;
            brightness_shr  <= 0;
        end
        else begin
            change_rate_shr <= {change_rate_shr [2:0] , change_rate};
            brightness_shr  <= {brightness_shr  [2:0] , brightness };
        end
    end

    // Rising edge detection
    assign next_rate       = (change_rate_shr [3:2] == RISING_EDGE) ? 1'b1 : 1'b0 ;
    assign next_brightness = (brightness_shr  [3:2] == RISING_EDGE) ? 1'b1 : 1'b0 ;

    // LED shift register
    reg [OUT_WIDTH-1:0]  led_shr;

    // This shift register is responsible
    // for moving the active bit to left and right.
    always @(posedge clk) begin
        if (reset) begin
            led_shr <= 1;
        end
        else begin
            if (next_pos) begin // Move active bit
                if (dir == LEFT) begin // Move active bit to the left by one
                    led_shr <= {led_shr[OUT_WIDTH-2:0] , 1'b0 };
                end
                else begin // Move active bit to the right by one
                    led_shr <= {1'b0 ,led_shr[OUT_WIDTH-1:1]  };
                end
            end
        end
    end

    assign io_out = led_shr;

    // Direction bit
    reg dir;

    // Setting the direction bit
    always @(posedge clk) begin
        if (reset) begin
            dir <= LEFT;

        end
        else begin
            if (led_shr[OUT_WIDTH-1:OUT_WIDTH-2] == LEFT_END) begin // Active bit is at the left most position
                dir <= RIGHT;
            end
            else if (led_shr[1:0] == RIGHT_END) begin // Active bit is at the right most position
                dir <= LEFT;
            end
        end
    end

    // Rate counter
    reg [13:0]  rate_counter;

    wire        next_pos;
    assign      next_pos =  (rate_counter >= rc_max_value) ? 1'b1 : 1'b0; // Move active bit

    // This counter controls when the active bit will move
    always @(posedge clk) begin
        if (reset) begin
            rate_counter <= 0;
        end
        else begin
            if (rate_counter >= rc_max_value) begin // Reset the counter if max value reached
                rate_counter <= 0;
            end
            else begin // Increment the counter
                rate_counter <= rate_counter + 1;
            end
        end
    end

    // Rate control
    reg [2:0]  rate_ctrl;

    // This register controls how fast the
    // active led is moving.
    always @(posedge clk) begin
        if (reset) begin
            rate_ctrl <= 2; // Use RATE_NORMAL
        end
        else begin
            if (next_rate) begin // Change rate
                if (rate_ctrl >= 4) begin
                    rate_ctrl <= 0; // Max rate can not be increased. Move to slowest.
                end
                else begin
                    rate_ctrl <= rate_ctrl + 1; // Increase rate by one.
                end
            end
        end
    end

    logic [13:0] rc_max_value; // This variable contains the max value of the rate counter

    // Rate control mux
    always @(*) begin
        case (rate_ctrl)
            0 : rc_max_value = RATE_VERY_SLOW;
            1 : rc_max_value = RATE_SLOW;
            2 : rc_max_value = RATE_NORMAL;
            3 : rc_max_value = RATE_FAST;
            4 : rc_max_value = RATE_VERY_FAST;
            default : rc_max_value = RATE_NORMAL;
        endcase
    end

endmodule
