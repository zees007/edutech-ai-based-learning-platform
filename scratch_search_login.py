import re

with open('ui.py', encoding='utf-8') as f:
    lines = f.readlines()

with open('matches_login.txt', 'w', encoding='utf-8') as f:
    for i, l in enumerate(lines):
        if 'def _db_login' in l or 'def _make_demo_profile' in l or 'user_profile' in l:
            f.write(f'{i+1}: {l}')
