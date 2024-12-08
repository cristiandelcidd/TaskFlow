class TaskModel {
  String id;
  String title;
  String description;
  DateTime dueDate;
  String listId;
  List<String> collaborators;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.listId,
    required this.collaborators,
    this.isCompleted = false,
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
    );
  }
}
