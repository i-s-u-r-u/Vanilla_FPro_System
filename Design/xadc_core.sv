module xadc_core(
    input logic clk,
    input logic reset,
    // Slot Interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // External Signals
    input logic [3:0] adc_p,
    input logic [3:0] adc_n,
);
    // Signal Declartion
    logic [4:0] channel;
    logic [6:0] daddr_in;
    logic eoc;
    logic rdy;
    logic [15:0] adc_data;
    logic [15:0] adc0_out_reg, adc1_out_reg, adc2_out_reg, adc3_out_reg;
    logic [15:0] tmp_out_reg, vcc_out_reg;
    logic [31:0] r_data;

    // Instantiate XADC
    xadc_fpro xdac_unit (
        .di_in(16'h0000),               // input wire [15 : 0] di_in
        .daddr_in(daddr_in),            // input wire [6 : 0] daddr_in
        .den_in(eoc),                   // input wire den_in
        .dwe_in(1'b0),                  // input wire dwe_in
        .drdy_out(rdy),                 // output wire drdy_out
        .do_out(adc_data),              // output wire [15 : 0] do_out
        .dclk_in(clk),                  // input wire dclk_in
        .reset_in(reset),               // input wire reset_in
        .vp_in(1'b0),                   // input wire vp_in
        .vn_in(1'b0),                   // input wire vn_in
        .vauxp2(adc_p[2]),              // input wire vauxp2
        .vauxn2(adc_n[2]),              // input wire vauxn2
        .vauxp3(adc_p[0]),              // input wire vauxp3
        .vauxn3(adc_n[0]),              // input wire vauxn3
        .vauxp10(adc_p[3]),             // input wire vauxp10
        .vauxn10(adc_n[3]),             // input wire vauxn10
        .vauxp11(adc_p[1]),             // input wire vauxp11
        .vauxn11(adc_n[1]),             // input wire vauxn11
        .channel_out(channel),          // output wire [4 : 0] channel_out
        .eoc_out(eoc),                  // output wire eoc_out
        .alarm_out(),                   // output wire alarm_out
        .eos_out(),                     // output wire eos_out
        .busy_out()                     // output wire busy_out
    );

    assign daddr_in = {2'b00, channel};

    // Registers and Decoding
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            adc0_out_reg <= 16'h0000;
            adc1_out_reg <= 16'h0000;
            adc2_out_reg <= 16'h0000;
            adc3_out_reg <= 16'h0000;
            tmp_out_reg <= 16'h0000;
            vcc_out_reg <= 16'h0000;
        end else begin
            if (rdy && channel == 5'b10011) begin
                adc0_out_reg < adc_data;
            end
            if (rdy && channel == 5'b11010) begin
                adc1_out_reg < adc_data;
            end
            if (rdy && channel == 5'b10010) begin
                adc2_out_reg < adc_data;
            end
            if (rdy && channel == 5'b11011) begin
                adc3_out_reg < adc_data;
            end
            if (rdy && channel == 5'b00000) begin
                tmp_out_reg < adc_data;
            end
            if (rdy && channel == 5'b00001) begin
                vcc_out_reg < adc_data;
            end
        end
    end

    // Read Multiplexing
    always_comb begin
        case (addr[2:0])
            3'b000:
                r_data = {16'h0000, adc0_out_reg};
            3'b001:
                r_data = {16'h0000, adc1_out_reg};
            3'b010:
                r_data = {16'h0000, adc2_out_reg};
            3'b011:
                r_data = {16'h0000, adc3_out_reg};
            3'b100:
                r_data = {16'h0000, tmp_out_reg};
            default: begin
                r_data = {16'h0000, vcc_out_reg};
            end
        endcase
        assign rd_data = r_data;
    end
endmodule