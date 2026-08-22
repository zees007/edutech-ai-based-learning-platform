import re

with open('ui.py', encoding='utf-8') as f:
    lines = f.readlines()

with open('matches_export.txt', 'w', encoding='utf-8') as f:
    for i, l in enumerate(lines):
        if 'def ' in l or 'Export' in l or 'export' in l or 'download' in l:
            f.write(f'{i+1}: {l}')
