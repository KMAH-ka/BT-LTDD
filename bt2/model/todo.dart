class Todo {
  final int? id;
  final String title;
  final String content;
  final int isDone; // 0 = chưa hoàn thành, 1 = hoàn thành

  Todo({
    this.id,
    required this.title,
    required this.content,
    this.isDone = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isDone': isDone,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isDone: map['isDone'],
    );
  }

  // Tạo bản sao với isDone thay đổi
  Todo copyWith({int? isDone}) {
    return Todo(
      id: id,
      title: title,
      content: content,
      isDone: isDone ?? this.isDone,
    );
  }
}