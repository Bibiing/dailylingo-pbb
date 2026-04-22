import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../models/diary_entry.dart';
import '../../../services/diary_repository.dart';
import 'editor_page.dart';

class EntryDetailPage extends StatefulWidget {
  const EntryDetailPage({
    super.key,
    required this.entry,
    required this.repository,
  });

  final DiaryEntry entry;
  final DiaryRepository repository;

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  final _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final path = widget.entry.localAudioPath;
    if (path == null || path.isEmpty || !await File(path).exists()) return;

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    await _player.play(DeviceFileSource(path));
    setState(() => _isPlaying = true);
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(
        builder: (_) => EditorPage(
          userId: widget.entry.userId,
          repository: widget.repository,
          initialWpm: widget.entry.wpm,
          initialEntry: widget.entry,
        ),
      ),
    );

    if (updated != null && mounted) {
      Navigator.of(context).pop(updated);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
          'This will remove the diary text and local audio file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.repository.deleteEntry(widget.entry);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry detail'),
        actions: [
          IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(entry.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${entry.wpm} WPM'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(entry.content),
            ),
          ),
          const SizedBox(height: 16),
          if (entry.localAudioPath != null)
            FilledButton.icon(
              onPressed: _togglePlayback,
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(_isPlaying ? 'Pause audio' : 'Play audio'),
            ),
          if (entry.localAudioPath == null)
            const Text('No local audio file saved for this entry.'),
        ],
      ),
    );
  }
}
