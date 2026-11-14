#!/usr/bin/env python3
"""Verifica diferencas de maiuscula/minuscula que quebram o build WEB (Linux/PCK diferencia caixa; Windows nao).

Uso (na raiz do projeto):
    python tools/verificar_caixa_build.py                      # confere os res:// do codigo contra as pastas reais
    python tools/verificar_caixa_build.py build/web/index.pck  # idem + confere o .pck exportado

Sai com codigo 1 se achar problema. Rode SEMPRE antes de publicar no itch.io."""
import glob, os, re, struct, sys

def audit_tree():
    pat = re.compile(r'res://[A-Za-z0-9_\-./ ]+\.[A-Za-z0-9]+')
    bad = []
    for p in glob.glob('**/*', recursive=True):
        if not os.path.isfile(p) or p.startswith(('build/', 'docs/', '.godot/')):
            continue
        if not p.endswith(('.gd', '.tscn', '.json', '.tres', '.cfg', '.html', '.godot')):
            continue
        text = open(p, encoding='utf-8', errors='ignore').read()
        for ref in set(pat.findall(text)):
            if '.godot/' not in ref and not os.path.exists(ref[6:]):
                bad.append((ref, p))
    return bad

def read_pck(path):
    f = open(path, 'rb')
    assert f.read(4) == b'GDPC', 'nao e um .pck'
    ver = struct.unpack('<I', f.read(4))[0]
    f.read(12)
    f.read(4)  # flags
    f.read(8)  # file_base
    dir_off = struct.unpack('<Q', f.read(8))[0] if ver >= 2 else None
    if ver < 2:
        f.read(64)
    else:
        f.seek(dir_off)
    n = struct.unpack('<I', f.read(4))[0]
    names = []
    for _ in range(n):
        ln = struct.unpack('<I', f.read(4))[0]
        names.append(f.read(ln).rstrip(b'\0').decode())
        f.read(8 + 8 + 16 + 4)
    return names

def audit_pck(path):
    tree = {}
    for p in glob.glob('**/*', recursive=True):
        if os.path.isfile(p) and not p.startswith(('build/', 'docs/', '.godot/')):
            tree[p.lower()] = p
    bad = []
    for name in read_pck(path):
        if name.startswith('.godot/') or name.endswith(('.gdc', '.remap')):
            continue
        real = tree.get(name.lower())
        if real is not None and real != name:
            bad.append((name, real))
        elif real is None and name.endswith('.import') and name[:-7].lower() not in tree:
            bad.append((name, '(origem nao existe mais no projeto)'))
    return bad

if __name__ == '__main__':
    problems = 0
    for ref, src in audit_tree():
        print('[CODIGO] %s (em %s) nao existe com essa caixa' % (ref, src)); problems += 1
    if len(sys.argv) > 1:
        for name, real in audit_pck(sys.argv[1]):
            print('[PCK] %s  <->  projeto: %s' % (name, real)); problems += 1
    print('OK: nenhuma diferenca de caixa.' if problems == 0 else '%d problema(s). Reexporte/renomeie antes de publicar.' % problems)
    sys.exit(1 if problems else 0)
