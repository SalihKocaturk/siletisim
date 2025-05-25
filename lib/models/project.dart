import 'package:cloud_firestore/cloud_firestore.dart';

import 'task.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String manager;
  final String status;
  final String startDate;
  final String endDate;
  final List<Task> tasks;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.manager,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.tasks,
  });

  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      manager: map['manager'] ?? '',
      status: map['status'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      tasks:
          (map['tasks'] as List<dynamic>? ?? [])
              .map((t) => Task.fromMap(t))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'manager': manager,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
