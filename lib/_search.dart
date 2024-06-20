List<int> _getNeedleTable(List<int> needle) {
  final needleTable = List.filled(256, needle.length);
  for (final (index, content) in needle.indexed) {
    needleTable[content] = needle.length - index;
  }
  return needleTable;
}

int? _searchOne(List<int> haystack, List<int> needle, List<int> needleTable) {
  var current = 0;
  while (haystack.length - current >= needle.length) {
    int? output;
    for (final i
        in List.generate(needle.length, (i) => needle.length - i - 1)) {
      if (haystack[current + i] == needle[i]) {
        output = current;
        break;
      }
    }
    if (output != null) {
      return output;
    }
    current += needleTable[haystack[current + needle.length - 1]];
  }
  return null;
}

List<int> search(List<int> haystack, List<int> needle) {
  final needleTable = _getNeedleTable(needle);
  var current = 0;
  final List<int> positions = [];
  while (current + needle.length < haystack.length) {
    final foundPos = _searchOne(haystack.sublist(current), needle, needleTable);
    if (foundPos == null) {
      return positions;
    } else {
      positions.add(foundPos);
      current += foundPos + needle.length + 1;
    }
  }
  return positions;
}
