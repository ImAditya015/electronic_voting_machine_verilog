module EVM_FSM (
    input clk, reset,            // Clock and Reset
    input start, close,          // Admin controls
    input [1:0] vote,            // 2-bit candidate selection (4 candidates)
    input confirm, cancel,       // Voter buttons
    output reg ready, locked,    // Status indicators
    output reg [3:0] led_state,  // State indicator (for debug)
    output reg [7:0] count1, count2, count3, count4 // Vote counts
);
    //----------- STATE DECLARATION -------------
    parameter IDLE    = 3'b000;
    parameter READY   = 3'b001;
    parameter VOTING  = 3'b010;
    parameter CONFIRM = 3'b011;
    parameter LOCKED  = 3'b100;
    parameter THANKS  = 3'b101;
    parameter CLOSED  = 3'b110;

    reg [2:0] state, next_state;
    reg [1:0] candidate; // Holds current voter’s selection
    integer timer;       // Simple counter for thank-you delay

    //----------- SEQUENTIAL BLOCK -------------
    // State transition block
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

 always @(posedge clk)
    begin
        // Default outputs for every cycle
        ready   = 0;
        locked  = 0;
        led_state = 4'b0000;

        case (state)
            //-------------------------------------------------
            // ⿡ IDLE — waiting for admin start
            //-------------------------------------------------
            IDLE: begin
                led_state = 4'b0001;
                if (start)
                    next_state = READY;
                else
                    next_state = IDLE;
            end

            //-------------------------------------------------
            // ⿢ READY — machine ready for voter
            //-------------------------------------------------
            READY: begin
                led_state = 4'b0010;
                ready = 1;
                if (close)
                    next_state = CLOSED;
                else if (vote != 2'b00)
                begin
                    candidate = vote; // store selection
                    next_state = VOTING;
                end
                else
                    next_state = READY;
            end

          VOTING: begin
                led_state = 4'b0011;
                ready = 1;
                if (cancel)
                    next_state = READY;   // cancel selection
                else if (confirm)
                    next_state = CONFIRM; // move to confirmation
                else
                    next_state = VOTING;
            end

            //-------------------------------------------------
            // ⿤ CONFIRM — ask confirmation from voter
            //-------------------------------------------------
            CONFIRM: begin
                led_state = 4'b0100;
                if (cancel)
                    next_state = READY;
                else if (confirm)
                    next_state = LOCKED; // final confirmation
                else
                    next_state = CONFIRM;
            end


           LOCKED: begin
                led_state = 4'b0101;
                locked = 1;
                case (candidate)
                    2'b00: count1 = count1 + 1;
                    2'b01: count2 = count2 + 1;
                    2'b10: count3 = count3 + 1;
                    2'b11: count4 = count4 + 1;
                endcase
                timer = 0;
                next_state = THANKS;
            end

            //-------------------------------------------------
            // ⿦ THANKS — short delay before next voter
            //-------------------------------------------------
            THANKS: begin
                led_state = 4'b0110;
                timer = timer + 1;
                if (timer > 5)
                    next_state = READY; // go back for next voter
                else
                    next_state = THANKS;
            end

            //-------------------------------------------------
            // ⿧ CLOSED — election ended
            //-------------------------------------------------
            CLOSED: begin
                led_state = 4'b0111;
                ready = 0;
                if (start)
                    next_state = READY; // reopen if needed
                else
                   next_state = CLOSED;
            end

            //-------------------------------------------------
            // DEFAULT CASE (safety)
            //-------------------------------------------------
            default: next_state = IDLE;
        endcase
      
    end

endmodule
