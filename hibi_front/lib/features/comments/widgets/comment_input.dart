import 'package:flutter/material.dart';
import 'package:hidi/features/comments/models/comment_models.dart';

/// 댓글 입력창 위젯 - CO-02
class CommentInput extends StatefulWidget {
  final Comment? replyTo;
  final bool isLoading;
  final void Function(String content)? onSubmit;
  final VoidCallback? onCancelReply;

  const CommentInput({
    super.key,
    this.replyTo,
    this.isLoading = false,
    this.onSubmit,
    this.onCancelReply,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 대댓글 모드로 전환되면 포커스
    if (widget.replyTo != null && oldWidget.replyTo == null) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSubmit() {
    final content = _controller.text.trim();
    if (content.isEmpty || widget.isLoading) return;

    widget.onSubmit?.call(content);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 대댓글 모드 표시
            if (widget.replyTo != null) _buildReplyIndicator(colorScheme),
            // 입력창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 입력 필드
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: widget.replyTo != null
                            ? '답글을 입력하세요...'
                            : '댓글을 입력하세요...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 전송 버튼
                  _buildSendButton(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '@${widget.replyTo!.author.nickname}님에게 답글',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onCancelReply,
            child: Icon(
              Icons.close,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(ColorScheme colorScheme) {
    final canSubmit = _hasText && !widget.isLoading;

    return GestureDetector(
      onTap: canSubmit ? _handleSubmit : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              canSubmit ? colorScheme.primary : colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: widget.isLoading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(
                Icons.send,
                size: 20,
                color:
                    canSubmit ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}
