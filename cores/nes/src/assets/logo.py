#!/usr/bin/env python3
"""Generate the 72x14 startup LOADING... bitmap for gowin_dpb_menu.v.

Each row occupies nine bytes, with the leftmost pixel in bit zero.
Only the existing logo ROM changes; text, font and display timing are preserved.
"""

GLYPHS = {
    'L': ('10000', '10000', '10000', '10000', '10000', '10000', '11111'),
    'O': ('01110', '10001', '10001', '10001', '10001', '10001', '01110'),
    'A': ('01110', '10001', '10001', '11111', '10001', '10001', '10001'),
    'D': ('11110', '10001', '10001', '10001', '10001', '10001', '11110'),
    'I': ('11111', '00100', '00100', '00100', '00100', '00100', '11111'),
    'N': ('10001', '11001', '11001', '10101', '10011', '10011', '10001'),
    'G': ('01110', '10001', '10000', '10111', '10001', '10001', '01110'),
    '.': ('00000', '00000', '00000', '00000', '00000', '00100', '00100'),
}
TEXT = 'LOADING...'
rows = ['0' * 6 + '0'.join(GLYPHS[c][y] for c in TEXT) + '0' * 7
        for y in range(7) for _ in range(2)]
assert len(rows) == 14 and all(len(row) == 72 for row in rows)
bitmap = [sum(int(row[x + bit]) << bit for bit in range(8))
          for row in rows for x in range(0, 72, 8)]
assert len(bitmap) == 126
bitmap.extend([0, 0])
for i in range(4):
    data = bytes(bitmap[i * 32:(i + 1) * 32][::-1]).hex().upper()
    print(f"defparam dpb_inst_0.INIT_RAM_{0x1C + i:02X} = 256'h{data};")
