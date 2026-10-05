#!/bin/bash
# Point this to your Kaldi installation (WSL example shown).
export KALDI_ROOT="${KALDI_ROOT:-/mnt/c/Users/kerkyra/nlp/lab1/kaldi}"
export IRSTLM=$KALDI_ROOT/tools/irstlm
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/src/fstbin:$KALDI_ROOT/src/bin:$KALDI_ROOT/src/lmbin:$IRSTLM/bin:$PATH
export LD_LIBRARY_PATH=$KALDI_ROOT/src/lib:$KALDI_ROOT/tools/openfst/lib:$LD_LIBRARY_PATH
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
export PYTHONUNBUFFERED=1


