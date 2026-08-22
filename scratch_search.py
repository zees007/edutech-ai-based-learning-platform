import re

with open('ui.py', encoding='utf-8') as f:
    lines = f.readlines()

with open('matches.txt', 'w', encoding='utf-8') as f:
    for i, l in enumerate(lines):
        if 'YouTubeCuratorAgent' in l or 'curate' in l.lower() or 'youtube' in l.lower() or 'socratic' in l.lower():
            f.write(f'{i+1}: {l}')
