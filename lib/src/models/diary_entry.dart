class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    required this.localAudioPath,
    required this.wpm,
  });

  final int? id;
  final String userId;
  final String title;
  final String content;
  final DateTime date;
  final String? localAudioPath;
  final int wpm;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch,
      'local_audio_path': localAudioPath,
      'wpm': wpm,
    };
  }

  factory DiaryEntry.fromMap(Map<String, Object?> map) {
    return DiaryEntry(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      localAudioPath: map['local_audio_path'] as String?,
      wpm: (map['wpm'] as int?) ?? 130,
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    String? localAudioPath,
    int? wpm,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      wpm: wpm ?? this.wpm,
    );
  }
}
