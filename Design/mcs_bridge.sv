module mcs_bridge #(
    parameter BRG_BASE = 23'hc000_0000
) (
    // uBlaze MCS I/O Bus
    input logic io_addr_strobe, // Not Used
    input logic io_read_strobe,
    input logic io_write_strobe,
    input logic [3:0] io_byte_enable,
    input logic [31:0] io_address,
    input logic [31:0] io_read_data,
    output logic [31:0] io_write_data,
    output logic io_ready,
    // FPro Bus
    output logic fp_video_cs,  
    output logic fp_mmio_cs,
    output logic fp_wr,
    output logic fp_rd,
    output logic [20:0] fp_addr,
    output logic [31:0] fp_wr_data,
    input logic [31:0] fp_rd_data
);
    logic mcs_bridge_en;
    logic [29:0] word_addr;
    
    // 2 LSBs are not considered (Word Alignment)
    // Address Line
    assign word_addr = io_address[31:2];
    assign mcs_bridge_en = (io_address[31:24] == BRG_BASE[31:24]);
    assign fp_video_cs = (mcs_bridge_en && io_address[23] == 1);
    assign fp_mmio_cs = (mcs_bridge_en && io_address[23] == 0);
    assign fp_addr = word_addr[20:0];
    // Control Line
    assign fp_wr = io_write_strobe;
    assign fp_rd = io_read_strobe;
    assign io_ready = 1; // Not Used
    // Data Line
    assign fp_wr_data = io_write_data;
    assign fp_rd_data = io_read_data;
    
endmodule