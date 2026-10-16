"""Vyrobí zástupné zvuky a hudbu hry (assets/audio/*.wav).

Spuštění: python3 tools/make_sounds.py
Vše je syntetizované, takže nevznikají žádné licenční starosti.
Až budou hotové skutečné nahrávky, stačí soubory se stejnými jmény přepsat.
"""
import os
import wave

import numpy as np

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
rng = np.random.default_rng(42)


def t(sec):
    return np.arange(int(sec * RATE)) / RATE


def env(n, attack=0.005, decay=None):
    """Obálka: krátký náběh a exponenciální dozvuk."""
    e = np.ones(n)
    a = max(1, int(attack * RATE))
    e[:a] = np.linspace(0, 1, a)
    if decay:
        e *= np.exp(-np.arange(n) / RATE / decay)
    fade = min(n, int(0.01 * RATE))
    e[-fade:] *= np.linspace(1, 0, fade)
    return e


def note(freq, sec, decay=0.25, harmonics=(1, 0.5, 0.25)):
    """Zvonivý tón (xylofon/zvonkohra)."""
    x = t(sec)
    s = sum(a * np.sin(2 * np.pi * freq * (i + 1) * x) for i, a in enumerate(harmonics))
    return s * env(len(x), decay=decay)


def pluck(freq, sec, damp=0.996):
    """Karplus-Strong: struna jako ukulele."""
    n = int(sec * RATE)
    period = max(2, int(RATE / freq))
    buf = rng.uniform(-1, 1, period)
    out = np.zeros(n)
    for i in range(n):
        out[i] = buf[i % period]
        buf[i % period] = damp * 0.5 * (buf[i % period] + buf[(i + 1) % period])
    return out * env(n)


def noise(sec, decay=0.1, smooth=1):
    x = rng.uniform(-1, 1, int(sec * RATE))
    if smooth > 1:
        x = np.convolve(x, np.ones(smooth) / smooth, mode="same")
    return x * env(len(x), decay=decay)


def sweep(f0, f1, sec, decay=None, vibrato=0.0, vib_rate=0.0, shape="sine"):
    x = t(sec)
    f = np.linspace(f0, f1, len(x)) * (1 + vibrato * np.sin(2 * np.pi * vib_rate * x))
    phase = 2 * np.pi * np.cumsum(f) / RATE
    s = np.sin(phase)
    if shape == "saw":
        s = sum(np.sin(phase * k) / k for k in range(1, 7))
    return s * env(len(x), decay=decay)


def mix(length_sec, parts):
    out = np.zeros(int(length_sec * RATE))
    for start, sig in parts:
        i = int(start * RATE)
        end = min(len(out), i + len(sig))
        out[i:end] += sig[: end - i]
    return out


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def save(name, sig, peak=0.8):
    sig = sig / (np.max(np.abs(sig)) + 1e-9) * peak
    data = (sig * 32767).astype("<i2").tobytes()
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data)


def song(bpm, bars, chords, scale, melody_seed, instrument, percussion=False, sparkle=False):
    """Smyčka: basa + akordy + melodie po pentatonice; konec plynule navazuje na začátek."""
    beat = 60.0 / bpm
    length = bars * 4 * beat
    total = np.zeros(int(length * RATE) + RATE * 3)
    local = np.random.default_rng(melody_seed)

    def add(start, sig, vol):
        i = int(start * RATE)
        total[i : i + len(sig)] += sig * vol

    idx = 2
    for bar in range(bars):
        root = chords[bar % len(chords)]
        bar_start = bar * 4 * beat
        add(bar_start, pluck(midi(root - 12), 4 * beat, 0.998), 0.5)
        add(bar_start + 2 * beat, pluck(midi(root - 5), 2 * beat, 0.998), 0.35)
        for b in range(4):
            for k, iv in enumerate((0, 4, 7)):
                add(bar_start + b * beat + k * 0.01, pluck(midi(root + 12 + iv), beat, 0.99), 0.12)
        steps = [0, 1, 1.5, 2, 3] if bar % 2 == 0 else [0, 0.5, 1, 2, 2.5, 3]
        for s in steps:
            idx = int(np.clip(idx + local.choice([-2, -1, 1, 2, 0]), 0, len(scale) - 1))
            add(bar_start + s * beat, instrument(midi(scale[idx]), beat * 1.2), 0.35)
        if percussion:
            for b in range(8):
                add(bar_start + b * beat / 2, noise(0.06, 0.02, 2), 0.06 if b % 2 else 0.1)
        if sparkle and bar % 2 == 1:
            for k in range(3):
                add(bar_start + 3 * beat + k * 0.12, note(midi(96 + k * 3), 0.6, 0.3), 0.08)
    n = int(length * RATE)
    loop = total[:n].copy()
    loop[: len(total) - n] += total[n:]
    return loop


def main():
    os.makedirs(OUT, exist_ok=True)
    save("click", sweep(500, 900, 0.07, decay=0.03))
    save("pickup", mix(0.5, [(0, note(midi(88), 0.4, 0.15)), (0.08, note(midi(95), 0.4, 0.2))]))
    save("discover", mix(1.2, [(i * 0.1, note(midi(n), 0.7, 0.3)) for i, n in enumerate([72, 76, 79, 84, 88])]))
    save("treasure", mix(1.8, [(i * 0.13, note(midi(n), 0.9, 0.35, (1, 0.6, 0.4, 0.2))) for i, n in enumerate([67, 72, 76, 79, 84, 79, 84, 91])]))
    save("quest", mix(1.2, [(0, note(midi(72), 0.4)), (0.15, note(midi(76), 0.4)), (0.3, note(midi(79), 0.4)), (0.5, note(midi(84), 0.7, 0.4))]))
    save("eat", mix(0.6, [(i * 0.17, noise(0.1, 0.03, 3)) for i in range(3)]))
    save("water", mix(0.8, [(i * 0.18, sweep(300 + i * 40, 700 + i * 60, 0.12, decay=0.05)) for i in range(4)]))
    save("splash", noise(0.6, 0.15, 4) + 0.3 * sweep(900, 300, 0.6, decay=0.1))
    save("plop", sweep(320, 70, 0.35, decay=0.12))
    save("brush", noise(0.3, 0.12, 8))
    save("rustle", mix(0.5, [(i * 0.07, noise(0.12, 0.04, 5)) for i in range(5)]))
    save("neigh", sweep(950, 520, 0.9, decay=0.6, vibrato=0.08, vib_rate=14, shape="saw"), peak=0.55)
    save("boing", sweep(200, 600, 0.3, decay=0.2, vibrato=0.15, vib_rate=20))
    save("music_stable", song(92, 8, [60, 55, 57, 53], [60, 62, 64, 67, 69, 72, 74, 76], 1, lambda f, s: note(f, s, 0.35)), peak=0.5)
    save("music_walk", song(112, 8, [65, 60, 62, 58], [65, 67, 69, 72, 74, 77, 79, 81], 2, lambda f, s: pluck(f, s, 0.995), percussion=True), peak=0.5)
    save("music_magic", song(76, 8, [57, 53, 60, 55], [69, 72, 74, 76, 79, 81, 84, 86], 3, lambda f, s: note(f, s, 0.6, (1, 0.3, 0.6)), sparkle=True), peak=0.45)


if __name__ == "__main__":
    main()
