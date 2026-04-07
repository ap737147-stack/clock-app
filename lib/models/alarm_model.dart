// lib/models/alarm_model.dart

enum RepeatType { once, daily, weekdays, weekends, custom }

class AlarmModel {
  final String id;
  final String title;
  final int hour;
  final int minute;
  final bool isPm;
  final RepeatType repeatType;
  final List<int> customDays; // 0=Sun, 1=Mon, ..., 6=Sat
  final DateTime? specificDate;
  final bool isActive;
  final String? voiceFilePath;
  final String? voiceLabel; // e.g. "RISE AND SHINE!"

  const AlarmModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.isPm,
    this.repeatType = RepeatType.once,
    this.customDays = const [],
    this.specificDate,
    this.isActive = true,
    this.voiceFilePath,
    this.voiceLabel,
  });

  AlarmModel copyWith({
    String? id,
    String? title,
    int? hour,
    int? minute,
    bool? isPm,
    RepeatType? repeatType,
    List<int>? customDays,
    DateTime? specificDate,
    bool? isActive,
    String? voiceFilePath,
    String? voiceLabel,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isPm: isPm ?? this.isPm,
      repeatType: repeatType ?? this.repeatType,
      customDays: customDays ?? this.customDays,
      specificDate: specificDate ?? this.specificDate,
      isActive: isActive ?? this.isActive,
      voiceFilePath: voiceFilePath ?? this.voiceFilePath,
      voiceLabel: voiceLabel ?? this.voiceLabel,
    );
  }

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get repeatLabel {
    switch (repeatType) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekdays:
        return 'Weekdays';
      case RepeatType.weekends:
        return 'Weekends';
      case RepeatType.custom:
        final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return customDays.map((d) => days[d]).join(', ');
      case RepeatType.once:
        if (specificDate != null) {
          final d = specificDate!;
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
        }
        return 'Once';
    }
  }

  int get _hour24 => isPm ? (hour % 12) + 12 : hour % 12;

  DateTime? get nextScheduledDate {
    final now = DateTime.now();
    final makeDate = (DateTime date) =>
        DateTime(date.year, date.month, date.day, _hour24, minute);

    bool isMatch(DateTime date) {
      switch (repeatType) {
        case RepeatType.daily:
          return true;
        case RepeatType.weekdays:
          return date.weekday >= DateTime.monday &&
              date.weekday <= DateTime.friday;
        case RepeatType.weekends:
          return date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday;
        case RepeatType.custom:
          return customDays.contains(date.weekday % 7);
        case RepeatType.once:
          return true;
      }
    }

    if (repeatType == RepeatType.once) {
      if (specificDate != null) {
        final scheduled = makeDate(specificDate!);
        return scheduled.isBefore(now) ? null : scheduled;
      }
      final candidate = makeDate(now);
      return candidate.isBefore(now)
          ? candidate.add(const Duration(days: 1))
          : candidate;
    }

    var candidate = makeDate(now);
    if (!isMatch(candidate) || candidate.isBefore(now)) {
      candidate = makeDate(now.add(const Duration(days: 1)));
    }
    while (!isMatch(candidate)) {
      candidate = makeDate(candidate.add(const Duration(days: 1)));
    }
    return candidate;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'hour': hour,
    'minute': minute,
    'isPm': isPm,
    'repeatType': repeatType.index,
    'customDays': customDays,
    'specificDate': specificDate?.toIso8601String(),
    'isActive': isActive,
    'voiceFilePath': voiceFilePath,
    'voiceLabel': voiceLabel,
  };

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
    id: json['id'],
    title: json['title'],
    hour: json['hour'],
    minute: json['minute'],
    isPm: json['isPm'],
    repeatType: RepeatType.values[json['repeatType']],
    customDays: List<int>.from(json['customDays'] ?? []),
    specificDate: json['specificDate'] != null
        ? DateTime.parse(json['specificDate'])
        : null,
    isActive: json['isActive'],
    voiceFilePath: json['voiceFilePath'],
    voiceLabel: json['voiceLabel'],
  );
}
