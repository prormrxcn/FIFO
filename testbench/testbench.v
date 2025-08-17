// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module FIFO_tb;
    // Inputs
    reg clk;
    reg rst;
    reg push;
    reg pop;
    reg [7:0] data_in;
    
    // Outputs
    wire [7:0] data_out;
    wire full;
    wire empty;
    wire error;
    
    // Instantiate the FIFO
    FIFO uut (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .error(error)
    );
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
        initial begin
        $dumpfile("fifo_simulation.vcd");  // Create VCD file
        $dumpvars(0, FIFO_tb);             // Dump all signals in testbench
        // Can also dump specific signals:
        // $dumpvars(1, clk, rst, push, pop);
        // $dumpvars(2, data_in, data_out);
        // $dumpvars(3, full, empty, error);
    end
    // Test stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        push = 0;
        pop = 0;
        data_in = 0;
        
        // Reset the FIFO
        #20;
        rst = 0;
        
        // Test Case 1: Basic push and pop
        $display("Test Case 1: Basic operations");
        push = 1;
        data_in = 8'hA5;
        #10;
        push = 0;
        pop = 1;
        #10;
        if (data_out !== 8'hA5) $error("Basic pop failed");
        pop = 0;
        #10;
        
        // Test Case 2: Fill the FIFO completely
        $display("Test Case 2: Fill FIFO");
        for (int i = 0; i < 16; i = i + 1) begin
            push = 1;
            data_in = i;
            #10;
            push = 0;
            #10;
        end
        if (!full) $error("FIFO should be full");
        
        // Test Case 3: Overflow test
        $display("Test Case 3: Overflow test");
        push = 1;
        data_in = 8'hFF;
        #10;
        if (!error) $error("Overflow error not detected");
        push = 0;
        #10;
        
        // Test Case 4: Empty the FIFO
        $display("Test Case 4: Empty FIFO");
        for (int i = 0; i < 16; i = i + 1) begin
            pop = 1;
            #10;
            if (data_out !== i[7:0]) $error("Pop data mismatch");
            pop = 0;
            #10;
        end
        if (!empty) $error("FIFO should be empty");
        
        // Test Case 5: Underflow test
        $display("Test Case 5: Underflow test");
        pop = 1;
        #10;
        if (!error) $error("Underflow error not detected");
        pop = 0;
        #10;
        
        // Test Case 6: Simultaneous push and pop
        $display("Test Case 6: Simultaneous operations");
        push = 1;
        pop = 1;
        data_in = 8'h55;
        #10;
        if (error) $error("False error on simultaneous ops");
        push = 0;
        pop = 0;
        #10;
        
        // Test Case 7: Wrap-around test
        $display("Test Case 7: Wrap-around test");
        // Fill to almost full
        for (int i = 0; i < 15; i = i + 1) begin
            push = 1;
            data_in = i + 100;
            #10;
            push = 0;
            #10;
        end
        // Do simultaneous ops to trigger wrap-around
        push = 1;
        pop = 1;
        data_in = 8'hAA;
        #10;
        push = 0;
        pop = 0;
        #10;
        
        // Test Case 8: Random operations
        $display("Test Case 8: Random operations");
        for (int i = 0; i < 50; i = i + 1) begin
            push = $random;
            pop = $random;
            data_in = $random;
            #10;
        end
        
        $display("All tests completed");
        $finish;
    end
    
    // Monitor FIFO status
    always @(posedge clk) begin
        $display("Time=%0t: push=%b pop=%b data_in=%h | data_out=%h full=%b empty=%b error=%b",
                 $time, push, pop, data_in, data_out, full, empty, error);
    end
endmodule