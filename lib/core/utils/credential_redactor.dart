String redactCredentials(String value) {
  var result = value.replaceAllMapped(
    RegExp(r'(https?://)([^/@\s]+)@'),
    (match) => '${match.group(1)}***@',
  );
  result = result.replaceAllMapped(
    RegExp(r'(Authorization:\s*)([^\r\n]+)', caseSensitive: false),
    (match) => '${match.group(1)}***',
  );
  return result;
}
