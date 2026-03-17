/// AE-01: 곡 등록 폼 (Enhanced Song Registration)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_song_models.dart';
import '../viewmodels/admin_song_viewmodel.dart';

class AdminSongRegisterView extends ConsumerStatefulWidget {
  const AdminSongRegisterView({super.key});

  @override
  ConsumerState<AdminSongRegisterView> createState() =>
      _AdminSongRegisterViewState();
}

class _AdminSongRegisterViewState extends ConsumerState<AdminSongRegisterView>
    with SingleTickerProviderStateMixin {
  late TabController _lyricsTabController;
  final _artistSearchController = TextEditingController();
  final _songSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lyricsTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _lyricsTabController.dispose();
    _artistSearchController.dispose();
    _songSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(songRegisterViewModelProvider);
    final vm = ref.read(songRegisterViewModelProvider.notifier);
    final theme = Theme.of(context);

    ref.listen(songRegisterViewModelProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
        Navigator.of(context).pop();
      }
      if (next.errorMessage != null &&
          (prev?.errorMessage != next.errorMessage)) {
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
        title: const Text('곡 등록'),
      ),
      body: state.isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === 제목 섹션 ===
                  _buildSectionHeader(theme, '제목', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '한국어 제목 *',
                      hintText: '밤을 달리다',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: vm.updateTitleKor,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '영어 제목',
                      hintText: 'Racing into the Night',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: vm.updateTitleEng,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '일본어 제목 *',
                      hintText: '夜に駆ける',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: vm.updateTitleJp,
                  ),

                  const SizedBox(height: 24),

                  // === 아티스트 섹션 ===
                  _buildSectionHeader(theme, '아티스트', isRequired: true),
                  const SizedBox(height: 8),
                  if (state.selectedArtist != null)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(state.selectedArtist!.displayName),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            vm.clearArtist();
                            _artistSearchController.clear();
                          },
                        ),
                      ),
                    )
                  else
                    Autocomplete<ArtistSuggestion>(
                      optionsBuilder: (textEditingValue) async {
                        if (textEditingValue.text.isEmpty) return [];
                        await vm.searchArtists(textEditingValue.text);
                        return state.artistSuggestions;
                      },
                      displayStringForOption: (option) => option.displayName,
                      onSelected: (selection) {
                        vm.selectArtist(selection);
                      },
                      fieldViewBuilder: (context, controller, focusNode,
                          onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: '아티스트 검색',
                            hintText: '아티스트 이름을 입력하세요',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // === 스토리 섹션 ===
                  _buildSectionHeader(theme, '추천 스토리'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText:
                          '이 곡을 추천하는 이유를 작성해주세요...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    onChanged: vm.updateStory,
                  ),

                  const SizedBox(height: 24),

                  // === 가사 섹션 ===
                  _buildSectionHeader(theme, '가사'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _lyricsTabController,
                          tabs: const [
                            Tab(text: '일본어'),
                            Tab(text: '한국어'),
                          ],
                        ),
                        SizedBox(
                          height: 250,
                          child: TabBarView(
                            controller: _lyricsTabController,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: '일본어 가사를 입력하세요...',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  onChanged: vm.updateLyricsJp,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: '한국어 가사를 입력하세요...',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  onChanged: vm.updateLyricsKr,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // === YouTube URL 섹션 ===
                  _buildSectionHeader(theme, 'YouTube URL'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'https://www.youtube.com/watch?v=...',
                      prefixIcon: const Icon(Icons.play_circle_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: state.youtubeUrl.isNotEmpty &&
                              state.youtubeUrl.contains('youtube')
                          ? const Icon(Icons.check_circle,
                              color: Colors.green)
                          : null,
                    ),
                    onChanged: vm.updateYoutubeUrl,
                  ),

                  const SizedBox(height: 24),

                  // === 연관곡 섹션 ===
                  _buildSectionHeader(theme, '연관곡'),
                  const SizedBox(height: 8),
                  ...state.relatedSongs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final related = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${related.song.titleKor} - ${related.song.artistName}',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () =>
                                      vm.removeRelatedSong(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              initialValue: related.reason,
                              decoration: const InputDecoration(
                                hintText: '선정 이유 (예: 같은 아티스트의 곡)',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) =>
                                  vm.updateRelatedSongReason(index, value),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: () => _showSongSearchSheet(context, vm),
                    icon: const Icon(Icons.add),
                    label: const Text('연관곡 추가'),
                  ),

                  const SizedBox(height: 32),

                  // === 액션 버튼 ===
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: state.isFormValid ? vm.saveSong : null,
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title,
      {bool isRequired = false}) {
    return Text(
      isRequired ? '$title *' : title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showSongSearchSheet(
      BuildContext context, SongRegisterViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(songRegisterViewModelProvider);
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '연관곡 검색',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _songSearchController,
                      decoration: const InputDecoration(
                        hintText: '곡 제목 또는 아티스트 검색',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: vm.searchSongs,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.songSearchResults.length,
                        itemBuilder: (context, index) {
                          final song = state.songSearchResults[index];
                          final alreadyAdded = state.relatedSongs
                              .any((e) => e.song.id == song.id);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(song.titleKor[0]),
                            ),
                            title: Text(song.titleKor),
                            subtitle: Text(
                                '${song.titleJp} - ${song.artistName}'),
                            trailing: alreadyAdded
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.add),
                            onTap: alreadyAdded
                                ? null
                                : () {
                                    vm.addRelatedSong(song);
                                    Navigator.of(context).pop();
                                    _songSearchController.clear();
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
