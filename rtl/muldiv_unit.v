`timescale 1ns / 1ps
// Report pp. 5-10, 24-26: four shift/add or shift/subtract steps.
// The datapath adder is external and shared with ADD/SUB in alu_4bit.
module muldiv_unit (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       is_div,
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] add_a,
    output wire [3:0] add_b,
    output wire       add_sub,
    input  wire [3:0] add_sum,
    input  wire       add_c4,
    output wire [3:0] hi,
    output wire [3:0] lo,
    output wire       busy,
    output reg        done,
    output reg        div_by_zero
);
    reg [3:0] acc, q, m;
    reg [1:0] count;
    reg       running;
    reg       mode_div;
    wire [3:0] r_shift;
    wire       r_top, fits;

    assign r_shift = {acc[2:0], q[3]};
    assign r_top   = acc[3];
    assign fits    = r_top | add_c4;
    assign add_a   = mode_div ? r_shift : acc;
    assign add_b   = m;
    assign add_sub = mode_div;
    assign busy    = running;
    assign hi      = acc;
    assign lo      = q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc         <= 4'd0;
            q           <= 4'd0;
            m           <= 4'd0;
            count       <= 2'd0;
            running     <= 1'b0;
            mode_div    <= 1'b0;
            done        <= 1'b0;
            div_by_zero <= 1'b0;
        end
        else if (start && !running) begin
            // Load is the first of five sampled rising edges.
            acc         <= 4'd0;
            q           <= is_div ? a : b;
            m           <= is_div ? b : a;
            count       <= 2'd0;
            running     <= 1'b1;
            mode_div    <= is_div;
            done        <= 1'b0;
            div_by_zero <= is_div && (b == 4'd0);
        end
        else if (running) begin
            if (!mode_div) begin
                // Conditional addition followed by right shift of {C, acc, q}.
                if (q[0])
                    {acc, q} <= {add_c4, add_sum, q[3:1]};
                else
                    {acc, q} <= {1'b0, acc, q[3:1]};
            end
            else begin
                // Shift left, then keep the difference only if the divisor fits.
                // With m=0, four steps naturally give q=15 and remainder=a.
                if (fits) begin
                    acc <= add_sum;
                    q   <= {q[2:0], 1'b1};
                end
                else begin
                    acc <= r_shift;
                    q   <= {q[2:0], 1'b0};
                end
            end

            count <= count + 2'd1;
            if (count == 2'd3) begin
                running <= 1'b0;
                done    <= 1'b1;
            end
        end
        // In IDLE, acc/q and done remain held until a new start or reset.
    end
endmodule
