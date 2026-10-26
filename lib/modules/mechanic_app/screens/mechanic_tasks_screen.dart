import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../data/sample_mechanic_tasks.dart';
import '../models/mechanic_task.dart';

class MechanicTasksScreen extends StatefulWidget {
  const MechanicTasksScreen({super.key});

  @override
  State<MechanicTasksScreen> createState() => _MechanicTasksScreenState();
}

class _MechanicTasksScreenState extends State<MechanicTasksScreen> {
  late DateTime _selectedDay;
  late List<MechanicTask> _tasks;
  _TaskFilter _filter = _TaskFilter.all;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _tasks = sampleMechanicTasksFor(_selectedDay);
  }

  List<MechanicTask> get _visibleTasks {
    final tasks = switch (_filter) {
      _TaskFilter.all => _tasks,
      _TaskFilter.active =>
        _tasks
            .where((task) => task.status == MechanicTaskStatus.inProgress)
            .toList(),
      _TaskFilter.toDo =>
        _tasks
            .where(
              (task) =>
                  task.status == MechanicTaskStatus.received ||
                  task.status == MechanicTaskStatus.waitingForParts,
            )
            .toList(),
      _TaskFilter.completed =>
        _tasks
            .where((task) => task.status == MechanicTaskStatus.ready)
            .toList(),
    };
    return tasks..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> _selectDay() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 1),
      locale: const Locale('pl'),
      helpText: 'Wybierz dzień',
    );
    if (selected == null || !mounted) return;

    setState(() {
      _selectedDay = DateTime(selected.year, selected.month, selected.day);
      _tasks =
          _isToday(_selectedDay) ? sampleMechanicTasksFor(_selectedDay) : [];
      _filter = _TaskFilter.all;
    });
  }

  Future<void> _openTask(MechanicTask task) async {
    final updatedTask = await Navigator.of(context).push<MechanicTask>(
      MaterialPageRoute(builder: (_) => MechanicTaskDetailsScreen(task: task)),
    );
    if (updatedTask == null || !mounted) return;

    setState(() {
      final index = _tasks.indexWhere(
        (item) => item.orderNumber == updatedTask.orderNumber,
      );
      if (index != -1) _tasks[index] = updatedTask;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Zapisano zmiany w zleceniu')));
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        _tasks
            .where((task) => task.status == MechanicTaskStatus.inProgress)
            .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.handyman_outlined, color: AppColors.teal, size: 22),
            SizedBox(width: 9),
            Text(
              'AutoFlow',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 7),
            Text(
              'WARSZTAT',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: const [
          CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFDCEFEB),
            child: Text(
              'MK',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildHeader(activeCount),
                ),
                const SizedBox(height: 20),
                _buildFilters(),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      _visibleTasks.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: _visibleTasks.length,
                            separatorBuilder:
                                (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = _visibleTasks[index];
                              return _TaskCard(
                                task: task,
                                onTap: () => _openTask(task),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int activeCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dzień dobry, Mateusz',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Oto Twój plan pracy',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.assignment_outlined,
                label: 'ZADANIA DZISIAJ',
                value: '${_tasks.length}',
                tint: AppColors.teal,
                background: const Color(0xFFE8F3F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.build_circle_outlined,
                label: 'W TRAKCIE',
                value: '$activeCount',
                tint: const Color(0xFFB97819),
                background: const Color(0xFFFFF3DF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Harmonogram',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _selectDay,
              icon: const Icon(Icons.calendar_month_outlined, size: 17),
              label: Text(_formatDate(_selectedDay)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.teal,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters() {
    const options = [
      (_TaskFilter.all, 'Wszystkie'),
      (_TaskFilter.toDo, 'Do zrobienia'),
      (_TaskFilter.active, 'W trakcie'),
      (_TaskFilter.completed, 'Gotowe'),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = options[index];
          final selected = _filter == filter;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _filter = filter),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: AppColors.teal,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? AppColors.teal : const Color(0xFFE6EAEC),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final message =
        _tasks.isEmpty
            ? 'Brak zadań na wybrany dzień.'
            : 'Brak zadań w tej kategorii.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: 44,
              color: AppColors.teal,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: tint, size: 23),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: tint,
                    fontSize: 21,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tint.withValues(alpha: 0.85),
                    fontSize: 9,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});

  final MechanicTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      _formatTime(task.startTime),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(task.endTime),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3,
                height: 94,
                margin: const EdgeInsets.only(right: 13),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.registrationNumber}  ·  ${task.customerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        _StatusBadge(status: task.status),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            task.stationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MechanicTaskDetailsScreen extends StatefulWidget {
  const MechanicTaskDetailsScreen({required this.task, super.key});

  final MechanicTask task;

  @override
  State<MechanicTaskDetailsScreen> createState() =>
      _MechanicTaskDetailsScreenState();
}

class _MechanicTaskDetailsScreenState extends State<MechanicTaskDetailsScreen> {
  late MechanicTaskStatus _status;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _noteController = TextEditingController(text: widget.task.completionNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      widget.task.copyWith(
        status: _status,
        completionNote: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(
          task.orderNumber,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth < 680 ? null : 680,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Text(
                      'Szczegóły zlecenia',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _VehicleHeading(task: task),
                    const SizedBox(height: 14),
                    _DetailSection(
                      title: 'SZCZEGÓŁY ZLECENIA',
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.tag_rounded,
                            label: 'Numer zlecenia',
                            value: task.orderNumber,
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Klient',
                            value: task.customerName,
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.flag_outlined,
                            label: 'Priorytet',
                            value: task.priority.label,
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.speed_rounded,
                            label: 'Przebieg przy przyjęciu',
                            value: '${task.mileageAtIntake} km',
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.event_outlined,
                            label: 'Termin realizacji',
                            value: _formatDate(task.deadline),
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Zaplanowany czas',
                            value:
                                '${_formatTime(task.startTime)}–${_formatTime(task.endTime)}',
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.home_repair_service_outlined,
                            label: 'Stanowisko',
                            value: task.stationName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailSection(
                      title: 'OPIS USTERKI',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          task.description,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailSection(
                      title: 'STATUS ZLECENIA',
                      child: DropdownButtonFormField<MechanicTaskStatus>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.sync_alt_rounded),
                        ),
                        items:
                            MechanicTaskStatus.values
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.label),
                                  ),
                                )
                                .toList(),
                        onChanged: (status) {
                          if (status != null) setState(() => _status = status);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailSection(
                      title: 'ZDJĘCIA ZLECENIA',
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Dodawanie zdjęć będzie dostępne wkrótce.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: const Text('Dodaj zdjęcia'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.teal,
                            side: const BorderSide(color: AppColors.teal),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailSection(
                      title: 'NOTATKA KOŃCOWA',
                      child: TextField(
                        controller: _noteController,
                        minLines: 4,
                        maxLines: 7,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText:
                              'Opisz wykonane prace, wymienione części lub zalecenia dla klienta…',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Zapisz zmiany'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VehicleHeading extends StatelessWidget {
  const _VehicleHeading({required this.task});

  final MechanicTask task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: AppColors.teal,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.vehicleName,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  task.registrationNumber,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MechanicTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

enum _TaskFilter { all, toDo, active, completed }

Color _statusColor(MechanicTaskStatus status) => switch (status) {
  MechanicTaskStatus.received => const Color(0xFF477AA3),
  MechanicTaskStatus.inProgress => AppColors.teal,
  MechanicTaskStatus.waitingForParts => const Color(0xFFB97819),
  MechanicTaskStatus.ready => const Color(0xFF4A8A57),
};

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _formatDate(DateTime date) {
  const weekdays = ['pon.', 'wt.', 'śr.', 'czw.', 'pt.', 'sob.', 'niedz.'];
  const months = [
    'sty',
    'lut',
    'mar',
    'kwi',
    'maj',
    'cze',
    'lip',
    'sie',
    'wrz',
    'paź',
    'lis',
    'gru',
  ];
  if (_isToday(date)) return 'Dziś, ${date.day} ${months[date.month - 1]}';
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}
