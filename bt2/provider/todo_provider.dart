import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    _todos = await DatabaseHelper().getTodos();
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await DatabaseHelper().insertTodo(todo);
    await loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await DatabaseHelper().deleteTodo(id);
    await loadTodos();
  }

  Future<void> toggleDone(Todo todo) async {
    final updated = todo.copyWith(isDone: todo.isDone == 1 ? 0 : 1);
    await DatabaseHelper().updateTodo(updated);
    await loadTodos();
  }
}