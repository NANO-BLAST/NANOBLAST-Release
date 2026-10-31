#include "../storage/zip_rom.h"
#include <fstream>
#include <iterator>
#include <vector>
#include <string>
#include <cstring>
#include <cstdio>
struct Memory:nanoblast::ZipIO{
 std::vector<uint8_t> data,output;std::string name;bool begun=false,committed=false,aborted=false;unsigned fail=0;
 uint32_t size()const override{return data.size();}
 bool read(uint32_t offset,uint8_t*out,unsigned n)override{if(offset>data.size()||n>data.size()-offset||fail==1)return false;std::memcpy(out,data.data()+offset,n);return true;}
 bool begin(const char*s,uint32_t,uint32_t)override{begun=true;name=s;return fail!=2;}
 bool write(const uint8_t*p,unsigned n)override{if(fail==3)return false;output.insert(output.end(),p,p+n);return true;}
 bool finish()override{committed=fail!=4;return committed;}
 void abort()override{aborted=true;}
};
int main(int argc,char**argv){
 if(argc<4)return 2;Memory io;std::ifstream file(argv[1],std::ios::binary);io.data.assign(std::istreambuf_iterator<char>(file),{});io.fail=argc>4?std::stoul(argv[4]):0;
 auto result=nanoblast::extract_zip_rom(io,std::stoul(argv[2]));
 if(int(result)!=std::stoi(argv[3])){std::fprintf(stderr,"Unexpected ZIP result %d: %s\n",int(result),nanoblast::zip_rom_error(result));return 1;}
 if(result==nanoblast::ZipResult::Ok){if(!io.committed||!io.begun||io.aborted)return 3;std::ofstream out(std::string(argv[1])+".out",std::ios::binary);out.write(reinterpret_cast<const char*>(io.output.data()),io.output.size());std::puts(io.name.c_str());}
 else if(io.committed)return 4;
 return 0;
}
