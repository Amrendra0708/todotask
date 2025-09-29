import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../domain/entities/task.dart';
import '../../data/mock/members.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  const TaskCard({super.key, required this.task, this.onTap});

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 220;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      fit: FlexFit.loose,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(task.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            Icon(Icons.flag, size: compact ? 12 : 13, color: _priorityColor(task.priority)),
                            const SizedBox(width: 4),
                            Text(
                              task.priority.name.toUpperCase(),
                              style: TextStyle(
                                color: _priorityColor(task.priority),
                                fontSize: compact ? 10 : 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    )
                  ],
                );
              }),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (task.assigneeId != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            (kMockMembers.firstWhere((m) => m.id == task.assigneeId, orElse: () => kMockMembers.first).name)[0],
                            style: const TextStyle(fontSize: 11, color: Colors.indigo),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            kMockMembers
                                .firstWhere((m) => m.id == task.assigneeId, orElse: () => kMockMembers.first)
                                .name,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (task.deadline != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM d, yyyy').format(task.deadline!),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                ],
              ),
              if (task.deadline != null || task.assigneeId != null) ...[
                const SizedBox(height: 8),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

