class TaskModel {
  String? id;
  String title;
  String description;
  DateTime dueDate;
  String listId;
  List<String> collaborators;
  bool isCompleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;
  String? createdByEmail;
  String? updatedBy;
  String? updatedByEmail;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.listId,
    required this.collaborators,
    this.isCompleted = false,
    this.createdAt,
    this.createdBy,
    this.createdByEmail,
    this.updatedAt,
    this.updatedBy,
    this.updatedByEmail,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      listId: map['listId'],
      collaborators: List<String>.from(map['collaborators']),
      isCompleted: map['isCompleted'],
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      createdBy: map['createdBy'],
      createdByEmail: map['createdByEmail'],
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      updatedBy: map['updatedBy'],
      updatedByEmail: map['updatedByEmail'],
    );
  }
}
