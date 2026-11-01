// Unmodified ROM through the production shared SDRAM controller.
// Ideal CL2/BL1 pin model and clocks; no analog timing signoff.
#include "VNESBoard.h"
using VNES=VNESBoard;
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

    top.fclk=0;top.ram_drive=0;top.ram_din=0;
    unsigned rows[4]={};unsigned mismatches=0,samples=0;uint64_t time=0,read_at=~uint64_t(0),release_at=~uint64_t(0);uint32_t read_data=0;
    const int max_frames = std::atoi(argv[2]);
    const int page = argc > 3 ? std::atoi(argv[3]) : 0;
    const int row = argc > 4 ? std::atoi(argv[4]) : 0;
    const int latency = std::getenv("MEMORY_LATENCY") ?
        std::atoi(std::getenv("MEMORY_LATENCY")) : 1;
    if (latency < 1 || latency > 3) return 2;
    uint8_t cpu_pipe[3] = {}, ppu_pipe[3] = {};
    std::vector<uint8_t> pixels(256*240);
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

        for(unsigned sub : {0u,8u,10u,16u,24u,26u,32u,40u,42u}){
            time=tick*48+sub;
            if(time==release_at)top.ram_drive=0;
            if(time==read_at){top.ram_din=read_data;top.ram_drive=1;}
            if(sub==24 && frame<100 && top.dbg_ppu_sample){++samples;if(top.dbg_ppu_din!=memory[top.ppumem_addr]){if(mismatches<10)std::printf("PPU MISMATCH frame=%d line=%u cycle=%u address=%06x expected=%02x got=%02x\n",frame,top.scanline,top.cycle,top.ppumem_addr,memory[top.ppumem_addr],top.dbg_ppu_din);++mismatches;}}
            top.clk=sub>=24;top.fclk=(time%16)<8;top.eval();
            if(time%16==10){
                unsigned cmd=top.ram_cmd,bank=top.ram_bank;
                if(cmd==3)rows[bank]=top.ram_addr;
                unsigned address=(bank<<21)|(rows[bank]<<10)|((top.ram_addr&255)<<2);
                if(cmd==5){
                    read_data=0;
                    for(unsigned lane=0;lane<4;++lane)if(address+lane<memory.size())read_data|=uint32_t(memory[address+lane])<<(lane*8);
                    read_at=time+32;release_at=read_at+16;
                }
                if(cmd==4){
                    for(unsigned lane=0;lane<4;++lane)if(!(top.ram_mask&(1<<lane))&&address+lane<memory.size()){
                        const unsigned at=address+lane;const uint8_t value=top.ram_dout>>(lane*8);
                        const bool changed=memory[at]!=value;memory[at]=value;
                        if(frame>120 && at>=RAM+0x400 && at<RAM+0x500 && changed && value){
                            std::printf("RESULT frame=%d $%03x=%02x\n",frame,at-RAM,value);std::fflush(stdout);
                        }
                    }
                }
            }
        }
        if(frame<100 && top.cycle<256 && top.scanline<240)pixels[top.scanline*256+top.cycle]=top.color;
        bool at_frame = top.scanline == 240 && top.cycle == 0;
        if (at_frame && !previous_frame) {
            ++frame;
            if (frame % 100 == 0) {
                std::printf("FRAME %d running=%u tally=%u pass=%u\n", frame,
                            memory[RAM + 0x35], memory[RAM + 0x37], memory[RAM + 0x38]);
                std::ofstream progress("progress.bin",std::ios::binary);progress.write(reinterpret_cast<char *>(&memory[RAM]),2048);
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
    std::printf("Initial rendering samples=%u stale_bytes=%u\n",samples,mismatches);
    std::ofstream report("rendering.json");report<<"{\"samples\":"<<samples<<",\"stale_bytes\":"<<mismatches<<"}\n";
    std::ofstream image("pixels.bin",std::ios::binary);image.write(reinterpret_cast<char *>(pixels.data()),pixels.size());
    std::ofstream output("ram.bin", std::ios::binary);
    output.write(reinterpret_cast<char *>(&memory[RAM]), 2048);
    std::printf("STOP frame=%d passed=%u total=%u\n", frame,
                memory[RAM + 0x38], memory[RAM + 0x37]);
}
