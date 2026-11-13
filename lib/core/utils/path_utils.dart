String toPosixPath(String path) => path.replaceAll('\\', '/');

String repositoryBasename(String path) {
  final normalized = toPosixPath(path).replaceFirst(RegExp(r'/+$'), '');
  final segments = normalized.split('/');
  return segments.isEmpty ? normalized : segments.last;
}

String repositoryParent(String relativePath) {
  final normalized = normalizeRepositoryPath(relativePath);
  final index = normalized.lastIndexOf('/');
  return index < 0 ? '' : normalized.substring(0, index);
}

String repositoryName(String relativePath) {
  final normalized = normalizeRepositoryPath(relativePath);
  final index = normalized.lastIndexOf('/');
  return index < 0 ? normalized : normalized.substring(index + 1);
}

String normalizeRepositoryPath(String path) {
  return toPosixPath(path)
      .split('/')
      .where((segment) => segment.isNotEmpty && segment != '.')
      .join('/');
}

String joinRepositoryPath(String directory, String name) {
  final normalizedDirectory = normalizeRepositoryPath(directory);
  final normalizedName = normalizeRepositoryPath(name);
  if (normalizedDirectory.isEmpty) {
    return normalizedName;
  }
  if (normalizedName.isEmpty) {
    return normalizedDirectory;
  }
  return '$normalizedDirectory/$normalizedName';
}

bool isSameOrDescendantPath(String path, String possibleParent) {
  final normalizedPath = normalizeRepositoryPath(path);
  final normalizedParent = normalizeRepositoryPath(possibleParent);
  if (normalizedPath == normalizedParent) {
    return true;
  }
  return normalizedParent.isNotEmpty &&
      normalizedPath.startsWith('$normalizedParent/');
}

String absoluteRepositoryPath(String rootPath, String relativePath) {
  if (relativePath.isEmpty) {
    return rootPath;
  }
  final separator = rootPath.contains('\\') ? '\\' : '/';
  return '$rootPath$separator${relativePath.replaceAll('/', separator)}';
}
