import re

with open('ui.py', encoding='utf-8') as f:
    lines = f.readlines()

with open('matches_user.txt', 'w', encoding='utf-8') as f:
    for i, l in enumerate(lines):
        if 'st.session_state' in l and ('user' in l.lower() or 'role' in l.lower() or 'auth' in l.lower()):
            f.write(f'{i+1}: {l}')
