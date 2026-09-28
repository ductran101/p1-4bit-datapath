`timescale 1ns / 1ps

// Self-checking verification of the report, pages 19 and 28-29.
// Examples and Appendix protocol checks are separate from the 4096 exhaustive
// cases. Run all in Vivado; the complete simulation takes about 35 us.
module alu_4bit_tb;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg start = 1'b0;
    reg [3:0] a = 4'd0, b = 4'd0, opcode = 4'd9;
    wire [7:0] result;
    wire carry, zero, overflow, negative, div_by_zero, busy, done;

    integer errors = 0;
    integer comb_checks = 0;
    integer md_checks = 0;
    integer protocol_checks = 0;
    integer cycles;
    integer op_i, pair_i, work_i, before_errors;
    reg [7:0] ab;

    alu_4bit dut (
        .clk(clk), .rst(rst), .start(start),
        .a(a), .b(b), .opcode(opcode),
        .result(result), .carry(carry), .zero(zero),
        .overflow(overflow), .negative(negative),
        .div_by_zero(div_by_zero), .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

    task fail;
        input [8*100-1:0] reason;
        begin
            errors = errors + 1;
            if (errors <= 20)
                $display("FAIL t=%0t op=%b a=%0d b=%0d: %0s",
                         $time, opcode, a, b, reason);
        end
    endtask

    task check_status;
        input expected_busy, expected_done;
        begin
            if ({busy, done} !== {expected_busy, expected_done}) begin
                fail("busy/done protocol mismatch");
                if (errors <= 20)
                    $display("  got busy=%b done=%b, expected busy=%b done=%b",
                             busy, done, expected_busy, expected_done);
            end
        end
    endtask

    task check_outputs;
        input [7:0] expected_result;
        input expected_carry, expected_overflow, expected_negative, expected_dbz;
        reg [4:0] expected_flags;
        begin
            expected_flags = {expected_carry, (expected_result == 8'd0),
                              expected_overflow, expected_negative, expected_dbz};
            if (result !== expected_result ||
                {carry, zero, overflow, negative, div_by_zero} !== expected_flags) begin
                fail("result or flags mismatch");
                if (errors <= 20)
                    $display("  got result=%h C/Z/V/N/DBZ=%b, expected result=%h C/Z/V/N/DBZ=%b",
                             result, {carry, zero, overflow, negative, div_by_zero},
                             expected_result, expected_flags);
            end
        end
    endtask

    // Arithmetic reference uses direct definitions, independently of the
    // structural DUT. SUB carry is 1 when there is no unsigned borrow.
    task check_comb;
        reg [3:0] expected_low;
        reg expected_carry, expected_overflow;
        reg [4:0] extended_sum;
        begin
            expected_low = 4'd0;
            expected_carry = 1'b0;
            expected_overflow = 1'b0;
            extended_sum = 5'd0;
            case (opcode)
                4'd0: begin
                    extended_sum = {1'b0, a} + {1'b0, b};
                    expected_low = extended_sum[3:0];
                    expected_carry = extended_sum[4];
                    expected_overflow = (a[3] == b[3]) &&
                                        (expected_low[3] != a[3]);
                end
                4'd1: begin
                    expected_low = a - b;
                    expected_carry = (a >= b);
                    expected_overflow = (a[3] != b[3]) &&
                                        (expected_low[3] != a[3]);
                end
                4'd2: expected_low = a & b;
                4'd3: expected_low = a | b;
                4'd4: expected_low = a ^ b;
                4'd5: expected_low = ~a;
                4'd6: begin
                    expected_low = {a[2:0], 1'b0};
                    expected_carry = a[3];
                end
                4'd7: begin
                    expected_low = {1'b0, a[3:1]};
                    expected_carry = a[0];
                end
                default: expected_low = 4'd0;
            endcase
            check_outputs({4'd0, expected_low}, expected_carry,
                          expected_overflow, expected_low[3], 1'b0);
        end
    endtask

    task check_md;
        input [3:0] op, x, y;
        reg [7:0] expected_result;
        reg [3:0] expected_quotient, expected_remainder;
        reg expected_dbz;
        begin
            expected_dbz = (op == 4'd9) && (y == 4'd0);
            if (op == 4'd8)
                expected_result = {4'd0, x} * {4'd0, y};
            else if (y == 4'd0)
                expected_result = {x, 4'hf};
            else begin
                expected_quotient = x / y;
                expected_remainder = x % y;
                expected_result = {expected_remainder, expected_quotient};
            end
            check_outputs(expected_result, 1'b0, 1'b0, 1'b0, expected_dbz);
        end
    endtask

    // Drive at falling edges so each pulse spans one rising edge. Sampling
    // at falling edges also allows all nonblocking updates to settle.
    task load_md;
        input [3:0] op, x, y;
        begin
            @(negedge clk);
            opcode = op; a = x; b = y; start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            cycles = 1; // one load clock, followed by four work clocks
            check_status(1'b1, 1'b0);
            if (div_by_zero !== ((op == 4'd9) && (y == 4'd0)))
                fail("divide-by-zero flag was not loaded at start");
        end
    endtask

    task run_md;
        input [3:0] op, x, y;
        begin
            load_md(op, x, y);
            // Bounded even if done is X or the implementation never finishes.
            while (done !== 1'b1 && cycles < 9) begin
                @(negedge clk);
                cycles = cycles + 1;
                if (cycles < 5)
                    check_status(1'b1, 1'b0);
                else
                    check_status(1'b0, 1'b1);
            end
            if (done !== 1'b1) begin
                fail("MUL/DIV completion timeout");
                $fatal(1, "FAILED: %0d errors (MUL/DIV timeout)", errors);
            end
            if (cycles != 5)
                fail("MUL/DIV must take exactly 1 load + 4 work clocks");
            check_status(1'b0, 1'b1);
            check_md(op, x, y);
        end
    endtask

    task show_comb;
        input [3:0] op, x, y;
        input [8*4-1:0] name;
        begin
            opcode = op; a = x; b = y;
            #1;
            check_comb;
            $display(" %s %b | %2d %2d | %b (%3d) | C=%b Z=%b V=%b N=%b",
                     name, op, x, y, result, result, carry, zero, overflow, negative);
        end
    endtask

    task show_md;
        input [3:0] op, x, y;
        input [8*4-1:0] name;
        begin
            run_md(op, x, y);
            if (op == 4'd8)
                $display(" %s %b | %2d %2d | %b (%3d) | product=%0d, %0d cycles",
                         name, op, x, y, result, result, result, cycles);
            else
                $display(" %s %b | %2d %2d | %b       | quotient=%0d remainder=%0d dbz=%b, %0d cycles",
                         name, op, x, y, result, result[3:0], result[7:4],
                         div_by_zero, cycles);
        end
    endtask

    // Called at time zero or a falling edge. Assert and inspect reset before
    // the next rising edge, proving that reset is asynchronous.
    task reset_md;
        begin
            start = 1'b0;
            #2 rst = 1'b1;
            #1;
            check_status(1'b0, 1'b0);
            check_outputs(8'd0, 1'b0, 1'b0, 1'b0, 1'b0);
            #1 rst = 1'b0;
        end
    endtask

    initial begin
        before_errors = errors;
        reset_md;
        protocol_checks = protocol_checks + 1;

        // Every non-MUL/DIV opcode must ignore start at the top-level gate.
        for (op_i = 0; op_i < 16; op_i = op_i + 1) begin
            if (op_i != 8 && op_i != 9) begin
                @(negedge clk);
                opcode = op_i; a = 4'd5; b = 4'd3; start = 1'b1;
                @(negedge clk);
                start = 1'b0;
                check_status(1'b0, 1'b0);
                check_comb;
            end
        end
        protocol_checks = protocol_checks + 1;

        // Appendix behavior: inputs/mode latch at start and start is ignored
        // while running. Both MD opcodes expose the same stored hi/lo value.
        load_md(4'd8, 4'd13, 4'd11);
        a = 4'd2; b = 4'd3; opcode = 4'd9;
        for (work_i = 1; work_i <= 4; work_i = work_i + 1) begin
            @(negedge clk);
            if (work_i < 4)
                check_status(1'b1, 1'b0);
            else
                check_status(1'b0, 1'b1);
            // A new one-clock pulse on work clock 2 must not reload the unit.
            start = (work_i == 1);
        end
        check_md(4'd8, 4'd13, 4'd11);
        protocol_checks = protocol_checks + 1;

        // Completion/result are held while no new MD start is accepted.
        repeat (2) begin
            @(negedge clk);
            check_status(1'b0, 1'b1);
            check_md(4'd8, 4'd13, 4'd11);
        end
        protocol_checks = protocol_checks + 1;

        opcode = 4'd0; start = 1'b1;
        @(negedge clk);
        start = 1'b0;
        check_status(1'b0, 1'b1);
        check_comb;
        opcode = 4'd8;
        #1;
        check_md(4'd8, 4'd13, 4'd11);
        protocol_checks = protocol_checks + 1;

        // DBZ is stored by the unit and gated by the current DIV decode.
        // run_md also checks that the next accepted start clears sticky done.
        run_md(4'd9, 4'd9, 4'd0);
        opcode = 4'd8;
        #1;
        check_outputs(8'h9f, 1'b0, 1'b0, 1'b0, 1'b0);
        opcode = 4'd2; a = 4'd12; b = 4'd10;
        #1;
        check_comb;
        opcode = 4'd9; a = 4'd0; b = 4'd7;
        repeat (2) begin
            @(negedge clk);
            check_status(1'b0, 1'b1);
            check_outputs(8'h9f, 1'b0, 1'b0, 1'b0, 1'b1);
        end
        run_md(4'd8, 4'd3, 4'd4);
        protocol_checks = protocol_checks + 1;

        // Reset interrupts MUL and DIV, including a set DBZ latch. No aborted
        // transaction may resume when reset is released.
        load_md(4'd8, 4'd15, 4'd15);
        @(negedge clk);
        check_status(1'b1, 1'b0);
        reset_md;
        repeat (2) begin
            @(negedge clk);
            check_status(1'b0, 1'b0);
            check_outputs(8'd0, 1'b0, 1'b0, 1'b0, 1'b0);
        end
        protocol_checks = protocol_checks + 1;

        load_md(4'd9, 4'd9, 4'd0);
        @(negedge clk);
        check_status(1'b1, 1'b0);
        reset_md;
        repeat (2) begin
            @(negedge clk);
            check_status(1'b0, 1'b0);
            check_outputs(8'd0, 1'b0, 1'b0, 1'b0, 1'b0);
        end
        protocol_checks = protocol_checks + 1;
        run_md(4'd9, 4'd13, 4'd4);
        protocol_checks = protocol_checks + 1;
        $display("Protocol checks: %0d scenarios, %0d errors (separate from exhaustive totals)",
                 protocol_checks, errors - before_errors);

        before_errors = errors;
        $display("\n Op   code | A  B | result         | flags / notes");
        $display(" ----------+------+----------------+------------------------------");
        show_comb(4'd0, 4'd5,  4'd3,  "ADD ");
        show_comb(4'd0, 4'd15, 4'd1,  "ADD ");
        show_comb(4'd1, 4'd5,  4'd3,  "SUB ");
        show_comb(4'd1, 4'd3,  4'd5,  "SUB ");
        show_comb(4'd2, 4'd12, 4'd10, "AND ");
        show_comb(4'd3, 4'd12, 4'd10, "OR  ");
        show_comb(4'd4, 4'd12, 4'd10, "XOR ");
        show_comb(4'd5, 4'd12, 4'd0,  "NOT ");
        show_comb(4'd6, 4'd11, 4'd0,  "SHL ");
        show_comb(4'd7, 4'd11, 4'd0,  "SHR ");
        show_md(4'd8, 4'd13, 4'd11, "MUL ");
        show_md(4'd8, 4'd15, 4'd15, "MUL ");
        show_md(4'd9, 4'd13, 4'd4, "DIV ");
        show_md(4'd9, 4'd15, 4'd3, "DIV ");
        show_md(4'd9, 4'd9,  4'd0, "DIV ");
        $display("Representative checks: 15 cases, %0d errors (separate from exhaustive totals)",
                 errors - before_errors);

        // 14 single-cycle/unused opcodes x 256 operand pairs = 3584 cases.
        for (op_i = 0; op_i < 16; op_i = op_i + 1) begin
            if (op_i != 8 && op_i != 9) begin
                for (pair_i = 0; pair_i < 256; pair_i = pair_i + 1) begin
                    opcode = op_i;
                    {a, b} = pair_i;
                    #1;
                    check_comb;
                    comb_checks = comb_checks + 1;
                end
            end
        end

        // 256 MUL + 256 DIV, with latency/flags checked for both (also b=0).
        for (pair_i = 0; pair_i < 256; pair_i = pair_i + 1) begin
            ab = pair_i;
            run_md(4'd8, ab[7:4], ab[3:0]);
            md_checks = md_checks + 1;
            run_md(4'd9, ab[7:4], ab[3:0]);
            md_checks = md_checks + 1;
        end

        if (comb_checks != 3584 || md_checks != 512)
            fail("exhaustive case counts do not match the report");
        if (errors != 0)
            $fatal(1, "FAILED: %0d errors", errors);
        $display("\nPASS: %0d single-cycle checks + %0d MUL/DIV checks, 0 errors",
                 comb_checks, md_checks);
        $display("Simulation completed at %0t (1 load + 4 work clocks per MUL/DIV).", $time);
        $finish;
    end

    // Independent watchdog keeps an accidental stalled test from hanging.
    initial begin
        #100000;
        $fatal(1, "FAILED: testbench watchdog timeout");
    end
endmodule
