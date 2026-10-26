"""Prove packed arithmetic against the actual Yosys $alu semantics.

The ALU54D hardware configuration is combinational A+B (Gowin UG287 mode0,
ACCLOAD=0, all registers bypassed). This proof covers the lane packing and
every original signedness, width, invert-B, carry-in, sum and used carry-out.
It does not replace hardware timing or board validation of the primitive.
"""
import argparse, collections, json, subprocess
from pathlib import Path

p=argparse.ArgumentParser();p.add_argument('manifest',type=Path);p.add_argument('--out',type=Path);a=p.parse_args()
base=Path(__file__).resolve().parents[4];out=a.out or base/'outputs/snes-nano-alu54'
out.mkdir(parents=True,exist_ok=True)
changes=json.loads(a.manifest.read_text())['mapped'];groups=collections.defaultdict(list)
ports=[];body=[]
for i,c in enumerate(changes):
    par=c['original']['parameters'];w=c['width'];aw=int(par['A_WIDTH'],2);bw=int(par['B_WIDTH'],2)
    sa=int(par['A_SIGNED'],2);sb=int(par['B_SIGNED'],2);bi=c['original']['connections']['BI'][0]
    ports += [f'input [{aw-1}:0] a{i}',f'input [{bw-1}:0] b{i}',f'input ci{i}']
    body += [f'wire [{w-1}:0] aa{i},bb{i},raw_b{i},y{i},x{i},co{i};',
        f'assign aa{i}='+ (f'$signed(a{i});'if sa and sb else f'a{i};'),
        f'assign raw_b{i}='+ (f'$signed(b{i});'if sa and sb else f'b{i};'),
        f'assign bb{i}='+('~'if bi=='1'else'')+f'raw_b{i};',
        f'\\$alu #(.A_WIDTH({aw}),.B_WIDTH({bw}),.Y_WIDTH({w}),.A_SIGNED({sa}),.B_SIGNED({sb})) original{i} '
        f'(.A(a{i}),.B(b{i}),.CI(ci{i}),.BI(1\'b{bi}),.Y(y{i}),.X(x{i}),.CO(co{i}));']
    groups[c['block']].append((i,w))
for g,lanes in groups.items():
    used=sum(w+1 for _,w in lanes);pad=54-used
    def operand(letter):
        chunks=[f'{{{letter}{i},ci{i}}}'for i,w in reversed(lanes)]
        if pad:chunks.insert(0,f"{pad}'d0")
        return '{'+','.join(chunks)+'}'
    body += [f'wire [53:0] sum{g}={operand("aa")}+{operand("bb")};']
    offset=0
    for i,w in lanes:
        body += [f'always @* begin assert(sum{g}[{offset+w}:{offset+1}]==y{i}); '
                 f'assert(sum{g}[{offset+w+1}]==co{i}[{w-1}]); end']
        offset+=w+1
source=out/'lane-equivalence.sv';source.write_text('module lane_equivalence('+','.join(ports)+');\n'+'\n'.join(body)+'\nendmodule\n')
cmd=f'read_verilog -formal -sv -icells {source}; prep -top lane_equivalence -flatten; chformal -lower; sat -verify -prove-asserts'
with(out/'lane-equivalence.log').open('w')as log:
    subprocess.run([str(base/'work/oss-cad-suite/bin/yosys'),'-Q','-p',cmd],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=60)
print(f'PASS exhaustive packed arithmetic equivalence: {len(changes)} original add/sub units in {len(groups)} independent lanes groups')
