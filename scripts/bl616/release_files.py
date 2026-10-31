"""Bounded local ZIP/folder/manifest selection. No hardware or network access."""
import json, shutil, stat, zipfile, os
from pathlib import Path
import current_bundle as bundle
import updater as u
MAX_BYTES=20*1024*1024

def find_manifest(root):
    candidates=[];visited=0
    for directory, dirs, files in os.walk(root,followlinks=False):
        visited+=len(dirs)+len(files)
        u.require(visited<=512 and len(Path(directory).relative_to(root).parts)<=5,'Select the extracted firmware folder or its exact manifest, not a source-code folder')
        for name in files:
            if name not in ('manifest.json','development-menu.json'):continue
            path=Path(directory)/name
            u.require(not path.is_symlink(),'Release manifest symlinks are not supported')
            m=bundle.read_json(path)
            if isinstance(m,dict) and (('firmware' in m and 'assets' in m) or m.get('base')=='solid-loading-v0.2.0'):candidates.append(path)
    u.require(len(candidates)==1,'Select the firmware release ZIP, or the exact release manifest; one matching manifest is required')
    return candidates[0]

def select(source, output, release):
    source=Path(source).resolve();output=Path(output)
    u.require(source.exists() and not output.exists(),'Release not found or cache directory already exists')
    output.mkdir(parents=True)
    try:
        if source.is_file() and source.suffix.lower()=='.zip':
            u.require(source.stat().st_size<=MAX_BYTES,'Release ZIP is too large')
            expanded=output/'unpacked';expanded.mkdir()
            with zipfile.ZipFile(source) as z:
                entries=z.infolist();u.require(len(entries)<=128,'Too many files in release ZIP')
                total=0;seen=set()
                for entry in entries:
                    name=entry.filename.rstrip('/')
                    u.require(name and name.casefold() not in seen,'Duplicate release ZIP entry');seen.add(name.casefold())
                    path=bundle.inside(expanded,name)
                    u.require(not stat.S_ISLNK(entry.external_attr>>16),'ZIP symlinks are not supported')
                    total+=entry.file_size;u.require(total<=MAX_BYTES and entry.file_size<=4*1024*1024,'Release ZIP expands beyond the size limit')
                    if entry.is_dir():path.mkdir(parents=True,exist_ok=True);continue
                    path.parent.mkdir(parents=True,exist_ok=True)
                    with z.open(entry) as f:
                        data=f.read(4*1024*1024+1);u.require(len(data)==entry.file_size,'Invalid ZIP entry length')
                    path.write_bytes(data)
            manifest=find_manifest(expanded)
        elif source.is_dir():manifest=find_manifest(source)
        else:
            u.require(source.suffix.lower()=='.json','Choose a release ZIP, extracted release folder or JSON manifest')
            manifest=source
        root=manifest.parent.resolve();version,menu,assets=bundle.describe(root,manifest)
        # Validate the source before copying, then validate the private copy too.
        bundle.load(root,release,manifest=manifest)
        target=output/'package';target.mkdir()
        normalized=dict(version=version,core_format='NBCRXZ01',firmware=menu,assets=assets)
        (target/'manifest.json').write_text(json.dumps(normalized,indent=2)+'\n')
        for record in [menu]+assets:
            src=bundle.inside(root,record['file']);dst=bundle.inside(target,record['file'])
            dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
        changes,_=bundle.load(target,release)
        return dict(version=version,path=str(target.resolve()),source=source.name,bytes=menu['bytes'],sha256=menu['sha256'],cores=len(assets),layout='BL616 / NBCRXZ01')
    except Exception:
        shutil.rmtree(output)
        raise
