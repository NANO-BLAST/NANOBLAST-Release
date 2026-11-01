"""Serve a local preview backed by the actual C++ menu/browser, without hardware."""
from pathlib import Path
from http.server import ThreadingHTTPServer,BaseHTTPRequestHandler
import argparse,subprocess,json
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--port',type=int,default=1421);a=p.parse_args();binary=Path('/tmp/nanoblast-menu-preview')
subprocess.run(['c++','-std=c++17','-Wall','-Wextra','-Werror','-I'+str(ROOT/'firmware/ui'),'-I'+str(ROOT/'firmware/storage'),str(ROOT/'firmware/ui/nanoblast_menu.cpp'),str(HERE/'preview.cpp'),'-o',str(binary)],check=True)
files={'/helpers.json':(ROOT/'artifacts/horizon-menu/helpers.json','application/json'),'/':(HERE/'index.html','text/html'),'/font.json':(ROOT/'artifacts/horizon-menu/font.json','application/json'),'/horizon.nbbg':(ROOT/'artifacts/horizon-menu/horizon.nbbg','application/octet-stream')}
class Handler(BaseHTTPRequestHandler):
 def respond(self,data,kind='application/json',status=200):
  self.send_response(status);self.send_header('Content-Type',kind);self.send_header('Content-Length',str(len(data)));self.send_header('Cache-Control','no-store');self.end_headers();self.wfile.write(data)
 def do_GET(self):
  item=files.get(self.path)
  if not item:return self.respond(b'Not found','text/plain',404)
  self.respond(item[0].read_bytes(),item[1])
 def do_POST(self):
  try:
   if self.path!='/frame':raise ValueError('Unknown operation')
   size=int(self.headers.get('Content-Length',0))
   if size>16384:raise ValueError('Preview session too long; power-cycle the preview')
   keys=json.loads(self.rfile.read(size))['keys']
   if not isinstance(keys,list) or len(keys)>4096 or any(type(k)!=int or k not in [0,1,4,8,12,16,32,64,128,132,256,1024,1028] for k in keys):raise ValueError('Invalid controller sequence')
   r=subprocess.run([str(binary),*map(str,keys)],check=True,capture_output=True,timeout=3);self.respond(r.stdout)
  except Exception as e:self.respond(str(e).encode(),'text/plain',400)
 def log_message(self,*args):pass
print('Horizon console-menu preview: http://127.0.0.1:'+str(a.port),flush=True)
ThreadingHTTPServer(('127.0.0.1',a.port),Handler).serve_forever()
