class TutorialsItem {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final String? externalLink;
  final String? language;
  final DateTime? createdAt;

  TutorialsItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.externalLink,
    this.language,
    this.createdAt,
  });

  factory TutorialsItem.fromJson(Map<String, dynamic> json) {
    return TutorialsItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      externalLink: json['externalLink'] as String?,
      language: json['language'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
    );
  }
}
