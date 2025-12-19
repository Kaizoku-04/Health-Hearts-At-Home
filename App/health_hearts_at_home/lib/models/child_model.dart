class Child {
  final String id;
  final String name;
  final String dateOfBirth;
  final String? chdType;
  final String? condition;

  Child({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.chdType,
    this.condition,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dateOfBirth': dateOfBirth,
    'chdType': chdType,
    'condition': condition,
  };

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json['id'],
    name: json['name'],
    dateOfBirth: json['dateOfBirth'],
    chdType: json['chdType'],
    condition: json['condition'],
  );
}
