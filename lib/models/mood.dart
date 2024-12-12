class Mood {
  final String id;
  final String name;
  bool isSelected;

  Mood({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}