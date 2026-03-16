import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faq_models.dart';
import '../viewmodels/faq_viewmodel.dart';
import '../widgets/faq_search_bar.dart';
import '../widgets/faq_category_tabs.dart';
import '../widgets/faq_category_header.dart';
import '../widgets/faq_item_tile.dart';
import '../widgets/faq_empty_view.dart';
import '../widgets/faq_contact_card.dart';

/// FAQ 화면 (FA-01)
class FAQView extends ConsumerWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faqViewModelProvider);
    final viewModel = ref.read(faqViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색창
          FAQSearchBar(
            initialValue: state.searchKeyword,
            onChanged: viewModel.updateSearchKeyword,
            onClear: viewModel.clearSearchKeyword,
          ),

          // 카테고리 탭
          FAQCategoryTabs(
            selectedCategory: state.selectedCategory,
            onCategorySelected: viewModel.selectCategory,
          ),

          const SizedBox(height: 8),

          // 콘텐츠 영역
          Expanded(
            child: _buildContent(context, ref, state, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FAQState state,
    FAQViewModel viewModel,
  ) {
    // 로딩 상태
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 상태
    if (state.hasError) {
      return FAQEmptyView(
        type: FAQEmptyType.error,
        onRetry: viewModel.refresh,
      );
    }

    // FAQ 없음 상태
    if (state.isEmpty) {
      return FAQEmptyView(
        type: FAQEmptyType.noFAQs,
        onContactSupport: () => _handleContactSupport(context),
      );
    }

    // 검색 결과 없음 상태
    final filteredFAQs = state.filteredFAQs;
    if (filteredFAQs.isEmpty) {
      return FAQEmptyView(
        type: FAQEmptyType.noSearchResult,
        searchKeyword: state.searchKeyword,
        onContactSupport: () => _handleContactSupport(context),
      );
    }

    // FAQ 목록
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: _buildFAQList(context, ref, state, viewModel),
    );
  }

  Widget _buildFAQList(
    BuildContext context,
    WidgetRef ref,
    FAQState state,
    FAQViewModel viewModel,
  ) {
    final groupedFAQs = state.filteredGroupedFAQs;
    final categories = groupedFAQs.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: categories.length + 1, // +1 for contact card
      itemBuilder: (context, index) {
        // 문의하기 카드 (마지막)
        if (index == categories.length) {
          return FAQContactCard(
            onContactTap: () => _handleContactSupport(context),
          );
        }

        final category = categories[index];
        final faqs = groupedFAQs[category] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 헤더 (전체 필터가 아닐 때만 표시하지 않음)
            if (state.selectedCategory == FAQCategory.all)
              FAQCategoryHeader(
                category: category,
                count: faqs.length,
              ),

            // FAQ 항목들
            ...faqs.map((faq) => FAQItemTile(
                  faq: faq,
                  isExpanded: viewModel.isFAQExpanded(faq.id),
                  onTap: () => viewModel.toggleFAQExpansion(faq.id),
                )),
          ],
        );
      },
    );
  }

  void _handleContactSupport(BuildContext context) {
    // F10 문의하기 화면으로 이동 (Step 4에서 라우팅 연결)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('문의하기 기능은 준비 중입니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
