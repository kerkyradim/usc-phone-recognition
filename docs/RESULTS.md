# Phone error rate (PER) — USC corpus

Scores from a completed run (Kaldi reports these as `%WER` on phone sequences).

| Model | Set | LM | PER |
|-------|-----|----|-----|
| Monophone | dev | unigram / bigram | 45.69% |
| Monophone | test | unigram / bigram | 45.29% |
| Triphone | dev | unigram / bigram | 36.51% |
| Triphone | test | unigram / bigram | 35.26% |

Pipeline: MFCC features → monophone training → triphone training → decode with unigram and bigram phone LMs.
