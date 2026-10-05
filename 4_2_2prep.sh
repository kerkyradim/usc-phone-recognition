#!bin/bash
source path.sh
 

build-lm.sh -i data/local/dict/lm_train.text -n 2 -o data/local/lm_tmp/lm_phone_bg.ilm.gz 
compile-lm data/local/lm_tmp/lm_phone_bg.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_bg.arpa.gz 


build-lm.sh -i data/local/dict/lm_train.text -n 1 -o data/local/lm_tmp/lm_phone_ug.ilm.gz 
compile-lm data/local/lm_tmp/lm_phone_ug.ilm.gz -t=yes /dev/stdout | grep -v unk | gzip -c > data/local/nist_lm/lm_phone_ug.arpa.gz 
