#!/bin/bash


source ./path.sh

¹Î½
export LD_LIBRARY_PATH=/mnt/c/Users/kerkyra/nlp/lab1/kaldi/src/lib:/mnt/c/Users/kerkyra/nlp/lab1/kaldi/tools/openfst/lib:$LD_LIBRARY_PATH

utils/prepare_lang.sh data/local/dict "<oov>" data/local/lang data/lang
