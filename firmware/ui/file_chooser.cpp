#include <vector>
#include <string>
#include <algorithm>

#include "file_chooser.h"
#include "nanoblast_menu.h"
#ifndef NANOBLAST_BROWSER_HOST_TEST
#include "overlay.h"
#include "utils.h"
#endif

#define PAGESIZE 10
#define TOPLINE 15

// void FileChooser::set_fs(FATFS *fs) {
//     this->fs = fs;
// }

// list files in dir, starting from number `start` and return at most `len` files. `count` is set to total number of files.
bool FileChooser::list_files(string dir, vector<FileEntry> &files, int start, int len, int *count, int known_count) {
    DIR d;
    
    last_error=f_opendir(&d, dir.c_str());
    if (last_error != FR_OK)
        return false;
    files.clear();

    *count = known_count>=0?known_count:0;

    FILINFO fno;
    while ((last_error=f_readdir(&d, &fno)) == FR_OK && fno.fname[0] != 0) {
        if(known_count<0)(*count)++;
        if (start > 0) {
            start--;
        } else if (static_cast<int>(files.size()) < len)
            files.push_back({fno.fname, (fno.fattrib & AM_DIR)!=0});
        // Count once per opened folder. Later pages stop after their last row.
        if(known_count>=0&&static_cast<int>(files.size())>=len)break;
    }
    const auto closed=f_closedir(&d);
    if(last_error==FR_OK)last_error=closed;
    return last_error==FR_OK;
}

// Suppress the opening press per button, rather than waiting indefinitely for
// every controller to report a completely neutral state. B remains usable
// even when A or a button on another controller stays held.
struct BrowserInput {
    uint16_t previous;
    unsigned repeats=0;
    static uint16_t read() {
        uint16_t a=0,b=0,c=0,d=0;
        get_joypad_states(&a,&b,&c,&d);return a|b|c|d;
    }
    BrowserInput():previous(read()){}
    int choice(int count,int &active) {
        const uint16_t buttons=read(),pressed=buttons&~previous;
        previous=buttons;
        if(pressed&0x001)return 1;
        if(pressed&0x100)return count?4:0;
        if(pressed&0x080)return 2;
        if(pressed&0x040)return 3;
        const uint16_t direction=buttons&0x30;
        if(!direction){repeats=0;return 0;}
        bool move=(pressed&0x30)!=0;
        if(move)repeats=0;
        else if(++repeats>=20){move=true;repeats=10;}
        if(move){
            if(direction&0x10){if(active>0)--active;}
            else if(active+1<count)++active;
        }
        return 0;
    }
};

static void wait_legacy_release() {
    while(BrowserInput::read()&(0x100|0x001|0x40|0x80))delay(10);
}

bool FileChooser::choose_file(string &res) {
    last_error=FR_OK;
    int page = 0, pages, total;
    int active = 0;
    vector<FileEntry> files;
    BrowserInput input;
    string counted_directory;
    int known_total=-1;

    while (1) {
        if(!menu_platform){overlay_clear();overlay_status("Reading games...");}
        if(counted_directory!=curdir){counted_directory=curdir;known_total=-1;}
        bool r = list_files(this->curdir, files, page*PAGESIZE, PAGESIZE, &total,known_total);
        if(r)known_total=total;
        const bool missing_root=!r&&last_error==FR_NO_PATH&&curdir==rootdir;
        if(missing_root){
            files.clear();total=0;
            // Missing core folders are an empty browser state; B returns home.
            last_error=FR_OK;
        }
        if (r||missing_root) {
            pages = std::max(1,(total+PAGESIZE-1) / PAGESIZE);
            if(page>=pages){page=pages-1;active=0;continue;}
            if(menu_platform){
                menu_platform->clear();
                menu_platform->large_text(false);
                menu_platform->half_cell_row(-1);
                menu_platform->panel(true,1,14,31,25);
                menu_platform->text(1,27,"U/D Move L/R Page A:Sel B:Back");
                std::string status="Page "+std::to_string(page+1)+"/"+std::to_string(pages);
                menu_platform->text(1+(31-static_cast<unsigned>(status.size()))/2,25,status.c_str());
                if(files.empty()){
                    if(missing_root){
                        const auto slash=rootdir.find_last_of('/');
                        const std::string label="Missing /"+rootdir.substr(slash+1)+" folder";
                        menu_platform->text(2,TOPLINE,label.c_str());
                    }else menu_platform->text(2,TOPLINE,"Empty folder");
                }
            }else{overlay_status("Page ");overlay_printf("%d/%d",page+1,pages);}
            if (active >= static_cast<int>(files.size()))
                active = files.empty()?0:static_cast<int>(files.size())-1;
            for (int i = 0; i < PAGESIZE; i++) {
                if(!menu_platform)overlay_cursor(2, i+TOPLINE);
                if (i < static_cast<int>(files.size())) {
                    std::string label=files[i].name;
                    if(files[i].is_dir)label+="/";
                    if(menu_platform)menu_platform->text(2,i+TOPLINE,label.c_str());
                    else overlay_printf("%s",label.c_str());
                }
            }
            if(menu_platform){
                if(files.empty())menu_platform->selection(false,0,0,0,0);
                else menu_platform->selection(true,1,TOPLINE+active,31,TOPLINE+active);
                menu_platform->present();
            }
            if(!menu_platform)wait_legacy_release();
            while (1) {
                int previous_active=active;
                int r = menu_platform ? input.choice(files.size(),active) : joy_choice(TOPLINE, files.size(), &active, OSD_KEY_CODE,true);
                if(menu_platform&&previous_active!=active){
                    menu_platform->selection(true,1,TOPLINE+active,31,TOPLINE+active);
                    // Selection moves immediately; the repeat timer owns pacing.
                }
                if(r==1){
                    if(curdir==rootdir){if(!menu_platform)wait_legacy_release();return false;}
                    auto slash=curdir.find_last_of('/');
                    curdir=slash==string::npos||slash<rootdir.size()?rootdir:curdir.substr(0,slash);
                    active=0;page=0;break;
                }else if(r==4&&!files.empty()){
                    if(files[active].is_dir){
                        if(!curdir.empty()&&curdir.back()!='/'&&curdir.back()!=':')curdir+='/';
                        curdir+=files[active].name;active=0;page=0;break;
                    }else{
                        res=curdir;if(!res.empty()&&res.back()!='/'&&res.back()!=':')res+='/';
                        res+=files[active].name;return true;
                    }
                } else if (r == 2 && page < pages-1) {
                    page++;
                    break;
                } else if (r == 3 && page > 0) {
                    page--;
                    break;
                }
                delay(10);
            }
        } else {
            overlay_status("Error opening directory");
            overlay_printf(" %d", last_error);
            return false;
        }
    }        
}
