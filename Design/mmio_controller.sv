module mmio_controller(
    // FPro Bus
    input logic clk,
    input logic reset,
    input logic mmio_cs,
    input logic mmio_wr,
    input logic mmio_rd,
    input logic [20:0] mmio_addr,
    input logic [31:0] mmio_wr_data,
    output logic [31:0] mmio_rd_data,
    // Slot Interface
    output logic [63:0] slot_cs_array,
    output logic [63:0] slot_mem_rd_array,
    output logic [63:0] slot_mem_wr_array,
    output logic [4:0] slot_reg_addr_array [63:0],
    input logic [31:0] slot_rd_data_array [63:0],
    output logic [31:0] slot_wr_data_array [63:0]
);
    logic [5:0] slot_addr;
    logic [4:0] reg_addr;

    assign slot_addr = mmio_addr[10:5];
    assign reg_addr = mmio_addr[4:0];

    // Address Decoding
    always_comb begin
        slot_cs_array = 0;
        if (mmio_cs) begin
            slot_cs_array[slot_addr] = 1;
        end
    end

    // Broadcasting read & write enable signals, data & reg. address
    generate
        genvar i;
        for (i=0; i<64; i=i+1) begin
            assign slot_mem_rd_array[i] = mmio_rd;
            assign slot_mem_wr_array[i] = mmio_wr;
            assign slot_wr_data_array[i] = mmio_wr_data;
            assign slot_reg_addr_array[i] =reg_addr;
        end        
    endgenerate

    // Multiplexing the read data
    assign mmio_rd_data = slot_rd_data_array[slot_addr];

endmodule