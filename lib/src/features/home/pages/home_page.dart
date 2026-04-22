import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/diary_entry.dart';
import '../../../services/diary_repository.dart';
import '../../../services/notification_service.dart';
import 'entry_detail_page.dart';
import 'editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.user,
    required this.repository,
    required this.notificationService,
  });

  final User user;
  final DiaryRepository repository;
  final NotificationService notificationService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openEditor() async {
    await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(
        builder: (_) => EditorPage(
          userId: widget.user.uid,
          repository: widget.repository,
          initialWpm: 130,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openEntry(DiaryEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            EntryDetailPage(entry: entry, repository: widget.repository),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: widget.repository.getEntries(widget.user.uid),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <DiaryEntry>[];
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('DailyLingo'),
              actions: [
                IconButton(
                  onPressed: () => widget.notificationService.showReminder(),
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s focus',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FilledButton.icon(
                              onPressed: _openEditor,
                              icon: const Icon(Icons.edit),
                              label: const Text('Write & Record'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Buat catatan, lalu rekam suara sambil mengikuti auto-scroll teleprompter. WPM diatur di dalam sesi teleprompter.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recent entries',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Belum ada diary. Tambahkan entri pertama.',
                          ),
                        ),
                      )
                    else
                      ...entries.map(
                        (entry) => Card(
                          child: ListTile(
                            onTap: () => _openEntry(entry),
                            title: Text(entry.title),
                            subtitle: Text(
                              entry.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text('${entry.wpm} WPM'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
