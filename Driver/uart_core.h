#ifndef _UART_CORE_H_INCLUDED
#define _UART_CORE_H_INCLUDED

#include "io_rw.h"
#include "io_map.h"

class UartCore
{
    enum {
        RD_DATA_REG = 0,
        DVSR_REG = 1,
        WR_DATA_REG = 2,
        RM_RD_DATA_REG = 3
    };

    enum {
        TX_FULL_FIELD = 0x00000200,
        RX_EMPT_FIELD = 0x00000100,
        RX_DATA_FIELD = 0x000000ff
    };

    private:
        uint32_t base_addr;
        int baud_rate;
        void disp_str(const char *str);

    public:
        UartCore(uint32_t core_base_addr);
        ~UartCore();
        // Basic IO
        void set_baud_rate(int baud);
        int rx_fifo_empty();
        int tx_fifo_full();
        void tx_byte(uint8_t byte);
        int rx_byte();
        //Display
        void disp(char ch);
        void disp(const char *str);
        void disp(int n, int base, int len);
        void disp(int n, int base);
        void disp(int n);
        void disp(double f, int digit);
        void disp(double f);
};

#endif