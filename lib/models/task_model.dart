class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
