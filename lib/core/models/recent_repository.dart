class RecentRepository {
  const RecentRepository({required this.path, required this.lastOpened});

  final String path;
  final DateTime lastOpened;

  Map<String, Object> toJson() => {
    'path': path,
    'lastOpened': lastOpened.toIso8601String(),
  };

  factory RecentRepository.fromJson(Map<String, dynamic> json) {
    final path = (json['path'] as String? ?? '').trim();
    final lastOpened = DateTime.tryParse(json['lastOpened'] as String? ?? '');
    if (path.isEmpty || lastOpened == null) {
      throw const FormatException('Invalid recent repository entry');
    }
    return RecentRepository(path: path, lastOpened: lastOpened.toLocal());
  }
}
