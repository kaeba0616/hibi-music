import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/question_models.dart';
import '../viewmodels/question_viewmodel.dart';

/// QU-02: 제출 완료 화면
class QuestionCompleteView extends ConsumerWidget {
  final Question question;

  const QuestionCompleteView({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 완료'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 성공 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 48,
                  color: Colors.green.shade700,
                ),
              ),

              const SizedBox(height: 24),

              // 제목
              Text(
                '문의가 접수되었습니다',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              // 설명
              Text(
                '운영팀에서 확인 후 답변을 드립니다.\n답변은 \'문의 내역\'에서 확인하실 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // 접수 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('접수 번호', question.questionNumber),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      '접수 일시',
                      DateFormat('yyyy.MM.dd HH:mm').format(question.createdAt),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 버튼들
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 폼 초기화
                    ref.read(questionFormProvider.notifier).reset();
                    // 문의 내역으로 이동
                    Navigator.pushReplacementNamed(context, '/question/history');
                  },
                  child: const Text('문의 내역 보기'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () {
                    // 폼 초기화
                    ref.read(questionFormProvider.notifier).reset();
                    // 홈으로 이동
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('홈으로'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
