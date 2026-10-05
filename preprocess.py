import os
import re

# Αρχεία εισόδου
LEXICON = 'lexicon.txt'
TRANSCRIPTION = 'transcriptions.txt'
FILESETS = 'filesets'

# 1. Φόρτωση Λεξικού 
lexicon_dict = {}
with open(LEXICON, 'r') as f:
    for line in f:
        parts = line.strip().split()
        if len(parts) > 1:
            lexicon_dict[parts[0].lower()] = " ".join(parts[1:])

# 2. Συνάρτηση μετατροπής σε φωνήματα 
def get_phonemes(text):
    text = text.lower() # lower case 
    text = re.sub(r"[^a-z' ]", "", text) # αφαίρεση ειδικών χαρακτήρων εκτός από ' στο τελος των λέξεων
    words = text.split()
    phonemes = [lexicon_dict.get(w, "") for w in words]
    return "sil " + " ".join(filter(None, phonemes)) + " sil" # προσθήκη sil

# 3. Διάβασμα transcriptions
# Σημείωση: 1η γραμμή = 1η πρόταση κ.ο.κ. 
with open(TRANSCRIPTION, 'r') as f:
    sentences = [line.strip() for line in f]

# 4. Δημιουργία αρχείων για train, dev, test 
sets = {'train': 'training.txt', 'dev': 'validation.txt', 'test': 'testing.txt'}

for folder, fset in sets.items():
    output_dir = f'data/{folder}'
    os.makedirs(output_dir, exist_ok=True)
    
    with open(f'{FILESETS}/{fset}', 'r') as fs:
        u_ids = [line.strip() for line in fs if line.strip()]

    # Ανοίγουμε τα 4 αρχεία-δείκτες που ζητάει η άσκηση 
    with open(f'{output_dir}/uttids', 'w') as f_id, \
         open(f'{output_dir}/utt2spk', 'w') as f_u2s, \
         open(f'{output_dir}/wav.scp', 'w') as f_wav, \
         open(f'{output_dir}/text', 'w') as f_txt:
        
        for u_id in u_ids:
            # speaker_id: m1, m3, f1, f5 [cite: 71]
            spk_id = u_id.split('_')[0]
            # index πρότασης (π.χ. m1_001 -> index 0)
            idx = int(u_id.split('_')[1]) - 1
            
            if idx < len(sentences):
                f_id.write(f"{u_id}\n") 
                f_u2s.write(f"{u_id} {spk_id}\n") 
                f_wav.write(f"{u_id} {os.path.abspath(f'wav/{spk_id}/{u_id}.wav')}\n") # [cite: 72, 73]
                f_txt.write(f"{u_id} {get_phonemes(sentences[idx])}\n") # [cite: 76, 77, 79]

print("Η προετοιμασία ολοκληρώθηκε!")