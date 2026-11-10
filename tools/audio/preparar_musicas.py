#!/usr/bin/env python3
"""
ContalMaster - prepara as TRILHAS (assets/sounds/musica/*.ogg) para o jogo e para a web.

O que faz, para cada .ogg da pasta:
  1. VALIDA o arquivo de verdade (ffprobe): o Godot so le Ogg Vorbis. Arquivo que e MP3/Opus/WAV com
     extensao .ogg (foi o que quebrou a V0.13.1: musica_stop.ogg era MP3) e convertido.
  2. PADRONIZA: 44.1 kHz, estereo, Vorbis (libvorbis, qualidade -q), sem metadados extras.
  3. NIVELA o volume (LUFS integrado) para o mesmo alvo, so com ganho (nao comprime a dinamica) + limitador de picos.
  4. Marca o arquivo ("contalmaster-audio-v1") para NAO reprocessar de novo (reencodar acumula perda).

Requisitos: Python 3 e ffmpeg/ffprobe no PATH (Windows: `winget install Gyan.FFmpeg`, depois FECHE e
reabra o terminal para o PATH atualizar).
Uso (na raiz do projeto, onde esta o project.godot):
    python tools/audio/preparar_musicas.py --check     # so confere, nao altera nada
    python tools/audio/preparar_musicas.py             # processa o que ainda nao foi processado
    python tools/audio/preparar_musicas.py --force     # reprocessa tudo (use o ORIGINAL, nao um ja comprimido)
    python tools/audio/preparar_musicas.py --quality 2 --target-lufs -15
Efeitos sonoros (assets/sounds/efeitos) NAO sao tocados por este script.

V0.13.4 (correcoes):
  - ffmpeg/ffprobe fora do PATH agora mostra mensagem clara (antes: traceback FileNotFoundError).
  - A marca "ja processado" e lida tambem do metadado do STREAM (ffmpeg novo grava ali, nao no formato);
    antes a marca nunca era vista e toda rodada reencodava tudo.
  - Arquivo travado (Godot aberto / antivirus no Windows) tem novas tentativas e erro legivel; um arquivo
    com problema nao derruba o lote inteiro.
  - Sobras *.tmp.ogg de uma rodada interrompida sao ignoradas/limpas em vez de virarem "trilha".
  - Codigo de saida 1 se algum arquivo falhou (util para conferir antes do commit).
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

TAG = "contalmaster-audio-v1"
DEFAULT_DIR = "assets/sounds/musica"
TMP_SUFFIX = ".tmp.ogg"


def run(cmd):
    """subprocess.run que NUNCA levanta por executavel ausente: devolve returncode 127."""
    try:
        return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    except OSError as e:
        return subprocess.CompletedProcess(cmd, 127, "", f"nao foi possivel executar '{cmd[0]}': {e}")


def probe(path):
    r = run(["ffprobe", "-v", "error", "-show_entries",
             "stream=codec_name,sample_rate,channels:stream_tags=comment:format=format_name,duration:format_tags=comment",
             "-of", "json", str(path)])
    if r.returncode != 0:
        return None
    try:
        data = json.loads(r.stdout or "{}")
    except json.JSONDecodeError:
        return None
    stream = (data.get("streams") or [{}])[0]
    fmt = data.get("format", {})
    # A marca pode estar no formato (ffmpeg antigo) ou no stream (ffmpeg novo): olha nos dois.
    tags_blob = json.dumps(fmt.get("tags", {})) + json.dumps(stream.get("tags", {}))
    return {
        "codec": stream.get("codec_name", "?"),
        "rate": int(stream.get("sample_rate", 0) or 0),
        "channels": int(stream.get("channels", 0) or 0),
        "container": fmt.get("format_name", "?"),
        "duration": float(fmt.get("duration", 0) or 0),
        "tagged": TAG in tags_blob,
    }


def loudness(path):
    """LUFS integrado (EBU R128) do arquivo, ou None se falhar."""
    r = run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(path), "-af", "ebur128=peak=true", "-f", "null", "-"])
    summary = r.stderr.split("Summary:")[-1]
    m = re.search(r"I:\s+(-?[\d.]+)\s+LUFS", summary)
    return float(m.group(1)) if m else None


def is_valid_vorbis(info):
    return info is not None and info["codec"] == "vorbis" and "ogg" in info["container"]


def replace_with_retry(tmp, dst, attempts=5, wait=1.0):
    """os.replace com novas tentativas: no Windows falha se o Godot/antivirus estiver com o arquivo aberto."""
    last = None
    for i in range(attempts):
        try:
            os.replace(tmp, dst)
            return
        except PermissionError as e:
            last = e
            time.sleep(wait)
    raise RuntimeError(f"nao consegui substituir {dst.name} (arquivo em uso?). Feche o Godot e tente de novo. ({last})")


def convert(src, args, gain_db):
    tmp = src.with_name(src.stem + TMP_SUFFIX)
    filters = f"aresample={args.rate},volume={gain_db:.2f}dB,alimiter=limit=0.84:attack=5:release=60:level=disabled"
    cmd = ["ffmpeg", "-v", "error", "-y", "-i", str(src), "-map", "0:a:0", "-map_metadata", "-1", "-af", filters,
           "-ac", "2", "-c:a", "libvorbis", "-q:a", str(args.quality), "-metadata", f"comment={TAG}", "-f", "ogg", str(tmp)]
    r = run(cmd)
    if r.returncode != 0 or not tmp.exists():
        if tmp.exists():
            tmp.unlink()
        raise RuntimeError(r.stderr.strip() or "falha no ffmpeg")
    try:
        replace_with_retry(tmp, src)
    except RuntimeError:
        if tmp.exists():
            tmp.unlink()
        raise


def main():
    ap = argparse.ArgumentParser(description="Valida, padroniza e comprime as trilhas do ContalMaster.")
    ap.add_argument("folder", nargs="?", default=DEFAULT_DIR, help="pasta das trilhas (padrao: %(default)s)")
    ap.add_argument("--check", action="store_true", help="apenas confere; nao altera arquivos")
    ap.add_argument("--force", action="store_true", help="reprocessa mesmo os ja marcados")
    ap.add_argument("--quality", type=float, default=1.5, help="qualidade Vorbis -1..10 (1.5 ~ 88 kbps; 2 ~ 96; 3 ~ 112). Padrao %(default)s")
    ap.add_argument("--rate", type=int, default=44100, help="taxa de amostragem. Padrao %(default)s")
    ap.add_argument("--target-lufs", type=float, default=-14.0, help="volume alvo (LUFS integrado). Padrao %(default)s")
    args = ap.parse_args()

    for tool in ("ffmpeg", "ffprobe"):
        if shutil.which(tool) is None or run([tool, "-version"]).returncode != 0:
            sys.exit(f"ERRO: '{tool}' nao encontrado no PATH. Instale o ffmpeg (Windows: winget install Gyan.FFmpeg) "
                     f"e FECHE/REABRA o terminal para o PATH atualizar. Teste com: {tool} -version")
    folder = Path(args.folder)
    if not folder.is_dir():
        sys.exit(f"ERRO: pasta '{folder}' nao existe. Rode na raiz do projeto (onde esta o project.godot).")

    # Sobras de uma rodada interrompida: nao sao trilhas e nao podem ir para o export.
    for stale in sorted(folder.glob(f"*{TMP_SUFFIX}")):
        if args.check:
            print(f"AVISO: sobra de rodada interrompida (apague): {stale.name}")
        else:
            try:
                stale.unlink()
                print(f"Removida sobra de rodada interrompida: {stale.name}")
            except OSError as e:
                print(f"AVISO: nao consegui remover {stale.name}: {e}")
    files = sorted(p for p in folder.glob("*.ogg") if not p.name.endswith(TMP_SUFFIX))
    if not files:
        sys.exit(f"Nenhum .ogg em {folder} (rode na raiz do projeto).")

    print(f"{'arquivo':34} {'formato real':14} {'antes':>9} {'depois':>9}  LUFS antes -> depois")
    total_before = total_after = 0
    problems = 0
    for f in files:
        info = probe(f)
        size_before = f.stat().st_size
        total_before += size_before
        fmt = "ILEGIVEL" if info is None else f"{info['codec']}/{info['rate']//1000}k/{info['channels']}ch"
        ok_fmt = is_valid_vorbis(info) and info["rate"] == args.rate and info["channels"] == 2
        done = info is not None and info["tagged"] and not args.force
        lufs_before = loudness(f)
        if args.check or done:
            status = "ok" if (ok_fmt or done) else "PRECISA CONVERTER"
            if status != "ok":
                problems += 1
            elif not done and lufs_before is not None and abs(lufs_before - args.target_lufs) > 1.0:
                status = "ok, mas volume fora do alvo (use sem --check para nivelar)"
            lufs_txt = "?" if lufs_before is None else f"{lufs_before:5.1f}"
            print(f"{f.name:34} {fmt:14} {size_before/1048576:7.2f}MB {'':>9}  {lufs_txt}  [{status}]")
            total_after += size_before
            continue
        gain = 0.0 if lufs_before is None else args.target_lufs - lufs_before
        try:
            convert(f, args, gain)
        except (RuntimeError, OSError) as e:
            problems += 1
            print(f"{f.name:34} {fmt:14} ERRO: {e}")
            total_after += size_before
            continue
        size_after = f.stat().st_size
        total_after += size_after
        lufs_after = loudness(f)
        print(f"{f.name:34} {fmt:14} {size_before/1048576:7.2f}MB {size_after/1048576:7.2f}MB  "
              f"{lufs_before if lufs_before is not None else float('nan'):5.1f} -> {lufs_after if lufs_after is not None else float('nan'):5.1f}")
    print(f"\nTotal: {total_before/1048576:.1f} MB -> {total_after/1048576:.1f} MB")
    if problems:
        print(f"ATENCAO: {problems} arquivo(s) com problema (veja acima).")
    if args.check:
        sys.exit(1 if problems else 0)
    if problems:
        sys.exit(1)
    print("Pronto. Abra o Godot para reimportar (ele recria os .import sozinho).")


if __name__ == "__main__":
    main()
