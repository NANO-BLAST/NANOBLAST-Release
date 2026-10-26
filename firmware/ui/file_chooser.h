#pragma once
#include <string>
#include <vector>

#ifdef NANOBLAST_BROWSER_HOST_TEST
#include "../tests/browser_platform.h"
#else
extern "C" {
    #include "ff.h"
}
#endif

using namespace std;
namespace nanoblast {struct Platform;}

struct FileEntry {
    string name;
    bool is_dir;
};

struct FileChooser {
    string rootdir;
    string curdir;
    string curfile;
    string menu_title="GAMES";
    string msg_return = "<< Return to main menu";
    FRESULT last_error=FR_OK;
    nanoblast::Platform *menu_platform=nullptr;
    // FATFS *fs;

    // void set_fs(FATFS *fs);
    bool choose_file(string &res);      // return true if a file was chosen
    bool list_files(string dir, vector<FileEntry> &files, int start, int len, int *count, int known_count=-1);
};
