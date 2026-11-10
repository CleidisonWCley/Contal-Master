#!/usr/bin/env python3
"""
ContalMaster - gera o efeito sonoro da PORTA da sala de reuniao (cena de chegada, ArrivalScene).

V0.13.4: o rangido por codigo tinha sido removido na V0.13.2.1 e nao havia .ogg. Este script sintetiza
o efeito (sem samples de terceiros, sem direitos autorais) e grava assets/sounds/efeitos/porta_abrindo.ogg.

O som acompanha a animacao da porta em ArrivalScene.gd (DOOR_OPEN_SECONDS = 1.9 s, curva cubica in/out):
  - 0.00 s  trava destravando (dois estalos curtos);
  - 0.05-1.90 s  madeira deslizando + rangido, com a intensidade seguindo a VELOCIDADE da porta
                 (devagar no comeco, mais forte no meio, devagar no fim);
  - 1.88 s  batida suave das folhas no batente.
Tocar com AudioManager.play_sfx("porta") no inicio da abertura. Duracao total ~2.5 s.

Requisitos: Python 3 + numpy + scipy + ffmpeg/ffprobe no PATH.
Uso (na raiz do projeto):
    python tools/audio/gerar_som_porta.py                  # gera/regrava o .ogg
    python tools/audio/gerar_som_porta.py --lufs -19 --seed 7
Se a duracao da porta mudar (DOOR_OPEN_SECONDS), ajuste --door-open.
"""
import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 44100
OUT = "assets/sounds/efeitos/porta_abrindo.ogg"


def noise(rng, n):
    return rng.standard_normal(n)


def lowpass(x, fc, order=2):
    return signal.sosfilt(signal.butter(order, fc, "lowpass", fs=SR, output="sos"), x)


def highpass(x, fc, order=2):
    return signal.sosfilt(signal.butter(order, fc, "highpass", fs=SR, output="sos"), x)


def bandpass(x, lo, hi, order=2):
    return signal.sosfilt(signal.butter(order, [lo, hi], "bandpass", fs=SR, output="sos"), x)


def door_speed(t, start, dur):
    """Velocidade normalizada (0..1) da curva cubica in/out usada pela porta no jogo."""
    u = np.clip((t - start) / dur, 0.0, 1.0)
    v = np.where(u < 0.5, 12.0 * u**2, 12.0 * (1.0 - u) ** 2) / 3.0
    return np.where((t >= start) & (t <= start + dur), v, 0.0)


def click(t, at, freq, tau, amp, rng):
    """Estalo de trava: rajada curta de ruido filtrado + 'tok' grave."""
    x = np.zeros_like(t)
    m = t >= at
    d = t[m] - at
    n = bandpass(noise(rng, d.size), 1400, 4200) * np.exp(-d / (tau * 0.5))
    tok = np.sin(2 * np.pi * freq * d) * np.exp(-d / tau)
    x[m] = amp * (0.7 * n + 0.6 * tok)
    return x


def channel(t, rng, args):
    n = t.size
    sp = door_speed(t, args.move_start, args.door_open)

    # Deslize da madeira: ruido grave que cresce com a velocidade.
    rumble = lowpass(noise(rng, n), 170, 3) * sp**0.9 * 1.0
    hiss = bandpass(noise(rng, n), 2200, 5200) * sp**1.4 * 0.10

    # Rangido: serra com frequencia oscilante (stick-slip) passando por ressonancias de madeira.
    wob = lowpass(noise(rng, n), 7, 2)
    wob = wob / (np.abs(wob).max() + 1e-9)
    freq = 150 + 90 * sp + 35 * wob
    phase = 2 * np.pi * np.cumsum(freq) / SR
    saw = signal.sawtooth(phase)
    slip = 0.55 + 0.45 * np.tanh(2.2 * lowpass(noise(rng, n), 22, 2) / (np.std(lowpass(noise(rng, n), 22, 2)) + 1e-9))
    creak = bandpass(saw, 380, 560) * 1.0 + bandpass(saw, 850, 1250) * 0.7
    creak = creak * slip * (sp**0.8) * 0.9

    body = rumble * 1.6 + hiss + creak * 0.55

    # Trava destravando no inicio.
    latch = click(t, 0.02, 210, 0.045, 0.55, rng) + click(t, 0.115, 160, 0.060, 0.80, rng)

    # Batida suave quando as folhas encostam no fim do curso.
    at = args.move_start + args.door_open - 0.02
    thud = np.zeros(n)
    m = t >= at
    d = t[m] - at
    thud[m] = (np.sin(2 * np.pi * 64 * d) * np.exp(-d / 0.14) * 0.9
               + lowpass(noise(rng, d.size), 260, 2) * np.exp(-d / 0.07) * 0.8)
    return body + latch + thud


def lufs_of(path):
    r = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(path), "-af", "ebur128=peak=true",
                        "-f", "null", "-"], capture_output=True, text=True, errors="replace")
    s = r.stderr.split("Summary:")[-1]
    i = re.search(r"I:\s+(-?[\d.]+)\s+LUFS", s)
    p = re.search(r"Peak:\s+(-?[\d.]+)\s+dBFS", s)
    return (float(i.group(1)) if i else None, float(p.group(1)) if p else None)


def main():
    ap = argparse.ArgumentParser(description="Gera o som de abertura da porta (ArrivalScene).")
    ap.add_argument("--out", default=OUT)
    ap.add_argument("--seed", type=int, default=13)
    ap.add_argument("--lufs", type=float, default=-19.0, help="volume alvo (LUFS integrado). Padrao %(default)s")
    ap.add_argument("--peak", type=float, default=-3.0, help="pico maximo em dBFS. Padrao %(default)s")
    ap.add_argument("--door-open", type=float, default=1.9, help="duracao da abertura da porta (s)")
    ap.add_argument("--move-start", type=float, default=0.05, help="quando a madeira comeca a deslizar (s)")
    ap.add_argument("--quality", type=float, default=4.0, help="qualidade Vorbis. Padrao %(default)s")
    args = ap.parse_args()

    total = args.move_start + args.door_open + 0.55
    t = np.arange(int(total * SR)) / SR
    rng_l, rng_r = np.random.default_rng(args.seed), np.random.default_rng(args.seed + 1000)
    left, right = channel(t, rng_l, args), channel(t, rng_r, args)
    # Leve abertura estereo (duas folhas) mantendo o centro estavel.
    mid, side = (left + right) / 2, (left - right) / 2
    left, right = mid + 0.8 * side, mid - 0.8 * side
    stereo = np.stack([left, right], axis=1)

    # Entrada/saida suaves (sem estalo no corte) e margem de pico.
    fade = np.ones(t.size)
    k = int(0.004 * SR)
    fade[:k] = np.linspace(0, 1, k)
    out_k = int(0.25 * SR)
    fade[-out_k:] = np.linspace(1, 0, out_k) ** 2
    stereo *= fade[:, None]
    stereo /= np.abs(stereo).max() + 1e-9
    stereo *= 0.5

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / "porta.wav"
        wavfile.write(wav, SR, (np.clip(stereo, -1, 1) * 32767).astype(np.int16))
        # Mede e aplica so ganho (com teto de pico), como nas trilhas.
        lufs, _ = lufs_of(wav)
        gain = 0.0 if lufs is None else args.lufs - lufs
        flt = f"volume={gain:.2f}dB,alimiter=limit={10 ** (args.peak / 20):.3f}:attack=2:release=40:level=disabled"
        r = subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(wav), "-af", flt, "-ac", "2", "-ar", str(SR),
                            "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", str(args.quality), "-f", "ogg", str(out)],
                           capture_output=True, text=True, errors="replace")
        if r.returncode != 0:
            sys.exit(f"ERRO no ffmpeg: {r.stderr.strip()}")
    i, p = lufs_of(out)
    print(f"{out}  {out.stat().st_size / 1024:.0f} KB  {total:.2f}s  LUFS={i}  pico={p} dBFS")


if __name__ == "__main__":
    main()
