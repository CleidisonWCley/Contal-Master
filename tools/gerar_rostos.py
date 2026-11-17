#!/usr/bin/env python3
"""V0.15.4 - Gera os rostos pre-recortados dos personagens (assets/sprites/personagens/<id>/<id>_face.png).

Por que: o FaceAvatar desenhava o recorte direto do sprite _3 (1120x1500). Isso carrega 9 texturas grandes so para
mostrar avatares de 56-150 px (~6,7 MB de memoria cada na GPU, ruim na web/celular) e dependia de desenho manual
(_draw + regiao), que aparecia como quadrado branco no teste visual. Agora cada rosto e um PNG pequeno (256x256).

Uso (na raiz do projeto):  python tools/gerar_rostos.py
Le os numeros de FACES em scripts/ui/FaceAvatar.gd, entao para ajustar um rosto: mude la, rode isto e abra o Godot.
Requer: pip install pillow
"""
import hashlib, pathlib, re, sys
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = 256

def read_faces():
    text = (ROOT / "scripts/ui/FaceAvatar.gd").read_text(encoding="utf-8")
    block = text.split("const FACES := {", 1)[1].split("}", 1)[0]
    faces = {}
    for m in re.finditer(r'"(\w+)":\s*Vector3\(([\d.]+),\s*([\d.]+),\s*([\d.]+)\)', block):
        faces[m.group(1)] = tuple(float(m.group(i)) for i in (2, 3, 4))
    return faces

IMPORT = '''[remap]

importer="texture"
type="CompressedTexture2D"
path="res://.godot/imported/{name}.png-{md5}.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://{rel}"
dest_files=["res://.godot/imported/{name}.png-{md5}.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
'''

def main():
    faces = read_faces()
    if not faces:
        sys.exit("FACES nao encontrado em FaceAvatar.gd")
    for cid, (cx, cy, s) in faces.items():
        src = ROOT / f"assets/sprites/personagens/{cid}/{cid}_3.png"
        im = Image.open(src).convert("RGBA")
        w, h = im.size
        side = s * w
        box = (round(cx * w - side / 2), round(cy * h - side / 2), round(cx * w + side / 2), round(cy * h + side / 2))
        # Image.crop preenche o que passa da borda com transparente (nada e esticado).
        face = im.crop(box).resize((OUT, OUT), Image.LANCZOS)
        dst = src.with_name(f"{cid}_face.png")
        face.save(dst, optimize=True)
        rel = dst.relative_to(ROOT).as_posix()
        md5 = hashlib.md5(f"res://{rel}".encode()).hexdigest()
        # .import so e criado se nao existir (o Godot mantem o uid dele depois).
        imp = dst.with_name(dst.name + ".import")
        if not imp.exists():
            imp.write_text(IMPORT.format(name=f"{cid}_face", md5=md5, rel=rel), encoding="utf-8")
        print(f"{rel}: {dst.stat().st_size/1024:.0f} KB")

if __name__ == "__main__":
    main()
