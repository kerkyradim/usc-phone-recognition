#!/usr/bin/env bash

. ./path.sh
. ./cmd.sh

echo "=== Step 4.1: Preparing Kaldi USC recipe ==="

BASE_DIR=$(pwd)

# create folders
mkdir -p local
mkdir -p conf
mkdir -p data/lang
mkdir -p data/local/dict
mkdir -p data/local/lm_tmp
mkdir -p data/local/nist_lm

# create symlinks to kaldi wsj recipe
ln -sf $KALDI_ROOT/egs/wsj/s5/steps .
ln -sf $KALDI_ROOT/egs/wsj/s5/utils .

# link scoring script
ln -sf $KALDI_ROOT/egs/wsj/s5/steps/score_kaldi.sh local/score_kaldi.sh

# copy mfcc config
cp $KALDI_ROOT/egs/wsj/s5/conf/mfcc.conf conf/

echo "=== Directory structure ready ==="
