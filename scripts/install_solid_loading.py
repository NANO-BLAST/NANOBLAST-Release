"""Guarded developer core/menu update; full backup/readback, no boot-flash write."""
import argparse,datetime,json,sys,struct,zlib,lzma
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'scripts/bl616'))
import updater as u
import development_menu

def load(folder):
    import current_bundle
    return current_bundle.load(folder,ROOT/'src-tauri/resources/nanoblast-v0.2.0')

def main():
    p=argparse.ArgumentParser();p.add_argument('bundle',type=Path);p.add_argument('--backup',type=Path);p.add_argument('--apply',action='store_true');p.add_argument('--port');p.add_argument('--confirmation');a=p.parse_args()
    changes,plan=load(a.bundle)
    if not a.apply:
        u.require(a.backup,'Offline planning requires --backup');before=a.backup.read_bytes();after=plan(before,changes)
        print(json.dumps(dict(status='OFFLINE_PLAN_PASS',before_sha256=u.sha(before),expected_sha256=u.sha(after)),indent=2));return
    u.require(a.port and a.confirmation=='UPDATE '+a.port,'Exact UPDATE port confirmation required')
    ports=[p for p in u.ports() if p['port']==a.port];u.require(len(ports)==1,'UPDATE port missing')
    out=ROOT/'hardware-tests'/('solid-loading-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ'));out.mkdir()
    u.install(u.Transport(a.port,ports[0]['identity'],out),changes,out,planner=plan)
    print('Update verified. Disconnect every USB and power cable for 5 seconds, then reconnect without holding UPDATE. Select a core to load its updated renderer.',flush=True)
if __name__=='__main__':main()
