#include "io_rw.h"
#include "init.h"

class GpoCore
{
    enum {
        DATA_REG = 0
    };
    private:
        uint32_t base_addr;
        uint32_t wr_data;
    public:
        GpoCore(uint32_t core_base_addr);
        ~GpoCore();
        void write(uint32_t data);
        void write(int bit_value, int bit_pos);
};

class GpiCore
{
    enum {
        DATA_REG = 0
    };
    private:
        uint32_t base_addr;
    public:
        GpiCore(uint32_t core_base_addr);
        ~GpiCore();
        uint32_t read();
        int read(int bit_pos);
};
