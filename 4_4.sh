#!/usr/bin/env bash
. ./path.sh
. ./cmd.sh

echo "=== Step 4.4: Acoustic Model Training and Decoding ==="

mkdir -p local
ln -sf $KALDI_ROOT/egs/wsj/s5/steps/score_kaldi.sh local/score.sh
chmod +x local/score.sh

# -----------------------------------------------------------------------
# STEP 1: Train monophone GMM-HMM model
# -----------------------------------------------------------------------
echo "=== Training monophone model ==="
steps/train_mono.sh \
    --cmd "$train_cmd" \
    --nj 1 \
    data/train \
    data/lang \
    exp/mono \
    || { echo "train_mono.sh failed"; exit 1; }

# -----------------------------------------------------------------------
# STEP 2: Build HCLG decoding graphs (unigram and bigram)
# -----------------------------------------------------------------------
echo "=== Building HCLG graph with UNIGRAM LM ==="
utils/mkgraph.sh \
    --mono \
    data/lang \
    exp/mono \
    exp/mono/graph_ug \
    || { echo "mkgraph.sh (unigram) failed"; exit 1; }

echo "=== Building HCLG graph with BIGRAM LM ==="
cp -r data/lang data/lang_bg
arpa2fst \
    --disambig-symbol=#0 \
    --read-symbol-table=data/lang/words.txt \
    data/local/nist_lm/lm_phone_bg.arpa \
    data/lang_bg/G.fst \
    || { echo "arpa2fst (bigram) failed"; exit 1; }

utils/mkgraph.sh \
    --mono \
    data/lang_bg \
    exp/mono \
    exp/mono/graph_bg \
    || { echo "mkgraph.sh (bigram) failed"; exit 1; }

# -----------------------------------------------------------------------
# STEP 3: Decode dev and test sets (monophone)
# -----------------------------------------------------------------------
for lm in ug bg; do
    for x in dev test; do
        echo "=== Decoding $x with monophone + ${lm} LM ==="
        steps/decode.sh \
            --cmd "$decode_cmd" \
            --nj 1 \
            exp/mono/graph_${lm} \
            data/$x \
            exp/mono/decode_${x}_${lm} \
            || { echo "decode.sh failed for $x / $lm"; exit 1; }
    done
done

# -----------------------------------------------------------------------
# STEP 4: Score / report PER (monophone)
# -----------------------------------------------------------------------
echo ""
echo "=== MONOPHONE PER RESULTS ==="
for lm in ug bg; do
    for x in dev test; do
        best_wer_file="exp/mono/decode_${x}_${lm}/scoring_kaldi/best_wer"
        if [ -f "$best_wer_file" ]; then
            echo "[$x / $lm]  $(cat $best_wer_file)"
        else
            best=$(grep -r "PER\|%WER" exp/mono/decode_${x}_${lm}/wer_* 2>/dev/null \
                   | sort -t' ' -k2 -n | head -1)
            echo "[$x / $lm]  $best"
        fi
    done
done

# -----------------------------------------------------------------------
# STEP 5: Align with monophone model, train triphone model
# -----------------------------------------------------------------------
echo ""
echo "=== Aligning train data with monophone model ==="
steps/align_si.sh \
    --cmd "$train_cmd" \
    --nj 1 \
    data/train \
    data/lang \
    exp/mono \
    exp/mono_ali \
    || { echo "align_si.sh failed"; exit 1; }

echo "=== Training triphone model ==="
steps/train_deltas.sh \
    --cmd "$train_cmd" \
    2000 \
    10000 \
    data/train \
    data/lang \
    exp/mono_ali \
    exp/tri \
    || { echo "train_deltas.sh failed"; exit 1; }

# -----------------------------------------------------------------------
# STEP 6: Build HCLG graphs for triphone model
# -----------------------------------------------------------------------
echo "=== Building HCLG graph (triphone, unigram) ==="
utils/mkgraph.sh \
    data/lang \
    exp/tri \
    exp/tri/graph_ug \
    || { echo "mkgraph.sh (tri/ug) failed"; exit 1; }

echo "=== Building HCLG graph (triphone, bigram) ==="
utils/mkgraph.sh \
    data/lang_bg \
    exp/tri \
    exp/tri/graph_bg \
    || { echo "mkgraph.sh (tri/bg) failed"; exit 1; }

# -----------------------------------------------------------------------
# STEP 7: Decode dev and test sets (triphone)
# -----------------------------------------------------------------------
for lm in ug bg; do
    for x in dev test; do
        echo "=== Decoding $x with triphone + ${lm} LM ==="
        steps/decode.sh \
            --cmd "$decode_cmd" \
            --nj 1 \
            exp/tri/graph_${lm} \
            data/$x \
            exp/tri/decode_${x}_${lm} \
            || { echo "decode.sh (tri) failed for $x / $lm"; exit 1; }
    done
done

# -----------------------------------------------------------------------
# STEP 8: Score / report PER (triphone)
# -----------------------------------------------------------------------
echo ""
echo "=== TRIPHONE PER RESULTS ==="
for lm in ug bg; do
    for x in dev test; do
        best_wer_file="exp/tri/decode_${x}_${lm}/scoring_kaldi/best_wer"
        if [ -f "$best_wer_file" ]; then
            echo "[$x / $lm]  $(cat $best_wer_file)"
        else
            best=$(grep -r "PER\|%WER" exp/tri/decode_${x}_${lm}/wer_* 2>/dev/null \
                   | sort -t' ' -k2 -n | head -1)
            echo "[$x / $lm]  $best"
        fi
    done
done

echo ""
echo "=== All done. Check exp/mono and exp/tri for full results. ==="
