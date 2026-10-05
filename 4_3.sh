#!/usr/bin/env bash
. ./path.sh
. ./cmd.sh

echo "=== Step 4.3: Feature Extraction ==="

mfccdir=mfcc
mkdir -p $mfccdir

for x in train dev test; do
  echo "--- Extracting MFCCs for $x set ---"
  steps/make_mfcc.sh --nj 1 --cmd "$train_cmd" data/$x exp/make_mfcc/$x $mfccdir || exit 1
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir || exit 1
  utils/fix_data_dir.sh data/$x
done

echo "=== Feature extraction completed ==="

echo "--- First 5 sentences frame counts ---"
feat-to-len scp:data/train/feats.scp ark,t:- | head -n 5

echo "--- Feature Dimension ---"
feat-to-dim scp:data/train/feats.scp -
