#include "background_install.h"
#include <cstring>
namespace nanoblast {
BackgroundInstallResult install_background(BackgroundInstallIO&io,const uint8_t *header,unsigned header_size,const uint8_t *data,unsigned size){
 if(io.exists())return BackgroundInstallResult::Exists;
 if(!io.matches_original(header,header_size))return BackgroundInstallResult::NotApplicable;
 if(!size||!io.begin())return BackgroundInstallResult::Failed;
 for(unsigned offset=0;offset<size;){
  unsigned n=size-offset>2048?2048:size-offset;
  if(!io.write(data+offset,n)){io.cancel();return BackgroundInstallResult::Failed;}
  offset+=n;io.progress(offset,size);
 }
 if(!io.finish()||!io.open_readback()){io.cancel();return BackgroundInstallResult::Failed;}
 uint8_t buffer[1024];
 for(unsigned offset=0;offset<size;){
  unsigned n=size-offset>sizeof buffer?sizeof buffer:size-offset;
  if(!io.readback(buffer,n)){io.cancel();return BackgroundInstallResult::Failed;}
  for(unsigned i=0;i<n;i++)if(buffer[i]!=data[offset+i]){
   io.mismatch(offset+i,data[offset+i],buffer[i]);io.cancel();return BackgroundInstallResult::Failed;
  }
  offset+=n;
 }
 if(!io.commit()){io.cancel();return BackgroundInstallResult::Failed;}
 return BackgroundInstallResult::Installed;
}
}
