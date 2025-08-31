import 'package:flutter/material.dart';

// --- PASSO 5 (e Desafio Extra): Criando o modelo de dados ---
// Enum para representar a prioridade da tarefa (parte do desafio)
enum TaskPriority { high, normal, low }

// Classe para representar uma única tarefa (Orientação a Objetos)
class Task {
  final String label;
  bool isDone;
  final TaskPriority priority; // Campo do desafio

  Task({
    required this.label,
    this.isDone = false,
    this.priority = TaskPriority.normal, // Prioridade padrão
  });
}

// --- PASSO 1: Estrutura básica do app ---
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planejador (TO-DO)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Define um tema mais moderno para os botões e inputs
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

// --- PASSO 6 e 7: Transformando a tela principal em interativa ---
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // A "fonte da verdade": a lista de tarefas que gerencia o estado do app
  final List<Task> tasks = [
    Task(label: 'Levar o cachorro para passear', priority: TaskPriority.high),
    Task(label: 'Lavar as roupas', isDone: true),
    Task(label: 'Chegar antes das 19:20', priority: TaskPriority.low),
  ];

  final TextEditingController _controller = TextEditingController();

  // Método para adicionar uma nova tarefa à lista
  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // Não adiciona tarefas vazias

    setState(() {
      tasks.add(Task(label: text));
      _controller.clear(); // Limpa o campo de texto após adicionar
    });
  }

  // Método para marcar/desmarcar uma tarefa
  void _toggleTask(Task task, bool? value) {
    setState(() {
      task.isDone = value ?? false;
    });
  }
  
  // Getter para calcular o progresso dinamicamente
  double get progress {
    if (tasks.isEmpty) return 0.0;
    // Calcula a porcentagem de tarefas concluídas
    return tasks.where((t) => t.isDone).length / tasks.length;
  }
  
  // Método para mostrar as tarefas concluídas em um diálogo
  void _showChecked() {
    final checked = tasks.where((t) => t.isDone).map((t) => '• ${t.label}').toList();
    final content = checked.isEmpty ? 'Nenhuma tarefa marcada.' : checked.join('\n');
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tarefas Concluídas'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Garante que o controller seja descartado para evitar vazamento de memória
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planejador')),
      body: Column(
        children: [
          // A barra de progresso agora recebe o valor dinâmico
          Progress(value: progress),
          const SizedBox(height: 12),
          // Campo de texto e botão para adicionar novas tarefas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Nova tarefa'),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          // A lista de tarefas ocupa o espaço restante
          Expanded(
            child: TaskList(
              tasks: tasks,
              onToggle: _toggleTask,
            ),
          ),
        ],
      ),
      // Botão flutuante para ver as tarefas marcadas
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showChecked,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Ver marcadas'),
      ),
    );
  }
}


// --- PASSO 2 e 7: Widgets de UI ---

// Widget para a barra de progresso (agora dinâmico)
class Progress extends StatelessWidget {
  final double value;
  const Progress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seu progresso de hoje:'),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value.clamp(0.0, 1.0), // Garante que o valor esteja entre 0 e 1
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(value * 100).toStringAsFixed(0)}% concluído'),
          ),
        ],
      ),
    );
  }
}


// Widget para renderizar a lista de tarefas (agora com ListView.builder)
class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task, bool?) onToggle;
  const TaskList({super.key, required this.tasks, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
        return TaskItem(
          task: t,
          onChanged: (value) => onToggle(t, value),
        );
      },
    );
  }
}

// --- PASSO 3 e 6: O item da tarefa (agora stateless e declarativo) ---
class TaskItem extends StatelessWidget {
  final Task task; // Recebe o objeto Task inteiro
  final ValueChanged<bool?> onChanged;

  const TaskItem({
    super.key,
    required this.task,
    required this.onChanged,
  });

  // Função auxiliar para retornar o ícone de prioridade
  Widget? _getPriorityIcon() {
    switch (task.priority) {
      case TaskPriority.high:
        return const Icon(Icons.arrow_upward, color: Colors.red);
      case TaskPriority.low:
        return const Icon(Icons.arrow_downward, color: Colors.green);
      default:
        return null; // Sem ícone para prioridade normal
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: task.isDone, onChanged: onChanged),
      title: Text(
        task.label,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          color: task.isDone ? Colors.grey : null,
        ),
      ),
      trailing: _getPriorityIcon(), // Mostra o ícone de prioridade
      onTap: () => onChanged(!task.isDone), // Permite clicar na linha inteira
    );
  }
}
class MyWidget {}       





