import re

with open('ui.py', encoding='utf-8') as f:
    lines = f.readlines()

with open('matches_sidebar.txt', 'w', encoding='utf-8') as f:
    for i, l in enumerate(lines):
        if 'with st.sidebar' in l:
            f.write(f'{i+1}: {l}')
