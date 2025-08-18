## FIFO Memory – Verilog Implementation
***

# 📌 Project Info

- College: Indore Institute of Science and Technology

- Engineer: Daksh Vaishnav

- Project Name: FIFO

- Design Name: FIFO (First-In First-Out) Memory

- Target Device: xc7a35t-cpg236-1 (Basys 3 FPGA – Artix-7)

- Tool Version: Vivado 2024.2

***

# 📝 Description

This project implements a 16-depth FIFO (First-In First-Out) memory in Verilog.
The FIFO supports push, pop, and simultaneous push+pop operations with overflow/underflow error handling.

***

# ⚙️ Features

- 8-bit wide data input/output

- 16 entries (depth = 16)

- push and pop signals for control

- full and empty status flags

- error signal for overflow/underflow

- Efficient pointer wrap-around handling

***

#  🔧 Verilog Code

```

module fifo(
    input clk,
    input rst,
    input push,
    input pop,
    input [7:0] data_in,
    output reg [7:0] data_out,
    output full,
    output empty,
    output reg error
);
    // 16-entry FIFO with 8-bit data
    reg [7:0] fifo [0:15];
    
    // Pointers (5-bit to handle wrap-around detection)
    reg [4:0] head;  // write pointer
    reg [4:0] tail;  // read pointer
    
    // Status signals
    assign empty = (head == tail);
    assign full = ((head[3:0] == tail[3:0]) && (head[4] != tail[4]));
    
    // Count of elements in FIFO (optional)
    wire [4:0] count = (head >= tail) ? (head - tail) : (16 + head - tail);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers
            head <= 0;
            tail <= 0;
            data_out <= 0;
            error <= 0;
        end
        else begin
            // Default: clear error unless triggered
            error <= 0;
            
            // Handle simultaneous push and pop
            if (push && pop) begin
                if (empty) begin
                    error <= 1;  // Can't pop from empty
                    // Still allow push if not full
                    if (!full) begin
                        fifo[head[3:0]] <= data_in;
                        head <= head + 1;
                    end
                end
                else if (full) begin
                    error <= 1;  // Can't push to full
                    // Still allow pop if not empty
                    data_out <= fifo[tail[3:0]];
                    tail <= tail + 1;
                end
                else begin
                    // Normal simultaneous operation
                    fifo[head[3:0]] <= data_in;
                    data_out <= fifo[tail[3:0]];
                    head <= head + 1;
                    tail <= tail + 1;
                end
            end
            // Handle push only
            else if (push) begin
                if (!full) begin
                    fifo[head[3:0]] <= data_in;
                    head <= head + 1;
                end
                else begin
                    error <= 1;  // overflow
                end
            end
            // Handle pop only
            else if (pop) begin
                if (!empty) begin
                    data_out <= fifo[tail[3:0]];
                    tail <= tail + 1;
                end
                else begin
                    error <= 1;  // underflow
                end
            end
            
            // Handle pointer wrap-around (more efficient than %)
            if (head[3:0] == 4'b1111) head[4] <= ~head[4];
            if (tail[3:0] == 4'b1111) tail[4] <= ~tail[4];
        end
    end
endmodule

```

***

# 🧪 Testbench

A testbench is included to validate the push/pop operations and error conditions.

***

# ✅ Status

- RTL Design

- Simulation Tested

- FPGA Hardware Validation


***

# author

daksh vaishnav


