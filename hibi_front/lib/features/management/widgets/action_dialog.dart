/// 관리자 액션 다이얼로그 위젯

import 'package:flutter/material.dart';

import '../models/admin_models.dart';

/// 신고 처리 다이얼로그
class ReportActionDialog extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback onWarn;
  final VoidCallback onSuspend;
  final VoidCallback onBan;

  const ReportActionDialog({
    super.key,
    required this.onDismiss,
    required this.onWarn,
    required this.onSuspend,
    required this.onBan,
  });

  @override
  State<ReportActionDialog> createState() => _ReportActionDialogState();
}

class _ReportActionDialogState extends State<ReportActionDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('신고 처리'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(
            icon: Icons.close,
            label: '기각',
            description: '신고를 기각합니다',
            onTap: () {
              Navigator.pop(context);
              widget.onDismiss();
            },
          ),
          const Divider(),
          _ActionTile(
            icon: Icons.warning_amber,
            label: '경고',
            description: '사용자에게 경고를 발송합니다',
            color: Colors.orange,
            onTap: () {
              Navigator.pop(context);
              widget.onWarn();
            },
          ),
          const Divider(),
          _ActionTile(
            icon: Icons.block,
            label: '정지',
            description: '사용자를 일시 정지합니다',
            color: theme.colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              widget.onSuspend();
            },
          ),
          const Divider(),
          _ActionTile(
            icon: Icons.person_off,
            label: '강제 탈퇴',
            description: '사용자를 영구 퇴출합니다',
            color: theme.colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              widget.onBan();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }
}

/// 정지 기간 선택 다이얼로그
class SuspendDurationDialog extends StatefulWidget {
  final ValueChanged<SuspensionDuration> onSelect;

  const SuspendDurationDialog({
    super.key,
    required this.onSelect,
  });

  @override
  State<SuspendDurationDialog> createState() => _SuspendDurationDialogState();
}

class _SuspendDurationDialogState extends State<SuspendDurationDialog> {
  SuspensionDuration? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정지 기간 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: SuspensionDuration.values.map((duration) {
          return RadioListTile<SuspensionDuration>(
            title: Text(_getDurationLabel(duration)),
            value: duration,
            groupValue: _selected,
            onChanged: (value) {
              setState(() {
                _selected = value;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _selected != null
              ? () {
                  Navigator.pop(context);
                  widget.onSelect(_selected!);
                }
              : null,
          child: const Text('확인'),
        ),
      ],
    );
  }

  String _getDurationLabel(SuspensionDuration duration) {
    switch (duration) {
      case SuspensionDuration.oneDay:
        return '1일';
      case SuspensionDuration.threeDays:
        return '3일';
      case SuspensionDuration.oneWeek:
        return '1주일';
      case SuspensionDuration.oneMonth:
        return '1개월';
      case SuspensionDuration.permanent:
        return '영구';
    }
  }
}

/// 확인 다이얼로그
class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = '확인',
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.description,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: TextStyle(color: effectiveColor),
      ),
      subtitle: Text(description),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
