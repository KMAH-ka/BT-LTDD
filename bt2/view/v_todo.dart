import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/todo.dart';
import '../provider/todo_provider.dart';

// ===================== MÀN HÌNH DANH SÁCH TODO =====================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final todos = provider.todos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: todos.isEmpty
          ? const Center(child: Text('Chưa có công việc nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return _TodoCard(todo: todo, provider: provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===================== WIDGET CARD TỪNG TODO =====================
class _TodoCard extends StatelessWidget {
  final Todo todo;
  final TodoProvider provider;

  const _TodoCard({required this.todo, required this.provider});

  @override
  Widget build(BuildContext context) {
    final bool done = todo.isDone == 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng tiêu đề + nút xóa
            Row(
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: done ? Colors.grey : Colors.blue,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteTodo(todo.id!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Hàng trạng thái
            Row(
              children: [
                Checkbox(
                  value: done,
                  onChanged: (_) => provider.toggleDone(todo),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  done ? 'Hoàn thành' : 'Chưa hoàn thành',
                  style: TextStyle(
                    color: done ? Colors.green : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            // Nội dung công việc
            if (todo.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  todo.content,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ===================== MÀN HÌNH THÊM TODO =====================
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công việc')),
      );
      return;
    }

    context.read<TodoProvider>().addTodo(
      Todo(title: title, content: content),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Lưu',
            onPressed: () => _save(context),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: UnderlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}