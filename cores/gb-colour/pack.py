"""Pack independent 64-KiB XZ/LZMA2 blocks into the unchanged GB extents."""
from pathlib import Path
import lzma,zlib,struct,json,hashlib,time
P=Path(__file__).resolve().parent/'build';raw=(P/'gb-mister-nano20k.bin').read_bytes();block=65536;count=(len(raw)+block-1)//block;head=bytearray(b'\xff'*4096);data=bytearray();start=time.time()
struct.pack_into('<8sIIIIIIII',head,0,b'NBGBXZ01',7,len(raw),zlib.crc32(raw),0x4b30324e,0,count,block,0)
for i in range(count):
 b=raw[i*block:(i+1)*block];enc=lzma.compress(b,format=lzma.FORMAT_XZ,check=lzma.CHECK_CRC32,filters=[{'id':lzma.FILTER_LZMA2,'dict_size':16384,'preset':9|lzma.PRESET_EXTREME}]);assert lzma.decompress(enc)==b
 stored=len(enc)>=len(b)
 if stored:enc=b
 struct.pack_into('<II',head,64+i*8,4096+len(data),len(enc)|(0x80000000 if stored else 0));data+=enc
struct.pack_into('<I',head,24,len(data));struct.pack_into('<I',head,36,zlib.crc32(head[:36]+head[64:64+count*8]));encoded=bytes(head+data)
result={'format':'NBGBXZ01','block_bytes':block,'packed_bytes':len(encoded),'slot_bytes':0x58000,'fits':len(encoded)<=0x58000,'headroom_bytes':0x58000-len(encoded),'sha256':hashlib.sha256(encoded).hexdigest(),'block_round_trip':'PASS','compressor':'XZ/LZMA2 16-KiB dictionary, CRC32 per block','seconds':time.time()-start}
assert result['fits'],result
(P/'gb-mister-core-packed.bin').write_bytes(encoded);(P/'packing-check.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
