class Task {
  final String title;
  final String assignee;
  final String status;
  final String dueDate;
  // final String projectId;

  Task({
    required this.title,
    required this.assignee,
    required this.status,
    required this.dueDate,
    // required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'assignee': assignee,
      'status': status,
      'dueDate': dueDate,
      // 'projectId': projectId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      assignee: map['assignee'] ?? '',
      status: map['status'] ?? '',
      dueDate: map['dueDate'] ?? '',
    );
  }
}
