void main() {
  var code = '''
graph TD
  A["Raw Text Corpus"] -->|"Tokenization" B["Tokenized Dataset"]
  B -->|"Sharding & Prefetching" C["Data Loader"]
  C -->|"Batch (B)" D["Transformer Model"]
  J -->|"Adjust LR" D
''';

  // Fix unclosed pipe strings: -->|"Text" Node
  // regex looks for -->|"Text" followed by space and node identifier
  var fixed = code.replaceAllMapped(
    RegExp(r'(-->\|"[^"]+")(\s+[A-Za-z0-9_]+)'),
    (match) => '${match.group(1)}|${match.group(2)}'
  );

  print(fixed);
}
