module seven_segment_display (
    output logic [3:0] grounds, // Control signals for the common grounds of the 7-segment displays
    output logic [6:0] display, // Control signals for the segments of the 7-segment display
    input logic clk,            // Clock signal
    input logic [15:0] data_in  // 16-bit input data to be displayed
);

    logic [3:0] data [3:0]; // Array to hold 4-bit data for each 7-segment display
    logic [1:0] count;      // Counter to cycle through the 4 displays
    logic [25:0] clk_div;   // Clock divider

    // Clock divider and data assignment
    always_ff @(posedge clk) begin
        clk_div <= clk_div + 1; // Increment the clock divider
        data[3] <= data_in[3:0];   // Assign lower 4 bits of data_in to data[3]
        data[2] <= data_in[7:4];   // Assign next 4 bits of data_in to data[2]
        data[1] <= data_in[11:8];  // Assign next 4 bits of data_in to data[1]
        data[0] <= data_in[15:12]; // Assign upper 4 bits of data_in to data[0]
    end

    // Ground control and count increment
    always_ff @(posedge clk_div[15]) begin
        grounds <= {grounds[2:0], grounds[3]};  // Rotate the grounds control signal
        count <= count + 1;                     // Increment the count to select the next display
    end

    // Display control
    always_comb begin
        case(data[count])
            4'h0: display = 7'b0111111; // 0
            4'h1: display = 7'b0000110; // 1
            4'h2: display = 7'b1011011; // 2
            4'h3: display = 7'b1001111; // 3
            4'h4: display = 7'b1100110; // 4
            4'h5: display = 7'b1101101; // 5
            4'h6: display = 7'b1111101; // 6
            4'h7: display = 7'b0000111; // 7
            4'h8: display = 7'b1111111; // 8
            4'h9: display = 7'b1101111; // 9
            4'ha: display = 7'b1110111; // A
            4'hb: display = 7'b1111100; // B
            4'hc: display = 7'b0111001; // C
            4'hd: display = 7'b1011110; // D
            4'he: display = 7'b1111001; // E
            4'hf: display = 7'b1110001; // F
            default: display = 7'b0111111; // 0 (for rollover)
        endcase
    end

    // Initial block
    initial begin
        data[3] = data_in[3:0];   // Initialize data[3]
        data[2] = data_in[7:4];   // Initialize data[2]
        data[1] = data_in[11:8];  // Initialize data[1]
        data[0] = data_in[15:12]; // Initialize data[0]
        count = 2'b0;             // Initialize count
        grounds = 4'b1110;        // Initialize grounds
        clk_div = 0;              // Initialize clock divider
    end

endmodule
