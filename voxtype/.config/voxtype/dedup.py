#!/usr/bin/env python3
import re, sys

text = sys.stdin.read()

text = re.sub(r'\bneary\b', 'Niri', text, flags=re.IGNORECASE)
text = re.sub(r'\b(\w+)(?:\s+\1){2,}\b', r'\1', text, flags=re.IGNORECASE)
text = re.sub(r'\b(\w+)\s+\1\b', r'\1', text, flags=re.IGNORECASE)

fillers = {"uh", "um", "er", "ah", "eh", "hmm", "hm", "mm", "mhm"}
words = text.split()
words = [w for w in words if w.lower().rstrip(".,;:!?") not in fillers]
text = " ".join(words)

text = re.sub(r'\s+', ' ', text).strip()
text = re.sub(r' ([.,;:!?])', r'\1', text)

print(text)
