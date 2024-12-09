import 'package:task_flow/models/task_list_model.dart';

class GroupModel {
  String id;
  String name;
  List<String> memberEmails;
  List<TaskListModel> lists;

  GroupModel({
    required this.id,
    required this.name,
    required this.memberEmails,
    required this.lists,
  });
}
