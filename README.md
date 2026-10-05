# USC phone recognition (Kaldi)

**NTUA MSc — Speech & Language Processing (Lab 1)**  
GMM-HMM **phone recognition** on the USC lecture-hall corpus using [Kaldi](https://github.com/kaldi-asr/kaldi).

## What this repo contains

- `preprocess.py` — builds Kaldi `data/{train,dev,test}` (`utt2spk`, `wav.scp`, `text`) from transcriptions and a CMU-style lexicon
- `4_1.sh` … `4_4.sh` — recipe steps (environment, language preparation, MFCCs, mono/tri training & decoding)
- Prepared phone lexicon, LMs, and language directories under `data/`
- [`docs/RESULTS.md`](docs/RESULTS.md) — dev/test PER for monophone and triphone models

**Not included (too large for Git):** WAV files and trained `exp/` / `mfcc/` artifacts. Re-run the scripts after installing Kaldi and downloading the corpus.

## Dataset

Download **`usc.tgz`** (course Google Drive link) and extract so you have:

```
wav/<speaker>/<utterance_id>.wav   # e.g. wav/m1/m1_001.wav
filesets/
lexicon.txt
transcriptions.txt
```

Official archive layout may differ; adjust paths in `preprocess.py` / `wav.scp` if your extract uses a flat `wav/*.wav` tree.

## Prerequisites

- Kaldi built on **Linux or WSL** 
- Set `KALDI_ROOT` in `path.sh` to your Kaldi clone

## Quick start (inside this directory)

```bash
# 1. Link Kaldi wsj helpers (also done in 4_1.sh)
bash 4_1.sh

# 2. Regenerate data lists if you changed WAV paths
python3 preprocess.py

# 3. Language & features
bash 4_2.sh    # LM + lang
bash 4_3.sh    # MFCC + CMVN

# 4. Train mono/tri and decode
bash 4_4.sh
```


