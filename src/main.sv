module main (
    input logic [3:0] dip_switches,
    output logic [3:0] ground_signals,
    output logic [6:0] seven_segment_display,
    input logic clock
);

    // Memory map is defined here
    localparam  BEGIN_MEM = 12'h000,
                END_MEM = 12'h1FF,
                DIP1_STATUS_ADDR = 12'h902,
                DIP2_STATUS_ADDR = 12'h903,
                DIP3_STATUS_ADDR = 12'h904,
                DIP4_STATUS_ADDR = 12'h905,
                SEVEN_SEG_ADDR = 12'h906;

    // Instantiate the seven-segment module
    seven_segment_display ss1 (
        .data_in(seven_seg_data_out),
        .grounds(ground_signals),
        .display(seven_segment_display),
        .clk(clock)
    );

    // Instantiate the CPU module
    bird_cpu br1 (
        .clk(clock),
        .data_in(cpu_data_in), 
        .data_out(cpu_data_out),
        .address(cpu_address), 
        .mem_write_enable(mem_write)
    );

    // Instantiate the dual timer module
    dual_timer dual_timer_inst (
        .clk(clock),
        .reset_1s(timer_1_ack),
        .reset_5s(timer_5_ack),
        .pulse_1s(timer_1_status),
        .pulse_5s(timer_5_status)
    );

    // Memory chip
    logic [15:0] memory [0:127];

    // CPU's input-output pins
    logic [15:0] cpu_data_out;
    logic [15:0] cpu_data_in;
    logic [11:0] cpu_address;
    logic mem_write;

    // Timer and seven segment
    logic [15:0] seven_seg_data_out;
    logic timer_1_status, timer_5_status, timer_1_ack, timer_5_ack;

    // Multiplexer for CPU input
    always_comb begin
        timer_1_ack = 0;
        timer_5_ack = 0;
        if ((cpu_address >= BEGIN_MEM) && (cpu_address <= END_MEM)) begin
            // CPU reads from memory
            cpu_data_in = memory[cpu_address];
        end else if (cpu_address == DIP1_STATUS_ADDR) begin
            // CPU reads DIP switch 1 status and timer 1 status
            cpu_data_in = dip_switches[0] & timer_1_status;
            timer_1_ack = dip_switches[0] & timer_1_status;
        end else if (cpu_address == DIP2_STATUS_ADDR) begin
            // CPU reads DIP switch 2 status and timer 5 status
            cpu_data_in = dip_switches[1] & timer_5_status;
            timer_5_ack = dip_switches[1] & timer_5_status;
        end else if (cpu_address == DIP3_STATUS_ADDR) begin
            // CPU reads DIP switch 3 status
            cpu_data_in = dip_switches[2];
        end else if (cpu_address == DIP4_STATUS_ADDR) begin
            // CPU reads DIP switch 4 status
            cpu_data_in = dip_switches[3];
        end else begin
            // Default value
            cpu_data_in = 16'h0000;
        end
    end

    // Multiplexer for CPU output
    always_ff @(posedge clock) begin
        if (mem_write) begin
            if ((cpu_address >= BEGIN_MEM) && (cpu_address <= END_MEM)) begin
                // CPU writes to memory
                memory[cpu_address] <= cpu_data_out;
            end else if (cpu_address == SEVEN_SEG_ADDR) begin
                // CPU writes to seven-segment display
                seven_seg_data_out <= cpu_data_out;
            end
        end
    end

    // Beginning of the simulation
    initial begin
        seven_seg_data_out = 16'h0;
        timer_1_ack = 1;
        timer_5_ack = 1;
        $readmemh("ram.dat", memory);
    end

endmodule