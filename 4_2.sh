#!/usr/bin/env bash
. ./path.sh
. ./cmd.sh
echo "=== Step 4.2: Preparing Language Model ==="

# clean lm_tmp
rm -rf data/local/lm_tmp/*
mkdir -p data/local/lm_tmp

# silence phones
echo "sil" > data/local/dict/silence_phones.txt
cp data/local/dict/silence_phones.txt data/local/dict/optional_silence.txt

# create nonsilence phones from lexicon
awk '{$1=""; print}' lexicon.txt \
| tr ' ' '\n' \
| grep -v '^sil$' \
| grep -v '^$' \
| sort -u \
> data/local/dict/nonsilence_phones.txt

# create phone lexicon (phone -> phone)
paste -d ' ' data/local/dict/nonsilence_phones.txt \
data/local/dict/nonsilence_phones.txt \
> data/local/dict/lexicon.txt
echo "sil sil" >> data/local/dict/lexicon.txt
awk '{print $1, "1.0", $2}' data/local/dict/lexicon.txt > data/local/dict/lexiconp.txt

# create LM training text
awk '{$1=""; sub(/^ /,""); print "<s> " $0 " </s>"}' data/train/text \
> data/local/dict/lm_train.txt
awk '{$1=""; sub(/^ /,""); print "<s> " $0 " </s>"}' data/dev/text \
> data/local/dict/lm_dev.txt
awk '{$1=""; sub(/^ /,""); print "<s> " $0 " </s>"}' data/test/text \
> data/local/dict/lm_test.txt

# extra questions file (empty)
touch data/local/dict/extra_questions.txt

echo "=== Building language models ==="

# Bigram
build-lm.sh -i data/local/dict/lm_train.txt \
  -n 2 \
  -o data/local/lm_tmp/lm_phone_bg.ilm.gz
compile-lm data/local/lm_tmp/lm_phone_bg.ilm.gz -t=yes /dev/stdout \
  | grep -v unk > data/local/nist_lm/lm_phone_bg.arpa

# Unigram
build-lm.sh -i data/local/dict/lm_train.txt \
  -n 1 \
  -o data/local/lm_tmp/lm_phone_ug.ilm.gz
compile-lm data/local/lm_tmp/lm_phone_ug.ilm.gz -t=yes /dev/stdout \
  | grep -v unk > data/local/nist_lm/lm_phone_ug.arpa

echo "=== Language Models Created ==="
echo "=== Preparing lang directory ==="

utils/validate_dict_dir.pl data/local/dict
utils/prepare_lang.sh data/local/dict sil data/local/lang data/lang

echo "=== Sorting Kaldi data files ==="
for x in train dev test; do
  sort -u data/$x/wav.scp -o data/$x/wav.scp
  sort -u data/$x/text -o data/$x/text
  sort -u data/$x/utt2spk -o data/$x/utt2spk
done

echo "=== Creating spk2utt ==="
for x in train dev test; do
  utils/utt2spk_to_spk2utt.pl data/$x/utt2spk > data/$x/spk2utt
done

echo "=== Creating G.fst ==="
arpa2fst --disambig-symbol=#0 \
  --read-symbol-table=data/lang/words.txt \
  data/local/nist_lm/lm_phone_bg.arpa \
  data/lang/G.fst

echo "=== Step 4.2 completed ==="
