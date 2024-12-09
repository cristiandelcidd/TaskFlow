class TaskListModel {
  final String id;
  final String name;
  DateTime? createdAt;
  String? createdBy;
  DateTime? updatedAt;
  String? updatedBy;
  String? updatedByEmail;

  TaskListModel({
    required this.id,
    required this.name,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
    this.updatedByEmail,
  });
}
