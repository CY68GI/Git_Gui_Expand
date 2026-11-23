class GitIdentityPerson {
  const GitIdentityPerson({required this.name, required this.email});

  final String name;
  final String email;

  static GitIdentityPerson? tryParse(String raw) {
    final match = RegExp(r'^(.+) <([^<>\s]+)> \d+ [+-]\d{4}$')
        .firstMatch(raw.trim());
    if (match == null) return null;
    final name = match.group(1)?.trim() ?? '';
    final email = match.group(2)?.trim() ?? '';
    if (name.isEmpty || email.isEmpty) return null;
    return GitIdentityPerson(name: name, email: email);
  }

  @override
  bool operator ==(Object other) {
    return other is GitIdentityPerson &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(name, email);
}

class GitIdentityState {
  const GitIdentityState({
    required this.isReady,
    this.author,
    this.committer,
    this.errorMessage = '',
  });

  const GitIdentityState.unavailable([this.errorMessage = ''])
    : isReady = false,
      author = null,
      committer = null;

  final bool isReady;
  final GitIdentityPerson? author;
  final GitIdentityPerson? committer;
  final String errorMessage;
}
