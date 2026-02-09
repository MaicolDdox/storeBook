class AdminImageSelection {
  const AdminImageSelection({required this.name, this.path, this.bytes});

  final String name;
  final String? path;
  final List<int>? bytes;

  bool get hasFilePath => path != null && path!.isNotEmpty;
  bool get hasBytes => bytes != null && bytes!.isNotEmpty;
}
