#!/usr/bin/env python3
"""Source inventory, not a substitute for Lean's transitive axiom audit."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def code_only(text):
    """Blank nested Lean comments and strings, retaining positions and newlines."""
    out = list(text)
    i, depth, string = 0, 0, False
    while i < len(text):
        if depth:
            if text.startswith('/-', i):
                out[i:i+2] = '  '; depth += 1; i += 2; continue
            if text.startswith('-/', i):
                out[i:i+2] = '  '; depth -= 1; i += 2; continue
            if text[i] != '\n': out[i] = ' '
        elif string:
            if text[i] == '\\' and i + 1 < len(text):
                out[i:i+2] = '  '; i += 2; continue
            if text[i] == '"': string = False
            if text[i] != '\n': out[i] = ' '
        elif text.startswith('/-', i):
            out[i:i+2] = '  '; depth = 1; i += 2; continue
        elif text.startswith('--', i):
            end = text.find('\n', i)
            if end < 0: end = len(text)
            out[i:end] = ' ' * (end-i); i = end; continue
        elif text[i] == '"':
            out[i] = ' '; string = True
        i += 1
    if depth or string:
        raise ValueError('Unterminated comment or string')
    return ''.join(out)

def inventory():
    files = sorted([ROOT/'GIFT.lean', *ROOT.glob('GIFT/**/*.lean')])
    result = {'lean_files': len(files), 'axiom_declarations': [], 'native_decide': [], 'holes': []}
    for f in files:
        code = code_only(f.read_text())
        for kind, pattern in [('axiom_declarations', r'\baxiom\s+([^\s:(]+)'),
                              ('native_decide', r'\bnative_decide\b'),
                              ('holes', r'\b(?:sorry|admit|sorryAx)\b')]:
            for m in re.finditer(pattern, code):
                row = {'file': str(f.relative_to(ROOT)), 'line': code[:m.start()].count('\n')+1}
                if kind == 'axiom_declarations': row['name'] = m.group(1)
                result[kind].append(row)
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', type=Path)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    result = inventory()
    if args.write:
        args.write.parent.mkdir(parents=True, exist_ok=True)
        args.write.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: len(v) if isinstance(v, list) else v for k,v in result.items()}, sort_keys=True))
    if args.check and result['holes']:
        raise SystemExit('Unfinished proofs in library sources: '+str(result['holes']))

if __name__ == '__main__': main()
