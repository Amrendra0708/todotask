import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/member.dart';
import '../../data/mock/members.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Board'),
        actions: const [],
      ),
      body: Column(
        children: [
          const _SearchBar(),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                final tasks = state.filteredTasks;
                List<Task> by(TaskStatus s) => tasks.where((t) => t.status == s).toList();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final bool wide = constraints.maxWidth >= 900;
                    if (wide) {
                      return Row(
                        children: [
                          Expanded(child: _ColumnSection(title: 'To Do', status: TaskStatus.todo, tasks: by(TaskStatus.todo))),
                          Expanded(child: _ColumnSection(title: 'In Progress', status: TaskStatus.inProgress, tasks: by(TaskStatus.inProgress))),
                          Expanded(child: _ColumnSection(title: 'Done', status: TaskStatus.done, tasks: by(TaskStatus.done))),
                        ],
                      );
                    }
                    // Mobile-first: stack sections vertically with a single vertical scroll
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          _ColumnSection(title: 'To Do', status: TaskStatus.todo, tasks: by(TaskStatus.todo), shrinkWrap: true),
                          _ColumnSection(title: 'In Progress', status: TaskStatus.inProgress, tasks: by(TaskStatus.inProgress), shrinkWrap: true),
                          _ColumnSection(title: 'Done', status: TaskStatus.done, tasks: by(TaskStatus.done), shrinkWrap: true),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: 'filterFab',
              tooltip: 'Filters',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  builder: (_) => const _FiltersSheet(),
                );
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters'),
            ),
            const Spacer(),
            FloatingActionButton.extended(
              heroTag: 'addFab',
              tooltip: 'Add Task',
              onPressed: () async {
                final bloc = context.read<TaskBloc>();
                final Task? newTask = await showDialog<Task>(
                  context: context,
                  builder: (_) => _TaskDialog(),
                );
                if (newTask != null) {
                  bloc.add(CreateOrUpdateTask(newTask));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final children = <Widget>[
          Expanded(
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by title'),
              onChanged: (v) => context.read<TaskBloc>().add(ApplyFilter(query: v)),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String?>(
            hint: const Text('Assignee'),
            value: context.select((TaskBloc b) => b.state.assigneeId),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All')),
              ...kMockMembers.map((m) => DropdownMenuItem<String?>(value: m.id, child: Text(m.name)))
            ],
            onChanged: (val) => context.read<TaskBloc>().add(ApplyFilter(assigneeId: val)),
          ),
          const SizedBox(width: 12),
          DropdownButton<TaskPriority?>(
            hint: const Text('Priority'),
            value: context.select((TaskBloc b) => b.state.priority),
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...TaskPriority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
            ],
            onChanged: (val) => context.read<TaskBloc>().add(ApplyFilter(priority: val)),
          ),
        ];

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              children[0],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [children[2], children[4]],
              ),
            ],
          );
        } else {
          return Row(children: children);
        }
      }),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search by title',
        ),
        onChanged: (v) => context.read<TaskBloc>().add(ApplyFilter(query: v)),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet();

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets + const EdgeInsets.all(16);
    return Padding(
      padding: padding,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by title'),
              onChanged: (v) => context.read<TaskBloc>().add(ApplyFilter(query: v)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: context.select((TaskBloc b) => b.state.assigneeId),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('All Assignees')),
                      ...kMockMembers.map((m) => DropdownMenuItem<String?>(value: m.id, child: Text(m.name))),
                    ],
                    decoration: const InputDecoration(labelText: 'Assignee'),
                    onChanged: (val) => context.read<TaskBloc>().add(ApplyFilter(assigneeId: val)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<TaskPriority?>(
                    value: context.select((TaskBloc b) => b.state.priority),
                    items: [
                      const DropdownMenuItem<TaskPriority?>(value: null, child: Text('All Priorities')),
                      ...TaskPriority.values.map((p) => DropdownMenuItem<TaskPriority?>(value: p, child: Text(p.name))),
                    ],
                    decoration: const InputDecoration(labelText: 'Priority'),
                    onChanged: (val) => context.read<TaskBloc>().add(ApplyFilter(priority: val)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnSection extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final List<Task> tasks;
  final bool shrinkWrap;
  const _ColumnSection({required this.title, required this.status, required this.tasks, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAccept: (taskId) => context.read<TaskBloc>().add(MoveTask(taskId: taskId, newStatus: status)),
      builder: (context, candidateData, rejectedData) {
        final Color statusColor = _statusColor(status);
        final bool isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isHovering ? statusColor.withOpacity(0.4) : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColumnHeader(title: title, color: statusColor, icon: _statusIcon(status), count: tasks.length),
              const SizedBox(height: 8),
              if (shrinkWrap)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return LongPressDraggable<String>(
                      data: task.id,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(width: 280, child: TaskCard(task: task)),
                      ),
                      childWhenDragging: Opacity(opacity: 0.5, child: TaskCard(task: task)),
                      child: TaskCard(
                        task: task,
                        onTap: () async {
                          final updated = await showDialog<Task>(
                            context: context,
                            builder: (_) => _TaskDialog(existing: task),
                          );
                          if (updated != null) {
                            context.read<TaskBloc>().add(CreateOrUpdateTask(updated));
                          }
                        },
                      ),
                    );
                  },
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return LongPressDraggable<String>(
                        data: task.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(width: 280, child: TaskCard(task: task)),
                        ),
                        childWhenDragging: Opacity(opacity: 0.5, child: TaskCard(task: task)),
                        child: TaskCard(
                          task: task,
                          onTap: () async {
                            final updated = await showDialog<Task>(
                              context: context,
                              builder: (_) => _TaskDialog(existing: task),
                            );
                            if (updated != null) {
                              context.read<TaskBloc>().add(CreateOrUpdateTask(updated));
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final int count;
  const _ColumnHeader({required this.title, required this.color, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.12), Colors.transparent], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: LayoutBuilder(builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 260;
        return Row(
          children: [
          Container(width: 6, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: compact ? 11 : 12)),
                ),
              ),
            ),
          ),
        ],
      );
    }),
    );
  }
}

Color _statusColor(TaskStatus s) {
  switch (s) {
    case TaskStatus.todo:
      return const Color(0xFF8E9AAF);
    case TaskStatus.inProgress:
      return const Color(0xFF4C6FFF);
    case TaskStatus.done:
      return const Color(0xFF22C55E);
  }
}

IconData _statusIcon(TaskStatus s) {
  switch (s) {
    case TaskStatus.todo:
      return Icons.inbox_outlined;
    case TaskStatus.inProgress:
      return Icons.sync;
    case TaskStatus.done:
      return Icons.check_circle_outline;
  }
}

class _TaskDialog extends StatefulWidget {
  final Task? existing;
  const _TaskDialog({this.existing});

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  Member? _assignee;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _priority = widget.existing?.priority ?? TaskPriority.medium;
    _status = widget.existing?.status ?? TaskStatus.todo;
    _assignee = kMockMembers.firstWhere(
      (m) => m.id == widget.existing?.assigneeId,
      orElse: () => const Member(id: '', name: ''),
    );
    if (_assignee?.id.isEmpty == true) _assignee = null;
    _deadline = widget.existing?.deadline;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Create Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  items: TaskPriority.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v ?? _priority),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  items: TaskStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Member>(
                  value: _assignee,
                  items: [
                    const DropdownMenuItem<Member>(value: null, child: Text('Unassigned')),
                    ...kMockMembers.map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                  ],
                  onChanged: (v) => setState(() => _assignee = v),
                  decoration: const InputDecoration(labelText: 'Assignee'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_deadline == null ? 'No deadline' : 'Deadline: ${_deadline!.toLocal()}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 5),
                          initialDate: _deadline ?? now,
                        );
                        if (picked != null) setState(() => _deadline = picked);
                      },
                      child: const Text('Pick date'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            final task = widget.existing == null
                ? Task(
                    id: '',
                    title: _title.text.trim(),
                    priority: _priority,
                    status: _status,
                    assigneeId: _assignee?.id,
                    deadline: _deadline,
                  )
                : widget.existing!.copyWith(
                    title: _title.text.trim(),
                    priority: _priority,
                    status: _status,
                    assigneeId: _assignee?.id,
                    deadline: _deadline,
                  );
            Navigator.pop(context, task);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}

