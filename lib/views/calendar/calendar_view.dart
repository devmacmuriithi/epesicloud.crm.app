import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../controllers/activities_controller.dart';
import '../../models/crm_models.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return _CalendarViewContent();
  }
}

class _CalendarViewContent extends StatefulWidget {
  @override
  State<_CalendarViewContent> createState() => _CalendarViewContentState();
}

class _CalendarViewContentState extends State<_CalendarViewContent> {
  final ActivitiesController _controller = Get.put(ActivitiesController());
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _viewMode = 'month'; // month, week, day

  List<ActivityModel> get _todayEvents {
    final selected = _selectedDay ?? _focusedDay;
    return _controller.activities.where((e) {
      final d = e.startDateTime ?? (e.dueDate != null ? DateTime.tryParse(e.dueDate!) : null);
      if (d == null) return false;
      return d.year == selected.year && d.month == selected.month && d.day == selected.day;
    }).toList();
  }

  bool _hasEventOnDay(DateTime date) {
    return _controller.activities.any((e) {
      final d = e.startDateTime ?? (e.dueDate != null ? DateTime.tryParse(e.dueDate!) : null);
      if (d == null) return false;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: AppColors.primary),
            tooltip: 'Today',
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
          Obx(() => _controller.isLoading.value 
              ? const SizedBox(width: 48, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
              : IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                  onPressed: () => _controller.fetchActivities(),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/new-activity');
          if (result == true) {
            _controller.fetchActivities();
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() => Column(
        children: [
          _buildViewToggle(),
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          const Divider(color: AppColors.divider, height: 1),
          Expanded(child: _buildEventsList()),
        ],
      )),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: ['month', 'week', 'day'].map((mode) {
            final isActive = _viewMode == mode;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _viewMode = mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mode[0].toUpperCase() + mode.substring(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () => setState(() {
              if (_viewMode == 'month') {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
              } else if (_viewMode == 'week') {
                _focusedDay = _focusedDay.subtract(const Duration(days: 7));
              } else {
                _focusedDay = _focusedDay.subtract(const Duration(days: 1));
              }
              _selectedDay = _focusedDay;
            }),
          ),
          Text(
            _viewMode == 'day' 
              ? DateFormat('MMM dd, yyyy').format(_focusedDay)
              : '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () => setState(() {
              if (_viewMode == 'month') {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
              } else if (_viewMode == 'week') {
                _focusedDay = _focusedDay.add(const Duration(days: 7));
              } else {
                _focusedDay = _focusedDay.add(const Duration(days: 1));
              }
              _selectedDay = _focusedDay;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    if (_viewMode == 'day') return const SizedBox.shrink();

    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    if (_viewMode == 'week') {
      final startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday % 7));
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: days.map((d) => Expanded(
                child: Center(child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _selectedDay != null && _isSameDay(date, _selectedDay!);
                final hasEvent = _hasEventOnDay(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = date),
                    child: _buildDayCircle(date.day, isSelected, isToday, hasEvent),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

    // Month view
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: days.map((d) => Expanded(
              child: Center(
                child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) return const SizedBox.shrink();
              final day = index - startingWeekday + 1;
              final date = DateTime(_focusedDay.year, _focusedDay.month, day);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _selectedDay != null && _isSameDay(date, _selectedDay!);
              final hasEvent = _hasEventOnDay(date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: _buildDayCircle(day, isSelected, isToday, hasEvent),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle(int day, bool isSelected, bool isToday, bool hasEvent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected
             ? AppColors.primary
            : isToday
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : isToday
                      ? AppColors.primary
                      : AppColors.textPrimary,
            ),
          ),
          if (hasEvent && !isSelected)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.primary.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final selected = _selectedDay ?? _focusedDay;
    final dateLabel = _isSameDay(selected, DateTime.now())
        ? 'Today – ${_getMonthName(selected.month)} ${selected.day}'
        : '${_getMonthName(selected.month)} ${selected.day}, ${selected.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            dateLabel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        Expanded(
          child: _controller.isLoading.value 
              ? const Center(child: CircularProgressIndicator())
              : _todayEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          const Text('No events for this day', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _todayEvents.length,
                      itemBuilder: (context, index) => _buildEventCard(_todayEvents[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildEventCard(ActivityModel activity) {
    final typeIcon = _controller.getTypeIcon(activity.type);
    final statusColor = _controller.getStatusColor(activity.status);
    final timeStr = activity.startDateTime != null 
        ? DateFormat('hh:mm a').format(activity.startDateTime!) 
        : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity.type.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(timeStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
