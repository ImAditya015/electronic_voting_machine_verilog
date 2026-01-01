`timescale 1ns / 1ps

module tb_EVM_FSM;

    // --------- Testbench Signals ---------
    reg clk;
    reg reset;
    reg start, close;
    reg [1:0] vote;
    reg confirm, cancel;

    wire ready, locked;
    wire [3:0] led_state;
    wire [7:0] count1, count2, count3, count4;

    // --------- DUT Instantiation ---------
    EVM_FSM dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .close(close),
        .vote(vote),
        .confirm(confirm),
        .cancel(cancel),
        .ready(ready),
        .locked(locked),
        .led_state(led_state),
        .count1(count1),
        .count2(count2),
        .count3(count3),
        .count4(count4)
    );

    // --------- Clock Generation (10ns period) ---------
    always #5 clk = ~clk;

    // --------- Initial Block ---------
    initial begin
        // Dumpfile for waveform
        $dumpfile("EVM_FSM.vcd");
        $dumpvars(0, tb_EVM_FSM);

        // Initialize signals
        clk     = 0;
        reset   = 1;
        start   = 0;
        close   = 0;
        vote    = 2'b00;
        confirm = 0;
        cancel  = 0;

        // --------- Reset ---------
        #20 reset = 0;

        // --------- Admin starts election ---------
        #10 start = 1;
        #10 start = 0;

        // --------- Voter 1 votes for Candidate 1 (01) ---------
        #20 vote = 2'b01;
        #10 confirm = 1;
        #10 confirm = 0;
        #10 confirm = 1;   // final confirm
        #10 confirm = 0;
        #40 vote = 2'b00;

        // --------- Voter 2 votes for Candidate 3 (11) ---------
        #20 vote = 2'b11;
        #10 confirm = 1;
        #10 confirm = 0;
        #10 confirm = 1;
        #10 confirm = 0;
        #40 vote = 2'b00;

        // --------- Voter 3 cancels vote ---------
        #20 vote = 2'b10;
        #10 cancel = 1;
        #10 cancel = 0;
        #20 vote = 2'b00;

        // --------- Admin closes election ---------
        #20 close = 1;
        #10 close = 0;

        // --------- End simulation ---------
        #100 $finish;
    end

endmodule

