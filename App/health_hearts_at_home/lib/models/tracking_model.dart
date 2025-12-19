class ChildTracking {
  final String id;
  final String childId;
  final String date;
  final double? weight;
  final int? feedingAmount;
  final String? feedingType; // breast/bottle
  final double? oxygenSaturation;
  final String? equipment;
  final String? notes;

  ChildTracking({
    required this.id,
    required this.childId,
    required this.date,
    this.weight,
    this.feedingAmount,
    this.feedingType,
    this.oxygenSaturation,
    this.equipment,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'date': date,
    'weight': weight,
    'feedingAmount': feedingAmount,
    'feedingType': feedingType,
    'oxygenSaturation': oxygenSaturation,
    'equipment': equipment,
    'notes': notes,
  };

  factory ChildTracking.fromJson(Map<String, dynamic> json) => ChildTracking(
    id: json['id'],
    childId: json['childId'],
    date: json['date'],
    weight: json['weight']?.toDouble(),
    feedingAmount: json['feedingAmount'],
    feedingType: json['feedingType'],
    oxygenSaturation: json['oxygenSaturation']?.toDouble(),
    equipment: json['equipment'],
    notes: json['notes'],
  );
}
