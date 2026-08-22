import os

with open('session_limits_results.txt', 'w', encoding='utf-8') as out:
    for root, dirs, files in os.walk('.'):
        if '.venv' in root or '.git' in root or '__pycache__' in root:
            continue
        for file in files:
            if file.endswith('.py') or file.endswith('.md'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                for i, line in enumerate(lines):
                    lower = line.lower()
                    if ('session' in lower and ('limit' in lower or 'quota' in lower or 'max' in lower or 'tier' in lower or 'restrict' in lower or 'count' in lower)):
                        out.write(f"{filepath}:{i+1}: {line.strip()}\n")
