// Design: bird
module bird_cpu (
    input logic clk,                // Clock signal
    input logic [15:0] data_in,     // Data input from memory
    output logic [15:0] data_out,   // Data output to memory
    output logic [11:0] address,    // Address for memory access
    output logic mem_write_enable   // Memory write enable signal
);

    // CPU internal signals
    logic [11:0] program_counter, instruction_register; // Program counter and instruction register
    logic [4:0] fsm_state; // FSM state of the CPU
    logic [15:0] register_bank [7:0]; // Register bank
    logic zero_flag; // Zero flag
    logic [15:0] alu_result; // ALU result

    // Constants for state encoding
    localparam  FETCH=4'b0000,
                LDI=4'b0001, 
                LD=4'b0010,
                ST=4'b0011,
                JZ=4'b0100,
                JMP=4'b0101,
                ALU=4'b0111,
                PUSH=4'b1000,
                POP1=4'b1001,
                POP2=4'b1100,
                CALL=4'b1010,
                RET1=4'b1011,
                RET2=4'b1101;

    logic zero_result; // Zero result for zero flag

    // State transition logic
    always_ff @(posedge clk) begin
        case(fsm_state)
            FETCH: begin
                if (data_in[15:12] == JZ) // Check if the instruction opcode is JZ
                    fsm_state <= zero_flag ? JMP : FETCH; // If zero flag is set, jump; otherwise, fetch next instruction
                else
                    fsm_state <= data_in[15:12]; // If instruction opcode is not JZ, go to the next state
                instruction_register <= data_in[11:0]; // Store instruction in instruction register
                program_counter <= program_counter + 1; // Increment program counter for the next instruction
            end

            LDI: begin
                register_bank[instruction_register[2:0]] <= data_in; 
                program_counter <= program_counter + 1; // Increment program counter for the next instruction  
                fsm_state <= FETCH;
            end

            LD: begin
                register_bank[instruction_register[2:0]] <= data_in; // Load data from memory to register
                fsm_state <= FETCH; // Go back to fetch state
            end 

            ST: fsm_state <= FETCH;  // Go back to fetch state

            JMP: begin
                program_counter <= program_counter + instruction_register; // Jump to the address specified in the instruction
                fsm_state <= FETCH;  // Go back to fetch state
            end

            ALU: begin
                register_bank[instruction_register[2:0]] <= alu_result; // Store ALU result in register
                zero_flag <= zero_result; // Set zero flag based on ALU result
                fsm_state <= FETCH; // Go back to fetch state
            end

            PUSH: begin
                register_bank[7] <= register_bank[7] - 1; // Decrement stack pointer
                fsm_state <= FETCH; // Go back to fetch state
            end

            POP1: begin
                register_bank[7] <= register_bank[7] + 1; // Increment stack pointer
                fsm_state <= POP2; // Go to the next state
            end

            POP2: begin
                register_bank[instruction_register[2:0]] <= data_in; // Load data from memory to register
                fsm_state <= FETCH; // Go back to fetch state
            end

            CALL: begin
                register_bank[7] <= register_bank[7] - 1; // Decrement stack pointer
                program_counter <= program_counter + instruction_register; // Jump to the address specified in the instruction
                fsm_state <= FETCH; // Go back to fetch state
            end

            RET1: begin
                register_bank[7] <= register_bank[7] + 1; // Increment stack pointer
                fsm_state <= RET2; // Go to the next state
            end

            RET2: begin
                program_counter <= data_in[11:0]; // Return to the address specified in the instruction
                fsm_state <= FETCH;  // Go back to fetch state
            end
        endcase
    end

    // Address generation logic
    always_comb begin
        case (fsm_state)
            LD, ST, PUSH, POP2, CALL, RET2: address = register_bank[instruction_register[5:3]][11:0];
            default: address = program_counter;
        endcase
    end

    // Memory write enable logic
    assign mem_write_enable = (fsm_state == ST) || (fsm_state == PUSH) || (fsm_state == CALL);

    // Data output logic
    always_comb begin
        case (fsm_state)
            CALL: data_out = {4'b0, program_counter};
            default: data_out = register_bank[instruction_register[8:6]];
        endcase
    end

    // ALU operation logic
    always_comb begin
        case (instruction_register[11:9]) // Decode ALU operation
            3'h0: alu_result = register_bank[instruction_register[8:6]] + register_bank[instruction_register[5:3]]; // ADD (000)
            3'h1: alu_result = register_bank[instruction_register[8:6]] - register_bank[instruction_register[5:3]]; // SUB (001)
            3'h2: alu_result = register_bank[instruction_register[8:6]] & register_bank[instruction_register[5:3]]; // AND (010)
            3'h3: alu_result = register_bank[instruction_register[8:6]] | register_bank[instruction_register[5:3]]; // OR (011)
            3'h4: alu_result = register_bank[instruction_register[8:6]] ^ register_bank[instruction_register[5:3]]; // XOR (100)
            3'h7: case (instruction_register[8:6]) // Special ALU operations
                3'h0: alu_result = !register_bank[instruction_register[5:3]]; // NOT (000)
                3'h1: alu_result = register_bank[instruction_register[5:3]];  // MOV (001)
                3'h2: alu_result = register_bank[instruction_register[5:3]] + 1; // INC (010)
                3'h3: alu_result = register_bank[instruction_register[5:3]] - 1; // DEC (011)
                default: alu_result = 16'h0000;
            endcase
            default: alu_result = 16'h0000;
        endcase
    end

    // Zero flag logic
    assign zero_result = ~|alu_result; // Set zero_result if alu_result is zero

    // Initial state
    initial begin
        fsm_state = FETCH;
        zero_flag = 0;
        program_counter = 0;
    end

endmodule