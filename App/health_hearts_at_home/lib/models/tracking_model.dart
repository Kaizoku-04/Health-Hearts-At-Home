class ChildTracking {
  final String id;
  final String childId;
  final String recordedAt;
  final double? weight;
  final String? note; // instead of notes

  // keep feeding fields if you want, but they won’t be persisted until you add them to backend
  final int? feedingAmount;
  final String? feedingType;
  final double? oxygenSaturation;
  final String? equipment;

  ChildTracking({
    required this.id,
    required this.childId,
    required this.recordedAt,
    this.weight,
    this.note,
    this.feedingAmount,
    this.feedingType,
    this.oxygenSaturation,
    this.equipment,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'recordedAt': recordedAt, // ✅ backend field
    'weight': weight,
    'note': note, // ✅ backend field
    // optional extras; backend ignores them unless you add columns
    'feedingAmount': feedingAmount,
    'feedingType': feedingType,
    'oxygenSaturation': oxygenSaturation,
    'equipment': equipment,
  };

  factory ChildTracking.fromJson(Map<String, dynamic> json) => ChildTracking(
    id: json['id'],
    childId: json['childId'],
    recordedAt: json['recordedAt'], // ✅ from backend SELECT ... AS "recordedAt"
    weight: json['weight']?.toDouble(),
    note: json['note'],
    feedingAmount: json['feedingAmount'],
    feedingType: json['feedingType'],
    oxygenSaturation: json['oxygenSaturation']?.toDouble(),
    equipment: json['equipment'],
  );
}
