#!/usr/bin/env python3
"""Two exact projection blocks on the pinned feedback001 page; no old assembler."""
import argparse,hashlib,json,re
from pathlib import Path

def sha(v):return hashlib.sha256(v).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--package',type=Path,default=Path(__file__).resolve().parent);p.add_argument('--output',type=Path,required=True);a=p.parse_args();b=json.loads((a.package/'BASELINE.json').read_text())
 for n,pin in b['inputs'].items():
  v=(a.root/n).read_bytes()
  if sha(v)!=pin['sha256'] or len(v)!=pin['bytes']:raise RuntimeError('Input drift:'+n)
 original=(a.root/b['land_source']).read_text()
 if sha(original.encode())!=b['land_sha256_expected']:raise RuntimeError('LAND baseline mismatch')
 def bundled(s):
  s=re.sub(r'^import\s*\{([^}]+)\}\s*from\s*[\'\"]\./([^\'\"]+)[\'\"];?\s*$',lambda x:'const {'+x[1]+'}='+b['modules'][x[2]]+';',s,flags=re.M)
  return re.sub(r'\bexport (function|const)\s+(\w+)',r'\1 \2',s)
 html=original;pairs=[]
 for n in b['patched']:
  old=bundled((a.root/b['source_dir']/n).read_text());new=bundled((a.package/'ui'/n).read_text())
  if html.count(old)!=1:raise RuntimeError('Source/LAND mismatch:'+n)
  html=html.replace(old,new);pairs.append((old,new))
 marker='content="LAND-COMMAND-FEEDBACK-CANDIDATE-001"';newmarker='content="LAND-MULTIPLICATION-PROJECTION-ALIGNMENT-001"'
 if html.count(marker)!=1:raise RuntimeError('Build marker mismatch')
 html=html.replace(marker,newmarker);inverse=html.replace(newmarker,marker)
 for old,new in reversed(pairs):
  if inverse.count(new)!=1:raise RuntimeError('Ambiguous candidate block')
  inverse=inverse.replace(new,old)
 if inverse!=original:raise RuntimeError('Unexpected change outside two blocks')
 a.output.mkdir(parents=True,exist_ok=False);(a.output/'LAND.html').write_text(html)
 print(json.dumps({'source_blocks':2,'build_marker':1,'inverse':'byteidentical','bytes':len(html.encode()),'sha256':sha(html.encode()),'dynamic_QA':False}))
if __name__=='__main__':main()
