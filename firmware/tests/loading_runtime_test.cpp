// Reuse the transport stubs while exercising the real game-loading adapter.
#define main legacy_runtime_main
#include "runtime_test.cpp"
#undef main
bool nanoblast_prepare_gb_game(){return true;}
const char *gb_diagnostic(unsigned){return "GB test";}
int main(){
 TextFrames buffers;Runtime runtime(buffers);runtime.remember_core(5);
 reply=5;cancel=false;rom_result=0;
 std::memset(screen,'?',sizeof screen);
 assert(runtime.browse_games(5)==nanoblast::BrowseResult::Loaded);
 assert(core_running&&!game_loading);
 // load_rom's stub checks the solid panel command, centred label and cleared rows.
 bytes.clear();rom_result=1;
 assert(runtime.browse_games(5)==nanoblast::BrowseResult::Failed);
 assert(!core_running&&!game_loading);
 cancel=true;bytes.clear();
 assert(runtime.browse_games(5)==nanoblast::BrowseResult::Cancelled&&!game_loading);
 assert(bytes.size()==16); // Selection is cleared around the browser, no loading panel.
 cancel=false;chosen_rom="Game.zip";rom_result=0;
 assert(runtime.browse_games(5)==nanoblast::BrowseResult::Loaded&&loaded_rom=="usb:/sms/Game.zip"&&!game_loading);
 rom_result=FR_DISK_ERR;loaded_rom.clear();
 assert(runtime.browse_games(5)==nanoblast::BrowseResult::Failed&&loaded_rom=="usb:/sms/Game.zip"&&!game_loading);
 puts("PASS loading runtime: centred black box, browser cleared, load failure and cancellation cleanup");
 return 0;
}
