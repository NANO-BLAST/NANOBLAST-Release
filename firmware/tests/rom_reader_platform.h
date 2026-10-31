#pragma once
// Raw-file adapter for the existing isolated cartridge-loader tests.
class RomFile {
 bool opened_=false;const char*name_="";
public:
 ~RomFile(){close();}
 int open(const char*path,unsigned){name_=path;int result=f_open(&fcore,path,FA_READ);opened_=result==FR_OK;return result;}
 int read(void*data,unsigned n,unsigned*got){return f_read(&fcore,data,n,got);}
 int seek(uint32_t position){return f_lseek(&fcore,position);}
 int close(){if(!opened_)return FR_OK;opened_=false;return f_close(&fcore);}
 uint32_t size()const{return f_size(&fcore);}
 const char*name()const{return name_;}
 const char*error()const{return "ROM open failed";}
 bool is_zip()const{return false;}
};
