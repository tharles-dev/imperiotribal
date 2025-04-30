class UpgradeQueueModel {
  final int? id;
  final int buildingId;
  final int villageId;
  final int targetLevel;
  final int startTime;
  final int endTime;
  final String status;

  UpgradeQueueModel({
    this.id,
    required this.buildingId,
    required this.villageId,
    required this.targetLevel,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'building_id': buildingId,
      'village_id': villageId,
      'target_level': targetLevel,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
  }

  factory UpgradeQueueModel.fromMap(Map<String, dynamic> map) {
    return UpgradeQueueModel(
      id: map['id'],
      buildingId: map['building_id'],
      villageId: map['village_id'],
      targetLevel: map['target_level'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      status: map['status'],
    );
  }

  @override
  String toString() {
    return 'UpgradeQueueModel(id: $id, buildingId: $buildingId, villageId: $villageId, targetLevel: $targetLevel, startTime: $startTime, endTime: $endTime, status: $status)';
  }
}
