module dual_timer (
    input logic clk,                // Main clock (50 MHz)
    input logic reset_1s,           // Reset for 1-second timer
    input logic reset_5s,           // Reset for 5-second timer
    output logic pulse_1s,          // 1-second pulse output
    output logic pulse_5s           // 5-second pulse output
);

    // Parameters (Clock division factors)
    parameter CLOCK_FREQ = 50000000; // 50 MHz
    parameter TIMER_1S_LIMIT = CLOCK_FREQ;       // For 1 second
    parameter TIMER_5S_LIMIT = 5 * CLOCK_FREQ;   // For 5 seconds

    // Counters and status registers
    logic [31:0] counter_1s;        // Counter for 1 second
    logic [31:0] counter_5s;        // Counter for 5 seconds
    logic status_1s, status_5s;

    // 1-second timer logic
    always_ff @(posedge clk or posedge reset_1s) begin
        if (reset_1s) begin
            counter_1s <= 32'b0;            // Counter is reset when reset is asserted
            status_1s <= 1'b0;              // Pulse is reset
        end else if (counter_1s == TIMER_1S_LIMIT - 1) begin
            status_1s <= 1'b1;              // Pulse is generated when 1 second has passed
            // Counter remains in hold
        end else if (!status_1s) begin
            counter_1s <= counter_1s + 1;   // Counter increments
        end
    end

    // 5-second timer logic
    always_ff @(posedge clk or posedge reset_5s) begin
        if (reset_5s) begin
            counter_5s <= 32'b0;            // Counter is reset when reset is asserted
            status_5s <= 1'b0;              // Pulse is reset
        end else if (counter_5s == TIMER_5S_LIMIT - 1) begin
            status_5s <= 1'b1;              // Pulse is generated when 5 seconds have passed
            // Counter remains in hold
        end else if (!status_5s) begin
            counter_5s <= counter_5s + 1;   // Counter increments
        end
    end

    // Pulse output logic
    always_comb begin
        pulse_1s = status_1s;
        pulse_5s = status_5s;
    end

    // Initial values
    initial begin
        counter_1s = 32'b0;
        counter_5s = 32'b0;
        pulse_1s = 1'b0;
        pulse_5s = 1'b0;
    end

endmodule