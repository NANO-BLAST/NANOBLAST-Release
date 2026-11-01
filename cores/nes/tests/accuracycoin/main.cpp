// Host-only ROM fixture. Never compiled into an FPGA image.
#include "VNES.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <vector>

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    if (argc < 3) return 2;
    std::ifstream input(argv[1], std::ios::binary);
    std::vector<uint8_t> rom((std::istreambuf_iterator<char>(input)), {});
    if (rom.size() != 40976 || rom[4] != 2 || rom[5] != 1 ||
        (rom[6] & 0xf5) || rom[7]) {
        std::fprintf(stderr, "Requires horizontal-mirroring NROM-256 with 8K CHR ROM\n");
        return 2;
    }
    VNES top;
    constexpr unsigned RAM = 0x380000;
    std::vector<uint8_t> memory(1 << 22, 0);
    for (unsigned i = 0; i < 32768; ++i) memory[i] = rom[16 + i];
    for (unsigned i = 0; i < 8192; ++i) memory[0x200000 + i] = rom[32784 + i];
    top.menu_pause = 0;
    top.sys_type = 0;
    top.mapper_flags = 0x100;
    top.audio_channels = 31;
    top.int_audio = 1;
    top.ext_audio = 0;
    top.gg = 0;
    top.gg_reset = 0;
    for (unsigned i = 0; i < 5; ++i) top.gg_code[i] = 0;
    top.bram_din = 0;
    top.fds_busy = top.fds_eject = top.diskside = 0;
    top.joypad1_data = top.joypad2_data = 0;
    top.cpumem_din = top.ppumem_din = 0;

    const int max_frames = std::atoi(argv[2]);
    const int page = argc > 3 ? std::atoi(argv[3]) : 0;
    const int row = argc > 4 ? std::atoi(argv[4]) : 0;
    const int latency = std::getenv("MEMORY_LATENCY") ?
        std::atoi(std::getenv("MEMORY_LATENCY")) : 1;
    if (latency < 1 || latency > 3) return 2;
    uint8_t cpu_pipe[3] = {}, ppu_pipe[3] = {};
    unsigned serial = 0, previous_joy_clock = 0;
    int frame = 0, complete_at = -1;
    bool previous_frame = false;
    // A clock-progress limit also detects a stopped PPU divider.
    for (uint64_t tick = 0; frame < max_frames &&
         tick < uint64_t(max_frames + 1) * 400000; ++tick) {
        top.clk = 0;
        top.reset_nes = top.cold_reset = tick < 100;
        top.eval();
        unsigned buttons = frame >= 120 && frame < 130 ? 8 : 0; // Start
        if (page) {
            int at = frame - 120;
            buttons = at >= 0 && at < (page - 1) * 4 && at % 4 < 2 ? 128 : 0;
            int after = at - (page - 1) * 4 - 4;
            if (after >= 0 && after < row * 4 && after % 4 < 2) buttons = 32;
            if (after >= row * 4 && after < row * 4 + 4) buttons = 1;
        }
        if (top.joypad_out & 1) serial = buttons;
        if ((previous_joy_clock & 1) && !(top.joypad_clock & 1))
            serial = (serial >> 1) | 128;
        previous_joy_clock = top.joypad_clock;
        top.joypad1_data = serial & 1;

        unsigned cpu_address = top.cpumem_addr, ppu_address = top.ppumem_addr;
        if (top.cpumem_write) {
            bool changed = memory[cpu_address] != top.cpumem_dout;
            memory[cpu_address] = top.cpumem_dout;
            if (cpu_address >= RAM + 0x400 && cpu_address < RAM + 0x500 &&
                memory[cpu_address] && frame > 130 && changed) {
                std::printf("RESULT frame=%d $%03x=%02x\n", frame,
                            cpu_address - RAM, memory[cpu_address]);
                std::fflush(stdout);
                if ((memory[cpu_address] & 3) == 2) {
                    char name[80];
                    std::snprintf(name, sizeof(name), "snapshot-%03x-%02x.bin",
                                  cpu_address - RAM, memory[cpu_address]);
                    std::ofstream snapshot(name, std::ios::binary);
                    snapshot.write(reinterpret_cast<char *>(&memory[RAM]), 2048);
                }
            }
        }
        if (top.ppumem_write) memory[ppu_address] = top.ppumem_dout;
        for (int i = latency - 1; i > 0; --i) {
            cpu_pipe[i] = cpu_pipe[i - 1];
            ppu_pipe[i] = ppu_pipe[i - 1];
        }
        if (top.cpumem_read) cpu_pipe[0] = memory[cpu_address];
        if (top.ppumem_read) ppu_pipe[0] = memory[ppu_address];
        top.clk = 1;
        top.eval();
        top.cpumem_din = cpu_pipe[latency - 1];
        top.ppumem_din = ppu_pipe[latency - 1];
        bool at_frame = top.scanline == 240 && top.cycle == 0;
        if (at_frame && !previous_frame) {
            ++frame;
            if (frame % 100 == 0) {
                std::printf("FRAME %d running=%u tally=%u pass=%u\n", frame,
                            memory[RAM + 0x35], memory[RAM + 0x37], memory[RAM + 0x38]);
                std::fflush(stdout);
            }
            // Let the unmodified ROM finish drawing/counting its result table.
            if (!page && frame > 200 && !memory[RAM + 0x35] && memory[RAM + 0x37] == 147) {
                if (complete_at < 0) complete_at = frame;
                if (frame >= complete_at + 3) break;
            }
        }
        previous_frame = at_frame;
    }
    std::ofstream output("ram.bin", std::ios::binary);
    output.write(reinterpret_cast<char *>(&memory[RAM]), 2048);
    std::printf("STOP frame=%d passed=%u total=%u\n", frame,
                memory[RAM + 0x38], memory[RAM + 0x37]);
}
