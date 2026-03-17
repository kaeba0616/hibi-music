/// AE-02: 예약 게시 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/admin_song_models.dart';
import '../viewmodels/admin_schedule_viewmodel.dart';

class AdminScheduledPublishView extends ConsumerStatefulWidget {
  const AdminScheduledPublishView({super.key});

  @override
  ConsumerState<AdminScheduledPublishView> createState() =>
      _AdminScheduledPublishViewState();
}

class _AdminScheduledPublishViewState
    extends ConsumerState<AdminScheduledPublishView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(schedulePublishViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schedulePublishViewModelProvider);
    final vm = ref.read(schedulePublishViewModelProvider.notifier);
    final theme = Theme.of(context);

    ref.listen(schedulePublishViewModelProvider, (prev, next) {
      if (next.successMessage != null &&
          prev?.successMessage != next.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      }
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 게시'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '예약 등록'),
            Tab(text: '예약 목록'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildScheduleRegisterTab(context, state, vm, theme),
                _buildScheduleListTab(context, state, vm, theme),
              ],
            ),
    );
  }

  Widget _buildScheduleRegisterTab(
    BuildContext context,
    SchedulePublishState state,
    SchedulePublishViewModel vm,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 곡 선택
          Text(
            '곡 선택',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<SongSearchResult>(
            value: state.selectedSong,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '게시할 곡을 선택하세요',
            ),
            items: state.availableSongs.map((song) {
              return DropdownMenuItem(
                value: song,
                child: Text('${song.titleKor} - ${song.artistName}'),
              );
            }).toList(),
            onChanged: (song) {
              if (song != null) vm.selectSong(song);
            },
          ),

          // 선택된 곡 요약
          if (state.selectedSong != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: const Icon(Icons.music_note),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedSong!.titleKor,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${state.selectedSong!.titleJp} - ${state.selectedSong!.artistName}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 날짜 선택
          Text(
            '게시 일시',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          state.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) vm.selectDate(date);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    state.selectedDate != null
                        ? dateFormat.format(state.selectedDate!)
                        : '날짜 선택',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: state.selectedHour,
                        minute: state.selectedMinute,
                      ),
                    );
                    if (time != null) {
                      vm.selectTime(time.hour, time.minute);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    '${state.selectedHour.toString().padLeft(2, '0')}:${state.selectedMinute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),

          if (state.scheduledDateTime != null) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${dateFormat.format(state.scheduledDateTime!)} ${timeFormat.format(state.scheduledDateTime!)} 에 게시 예정',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // 예약 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.canSchedule && !state.isSaving
                  ? vm.schedulePublish
                  : null,
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.schedule_send),
              label: const Text('예약 게시'),
            ),
          ),

          if (!state.canSchedule) ...[
            const SizedBox(height: 8),
            Text(
              '곡과 날짜를 모두 선택해야 예약할 수 있습니다',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleListTab(
    BuildContext context,
    SchedulePublishState state,
    SchedulePublishViewModel vm,
    ThemeData theme,
  ) {
    if (state.scheduledSongs.isEmpty) {
      return const Center(
        child: Text('예약된 곡이 없습니다'),
      );
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.scheduledSongs.length,
      itemBuilder: (context, index) {
        final item = state.scheduledSongs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(item.status, theme),
              child: Icon(
                _getStatusIcon(item.status),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              item.songTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.artistName),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(item.scheduledAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(
                    item.status.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(item.status, theme)
                      .withValues(alpha: 0.1),
                ),
                if (item.status == ScheduleStatus.pending) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.cancel_outlined,
                        color: theme.colorScheme.error),
                    onPressed: () => _showCancelDialog(context, vm, item),
                  ),
                ],
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getStatusColor(ScheduleStatus status, ThemeData theme) {
    switch (status) {
      case ScheduleStatus.pending:
        return Colors.orange;
      case ScheduleStatus.published:
        return Colors.green;
      case ScheduleStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.pending:
        return Icons.schedule;
      case ScheduleStatus.published:
        return Icons.check;
      case ScheduleStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _showCancelDialog(
    BuildContext context,
    SchedulePublishViewModel vm,
    ScheduledSongItem item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: Text('\'${item.songTitle}\' 예약을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('아니요'),
          ),
          FilledButton(
            onPressed: () {
              vm.cancelSchedule(item.id);
              Navigator.of(context).pop();
            },
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
  }
}
