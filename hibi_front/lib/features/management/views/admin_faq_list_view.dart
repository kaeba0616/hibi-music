/// MG-06: FAQ 목록 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../faq/models/faq_models.dart';
import '../viewmodels/admin_faq_viewmodel.dart';
import '../widgets/action_dialog.dart';
import '../widgets/admin_faq_tile.dart';
import '../widgets/filter_chip_bar.dart';

class AdminFAQListView extends ConsumerStatefulWidget {
  const AdminFAQListView({super.key});

  @override
  ConsumerState<AdminFAQListView> createState() => _AdminFAQListViewState();
}

class _AdminFAQListViewState extends ConsumerState<AdminFAQListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(faqListViewModelProvider.notifier).loadFaqs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqListViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ 관리'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/faqs/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 필터 바
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterChipBar<FAQCategory>(
              items: const [
                FilterChipItem(value: FAQCategory.account, label: '계정'),
                FilterChipItem(value: FAQCategory.service, label: '서비스'),
                FilterChipItem(value: FAQCategory.music, label: '음악'),
                FilterChipItem(value: FAQCategory.community, label: '커뮤니티'),
                FilterChipItem(value: FAQCategory.other, label: '기타'),
              ],
              selectedValue: state.selectedCategory,
              onSelected: (category) {
                ref
                    .read(faqListViewModelProvider.notifier)
                    .filterByCategory(category);
              },
            ),
          ),
          const Divider(height: 1),
          // FAQ 목록
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.errorMessage!),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                ref
                                    .read(faqListViewModelProvider.notifier)
                                    .loadFaqs();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : state.faqs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'FAQ가 없습니다',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () => context.push('/admin/faqs/new'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('FAQ 추가'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(faqListViewModelProvider.notifier)
                                  .loadFaqs();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: state.faqs.length,
                              itemBuilder: (context, index) {
                                final faq = state.faqs[index];
                                return AdminFAQTile(
                                  faq: faq,
                                  onTap: () {
                                    context.push('/admin/faqs/${faq.id}');
                                  },
                                  onDelete: () => _showDeleteDialog(faq.id),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int faqId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: 'FAQ 삭제',
        message: '이 FAQ를 삭제하시겠습니까?',
        confirmLabel: '삭제',
        isDestructive: true,
        onConfirm: () async {
          final success = await ref
              .read(faqListViewModelProvider.notifier)
              .deleteFaq(faqId);
          if (mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('FAQ가 삭제되었습니다')),
            );
          }
        },
      ),
    );
  }
}
