#define NANOBLAST_SRAM_VALIDATION
#define main normal_runtime_main
#include "runtime_test.cpp"
#undef main
int main(){
 built_in=true;reply=1;program_ok=true;
 assert(nanoblast_wait_boot_core()&&asset_activations==0);
 // A realistic slow cold boot must not be overwritten with NES recovery.
 reply=5;delayed_core_queries=8;unsigned before_slow_boot=asset_activations;
 assert(nanoblast_wait_boot_core()&&reply==5&&asset_activations==before_slow_boot);
 assert(std::string(startup_diagnostic)=="Startup: SMS from power-on");
 reply=-1;
 unsigned before_missing=asset_activations;
 assert(!nanoblast_wait_boot_core()&&reply==-1&&asset_activations==before_missing);
 assert(std::string(startup_diagnostic)=="Startup: no core reply");
 reply=1;TextFrames frames;Runtime runtime(frames);
 for(unsigned id:{2u,5u,1u}){
  assert(runtime.switch_core(id)==nanoblast::SwitchResult::Loaded);
  assert(runtime.detected_core()==id&&reply==int(id));
  assert(asset_saves==0&&persisted==0&&reloads==0&&staged==0);
 }
 // The persisted boot-flash flag never triggers a startup reload.
 reply=1;unsigned prior=asset_activations;
 loop_test=true;try{nanoblast_menu_loop();assert(false);}catch(int){}loop_test=false;
 assert(reply==1&&asset_activations==prior);
 assert(asset_saves==0&&persisted==0&&reloads==0);
 reply=1;program_ok=false;
 assert(runtime.switch_core(2)==nanoblast::SwitchResult::Failed&&runtime.detected_core()==1);
 assert(asset_saves==0&&persisted==0&&reloads==0);
 reply=-1;assert(!nanoblast_wait_boot_core());
 assert(asset_saves==0&&persisted==0&&reloads==0);
 // Only the button writes boot flash; subsequent switching remains volatile.
 reply=1;program_ok=true;bridge=true;runtime.remember_core(1);
 assert(runtime.save_boot_core()&&asset_saves==1);
 assert(runtime.switch_core(5)==nanoblast::SwitchResult::Loaded&&asset_saves==1&&reply==5);
 assert(runtime.save_boot_core()&&asset_saves==2);
 assert(runtime.switch_core(2)==nanoblast::SwitchResult::Loaded&&asset_saves==2&&reply==2);
 puts("PASS SRAM core selections; one-shot save current core; subsequent selections stay volatile; no startup core reload");
}
