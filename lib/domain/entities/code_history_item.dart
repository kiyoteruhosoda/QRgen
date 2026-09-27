/// A code the user scanned or generated, with the last time it was used.
///
/// The value itself is the identity: the same text appears at most once in a
/// history, and using it again only moves it to the top.
class CodeHistoryItem {
  const CodeHistoryItem({
    required this.value,
    required this.usedAt,
  });

  final String value;
  final DateTime usedAt;
}
