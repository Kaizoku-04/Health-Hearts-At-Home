class SpiritualItem {
  final int id;
  final int index;
  final String audioUrl;

  SpiritualItem({
    required this.id,
    required this.index,
    required this.audioUrl,
  });

  factory SpiritualItem.fromJson(Map<String, dynamic> json) {
    return SpiritualItem(
      id: json['id'] as int,
      index: json['index'] as int,
      audioUrl: json['audioUrl'] as String,
    );
  }
}
