class ContentItem {
  final String title;
  final String description;
  final String category; // tutorials, spiritual, etc.
  final String? videoUrl;
  final String? imageUrl;
  final String? externalLink;
  final String language; // en or ar

  ContentItem({
    required this.title,
    required this.description,
    required this.category,
    this.videoUrl,
    this.imageUrl,
    this.externalLink,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'videoUrl': videoUrl,
    'imageUrl': imageUrl,
    'externalLink': externalLink,
    'language': language,
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
    title: json['title'],
    description: json['description'],
    category: json['category'],
    videoUrl: json['videoUrl'],
    imageUrl: json['imageUrl'],
    externalLink: json['externalLink'],
    language: json['language'] ?? 'en',
  );
}
