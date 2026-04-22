import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/diary_entry.dart';
import '../../../services/diary_repository.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key, required this.user, required this.repository});

  final User user;
  final DiaryRepository repository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: repository.getEntries(user.uid),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <DiaryEntry>[];
        return Scaffold(
          appBar: AppBar(title: const Text('All diary entries')),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.content),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('${entry.wpm}'), const Text('WPM')],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
