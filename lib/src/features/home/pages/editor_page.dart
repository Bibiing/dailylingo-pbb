import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../models/diary_entry.dart';
import '../../../services/diary_repository.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({
    super.key,
    required this.userId,
    required this.repository,
    required this.initialWpm,
    this.initialEntry,
  });

  final String userId;
  final DiaryRepository repository;
  final int initialWpm;
  final DiaryEntry? initialEntry;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isSaving = false;
  String? _recordingPath;
  late int _wpm;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _wpm = entry?.wpm ?? widget.initialWpm;
    if (entry != null) {
      _titleController.text = entry.title;
      _contentController.text = entry.content;
      _recordingPath = entry.localAudioPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_formKey.currentState!.validate()) return;
    final canRecord = await _recorder.hasPermission();
    if (!canRecord) return;

    final path = await widget.repository.createRecordingPath(widget.userId);
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _recordingPath = path;
      _isRecording = true;
    });

    final words = _contentController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final seconds = (words / _wpm * 60).clamp(8, 180).toDouble();
    unawaited(_autoScroll(seconds));
  }

  Future<void> _stopAndSave() async {
    if (!_isRecording) return;
    setState(() => _isSaving = true);
    final stoppedPath = await _recorder.stop();
    final entry = DiaryEntry(
      id: widget.initialEntry?.id,
      userId: widget.userId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: DateTime.now(),
      localAudioPath: stoppedPath ?? _recordingPath,
      wpm: _wpm,
    );
    final savedId = await widget.repository.saveEntry(entry);
    if (mounted) {
      Navigator.of(context).pop(entry.copyWithId(savedId));
    }
  }

  Future<void> _saveWithoutRecording() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final entry = DiaryEntry(
      id: widget.initialEntry?.id,
      userId: widget.userId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: widget.initialEntry?.date ?? DateTime.now(),
      localAudioPath: widget.initialEntry?.localAudioPath,
      wpm: _wpm,
    );
    final savedId = await widget.repository.saveEntry(entry);
    if (mounted) {
      Navigator.of(context).pop(entry.copyWithId(savedId));
    }
  }

  Future<void> _autoScroll(double seconds) async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: (seconds * 1000).toInt()),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEntry == null ? 'Teleprompter session' : 'Edit diary',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                minLines: 8,
                maxLines: 18,
                decoration: const InputDecoration(
                  labelText: 'English diary content',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().length < 10
                    ? 'Tuliskan minimal 10 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target WPM: $_wpm'),
                      Slider(
                        min: 100,
                        max: 200,
                        divisions: 10,
                        value: _wpm.toDouble(),
                        onChanged: _isRecording
                            ? null
                            : (value) => setState(() => _wpm = value.round()),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tulisan akan digulirkan otomatis saat rekaman berjalan. Gunakan tombol Start lalu Stop untuk menyimpan audio dan teks sekaligus.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isRecording ? null : _startRecording,
                icon: const Icon(Icons.fiber_manual_record),
                label: Text(
                  _isRecording
                      ? 'Recording'
                      : (widget.initialEntry == null
                            ? 'Start recording'
                            : 'Record again'),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _isRecording && !_isSaving ? _stopAndSave : null,
                icon: const Icon(Icons.stop),
                label: Text(_isSaving ? 'Saving...' : 'Stop & save'),
              ),
              if (widget.initialEntry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveWithoutRecording,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save text only'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension DiaryEntryCopy on DiaryEntry {
  DiaryEntry copyWithId(int? newId) {
    return DiaryEntry(
      id: newId,
      userId: userId,
      title: title,
      content: content,
      date: date,
      localAudioPath: localAudioPath,
      wpm: wpm,
    );
  }
}
