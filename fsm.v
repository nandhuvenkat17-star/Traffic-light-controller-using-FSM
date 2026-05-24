`timescale 1ns/1ps

module TSC(
    input  wire clk,
    input  wire clear,
    input  wire x,              // sensor input (traffic presence)
    output reg  [1:0] hwy,
    output reg  [1:0] cntry
);

    // ================= STATES =================
    localparam S0 = 3'd0;  // highway green
    localparam S1 = 3'd1;  // highway yellow
    localparam S2 = 3'd2;  // highway red delay
    localparam S3 = 3'd3;  // country green
    localparam S4 = 3'd4;  // country yellow

    reg [2:0] state, nxt_state;

    // ================= COUNTER =================
    reg [1:0] count;

    // ================= STATE REGISTER =================
    always @(posedge clk or posedge clear) begin
        if (clear) begin
            state <= S0;
            count <= 2'd0;
        end else begin
            state <= nxt_state;

            // simple counter for timing control
            count <= count + 1;
        end
    end

    // ================= OUTPUT LOGIC =================
    always @(*) begin
        // default outputs
        hwy   = 2'b10; // green
        cntry = 2'b00; // red

        case (state)
            S0: begin
                hwy   = 2'b10; // green
                cntry = 2'b00; // red
            end

            S1: begin
                hwy   = 2'b01; // yellow
                cntry = 2'b00;
            end

            S2: begin
                hwy   = 2'b00; // red
                cntry = 2'b00;
            end

            S3: begin
                hwy   = 2'b00;
                cntry = 2'b10; // green
            end

            S4: begin
                hwy   = 2'b00;
                cntry = 2'b01; // yellow
            end
        endcase
    end

    // ================= NEXT STATE LOGIC =================
    always @(*) begin
        nxt_state = state;

        case (state)

            S0: begin
                if (x)
                    nxt_state = S1;
                else
                    nxt_state = S0;
            end

            S1: begin
                if (count == 2'd2)
                    nxt_state = S2;
                else
                    nxt_state = S1;
            end

            S2: begin
                if (count == 2'd3)
                    nxt_state = S3;
                else
                    nxt_state = S2;
            end

            S3: begin
                if (!x)
                    nxt_state = S4;
                else
                    nxt_state = S3;
            end

            S4: begin
                if (count == 2'd2)
                    nxt_state = S0;
                else
                    nxt_state = S4;
            end

        endcase
    end

endmodule
