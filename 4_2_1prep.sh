#!/bin/bash
DICT_DIR=data/local/dict
PROPARASKEYI_LEXICON=data/local/dict/lexicon.txt # Βεβαιώσου ότι αυτό είναι το σωστό path

# 1. Δημιουργία φακέλου
mkdir -p $DICT_DIR

# 2. Silence phones (Προσθήκη <oov> και sil)
echo "sil" > $DICT_DIR/silence_phones.txt
echo "<oov>" >> $DICT_DIR/silence_phones.txt
echo "sil" > $DICT_DIR/optional_silence.txt
sort -u $DICT_DIR/silence_phones.txt -o $DICT_DIR/silence_phones.txt

# 3. Nonsilence phones (Φιλτράρουμε sil και <oov>)
echo "Δημιουργία λίστας φωνημάτων..."
# Εδώ προσθέτουμε το grep -v "<oov>" για να μην μπει στα nonsilence
cut -d' ' -f2- $PROPARASKEYI_LEXICON | tr ' ' '\n' | sort -u | grep -v "sil" | grep -v "<oov>" > $DICT_DIR/nonsilence_phones.txt

# 4. Δημιουργία του 1-1 lexicon.txt
echo "sil sil" > $DICT_DIR/lexicon.txt
echo "<oov> sil" >> $DICT_DIR/lexicon.txt
echo "<unk> sil" >> $DICT_DIR/lexicon.txt # Καλό είναι να υπάρχει και το <unk>
while read p; do
    echo "$p $p" >> $DICT_DIR/lexicon.txt
done < $DICT_DIR/nonsilence_phones.txt

# 5. Δημιουργία lexiconp.txt και Τελική Ταξινόμηση
perl -ape 's/(\S+\s+)(.+)/$1 1.0 $2/;' < $DICT_DIR/lexicon.txt > $DICT_DIR/lexiconp.txt

export LC_ALL=C
sort -u $DICT_DIR/lexicon.txt -o $DICT_DIR/lexicon.txt
sort -u $DICT_DIR/lexiconp.txt -o $DICT_DIR/lexiconp.txt
sort -u $DICT_DIR/nonsilence_phones.txt -o $DICT_DIR/nonsilence_phones.txt

# 6. extra_questions.txt
touch $DICT_DIR/extra_questions.txt

# 7. Δημιουργία lm_train.text
echo "Προσθήκη <s> και </s> στα αρχεία text..."
for set in train dev test; do
    if [ -f data/$set/text ]; then
        awk '{$1=$1" <s>"; print $0" </s>"}' data/$set/text > data/local/dict/lm_${set}.text
    else
        echo "Προειδοποίηση: Το αρχείο data/$set/text δεν βρέθηκε!"
    fi
done

echo "Το βήμα 4.2.1 ολοκληρώθηκε επιτυχώς!"
