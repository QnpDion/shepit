import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Shepit design note: «Тихий ритуал» — глибокий індиго, тепле світло,
// багато простору й лише одна змістовна дія на екрані.
const _night = Color(0xFF101427);
const _nightSurface = Color(0xFF1A1F36);
const _nightRaised = Color(0xFF252B47);
const _paper = Color(0xFFF7F3EE);
const _paperSurface = Color(0xFFFFFCF8);
const _ink = Color(0xFF202336);
const _lavender = Color(0xFFB8B5D7);
const _apricot = Color(0xFFE7A77E);
const _apricotSoft = Color(0xFFF6D2B9);
const _lineDark = Color(0xFF383E5C);

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _notifications.initialize(const InitializationSettings(android: androidInit));
  tz_data.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Europe/Kyiv'));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications();
  runApp(const ShepitApp());
}

class ShepitApp extends StatefulWidget {
  const ShepitApp({super.key});

  @override
  State<ShepitApp> createState() => _ShepitAppState();
}

class _ShepitAppState extends State<ShepitApp> {
  bool _darkMode = true;
  String _languageMode = 'system';

  void _setAppearance(bool isDark) => setState(() => _darkMode = isDark);
  void _setLanguageMode(String mode) => setState(() => _languageMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _languageMode == 'system' ? null : Locale(_languageMode),
      supportedLocales: const [Locale('uk'), Locale('en')],
      localeResolutionCallback: (locale, _) =>
          Locale(locale?.languageCode == 'uk' ? 'uk' : 'en'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomeShell(
        onThemeChanged: _setAppearance,
        onLanguageModeChanged: _setLanguageMode,
      ),
    );
  }
}

ThemeData _darkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _apricot,
        brightness: Brightness.dark,
        surface: _nightSurface,
      ).copyWith(primary: _apricot, secondary: _lavender, onSurface: _paper),
      scaffoldBackgroundColor: _night,
      dividerColor: _lineDark,
      fontFamily: 'serif',
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _nightSurface,
        indicatorColor: Color(0xFF353A59),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _nightSurface,
        modalBackgroundColor: _nightSurface,
      ),
    );

ThemeData _lightTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9D6951),
        brightness: Brightness.light,
        surface: _paperSurface,
      ).copyWith(
        primary: const Color(0xFF9D6951),
        secondary: const Color(0xFF65658B),
        onSurface: _ink,
      ),
      scaffoldBackgroundColor: _paper,
      dividerColor: const Color(0xFFE5DDD5),
      fontFamily: 'serif',
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _paperSurface,
        indicatorColor: Color(0xFFF2D7C5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _paperSurface,
        modalBackgroundColor: _paperSurface,
      ),
    );

// ---------- Мова інтерфейсу та карток ----------

class AppStrings {
  const AppStrings._(this.languageCode);

  final String languageCode;
  bool get isUkrainian => languageCode == 'uk';

  static AppStrings of(BuildContext context) =>
      AppStrings._(Localizations.localeOf(context).languageCode == 'uk' ? 'uk' : 'en');
  static AppStrings forCode(String code) => AppStrings._(code == 'uk' ? 'uk' : 'en');

  String get appName => isUkrainian ? 'Шепіт' : 'Shepit';
  String get today => isUkrainian ? 'Сьогодні' : 'Today';
  String get settings => isUkrainian ? 'Налаштування' : 'Settings';
  String get openArchive => isUkrainian ? 'Відкрити архів' : 'Open archive';
  String get archive => isUkrainian ? 'Архів шепотів' : 'Whisper archive';
  String get favorites => isUkrainian ? 'Обране' : 'Saved';
  String get dailyWhisper => isUkrainian ? 'Шепіт дня' : 'Daily whisper';
  String get openWhisper => isUkrainian ? 'Відкрити шепіт' : 'Open whisper';
  String get openApp => isUkrainian ? 'Відкрити застосунок' : 'Open app';
  String get hiddenWidgetText =>
      isUkrainian ? 'Відкрий свій тихий знак.' : 'Open your quiet sign.';
  String get notificationTitle =>
      isUkrainian ? 'Шепіт дня готовий' : 'Your daily whisper is ready';
  String get notificationBody => isUkrainian
      ? 'Відкрий, щоб побачити свій тихий знак.'
      : 'Open it to see your quiet sign.';
  String get notificationChannel =>
      isUkrainian ? 'Щоденний шепіт' : 'Daily whisper';
  String get notificationDescription => isUkrainian
      ? 'Одне щоденне нагадування від Шепоту'
      : 'One gentle daily reminder from Shepit';
  String get yourSpace => isUkrainian ? 'Твій простір на сьогодні' : 'Your space for today';
  String get yourWhisper => isUkrainian ? 'Твій шепіт на сьогодні' : 'Your whisper for today';
  String get revealSemantics =>
      isUkrainian ? 'Відкрити сьогоднішній шепіт' : 'Open today’s whisper';
  String get whisperNearby => isUkrainian ? 'Твій шепіт уже поруч' : 'Your whisper is close';
  String get closedCardDescription => isUkrainian
      ? 'Відкрий одну думку для цього дня. Вона залишиться з тобою до завтра.'
      : 'Open one thought for today. It will stay with you until tomorrow.';
  String get saveFavorite => isUkrainian ? 'Зберегти в обране' : 'Save to favorites';
  String get removeFavorite => isUkrainian ? 'Прибрати з обраного' : 'Remove from favorites';
  String get previousWhispers => isUkrainian ? 'Попередні шепоти' : 'Previous whispers';
  String get collection => isUkrainian
      ? 'Твоя невелика колекція думок'
      : 'Your small collection of thoughts';
  String favoritesCount(int count) => isUkrainian ? '$count в обраному' : '$count saved';
  String get firstHistoryHint => isUkrainian
      ? 'Після завтрашнього дня тут з’явиться твоя перша картка з історії.'
      : 'After tomorrow, your first previous card will appear here.';
  String get emptyFavorites => isUkrainian
      ? 'В обраному поки порожньо. Збережи картку, до якої хочеш повернутися.'
      : 'Nothing is saved yet. Save a card you want to revisit.';
  String get emptyArchive => isUkrainian
      ? 'Тут зберігатимуться всі відкриті тобою картки дня.'
      : 'Every daily card you open will be kept here.';
  String get settingsIntro => isUkrainian
      ? 'Налаштуй ритм, але залиш простір для випадковості.'
      : 'Set your rhythm, while leaving room for chance.';
  String get myRhythm => isUkrainian ? 'Мій ритм' : 'My rhythm';
  String get myCards => isUkrainian ? 'Мої картки' : 'My cards';
  String get mySpace => isUkrainian ? 'Мій простір' : 'My space';
  String get language => isUkrainian ? 'Мова' : 'Language';
  String get languageDescription => isUkrainian
      ? 'Інтерфейс, картки, нагадування та віджет'
      : 'Interface, cards, reminders and widget';
  String get systemLanguage => isUkrainian ? 'Як у системі' : 'System default';
  String get systemLanguageDescription => isUkrainian
      ? 'Автоматично: українська або англійська'
      : 'Automatic: Ukrainian or English';
  String get ukrainian => 'Українська';
  String get english => 'English';
  String get reminder => isUkrainian ? 'Щоденне нагадування' : 'Daily reminder';
  String get reminderDescription => isUkrainian
      ? 'Одне тихе нагадування на день'
      : 'One gentle reminder each day';
  String get reminderTime => isUkrainian ? 'Час нагадування' : 'Reminder time';
  String get testReminder => isUkrainian ? 'Перевірити нагадування' : 'Test reminder';
  String get testReminderDescription => isUkrainian
      ? 'Надіслати тихе тестове повідомлення зараз'
      : 'Send a gentle test notification now';
  String get randomWhisper => isUkrainian ? 'Випадковий шепіт' : 'Random whisper';
  String get randomDescription => isUkrainian
      ? 'Одна картка з усіх тем — без вибору наперед'
      : 'One card from all themes, with no advance choice';
  String get chosenThemes => isUkrainian ? 'Мої теми' : 'My themes';
  String get chosenThemesDescription => isUkrainian
      ? 'Випадковий вибір лише з тем, які ти позначиш'
      : 'A random card only from themes you select';
  String get allowedThemes => isUkrainian ? 'Дозволені теми' : 'Allowed themes';
  String get noThemes => isUkrainian
      ? 'Поки нічого не вибрано — тоді Шепіт обиратиме з усіх тем.'
      : 'No themes are selected, so Shepit will choose from every theme.';
  String get themesSelected => isUkrainian
      ? 'Наступна картка буде випадково обрана тільки з позначених тем.'
      : 'Your next card will be randomly selected only from marked themes.';
  String get darkTheme => isUkrainian ? 'Темна тема' : 'Dark theme';
  String get darkThemeDescription => isUkrainian
      ? 'Глибокий індиго для тихого вечірнього ритуалу'
      : 'Deep indigo for a quiet evening ritual';
  String get reduceMotion => isUkrainian ? 'Зменшити анімації' : 'Reduce motion';
  String get reduceMotionDescription => isUkrainian
      ? 'Картки з’являються без м’якого розкриття'
      : 'Cards appear without the soft reveal';
  String get textSize => isUkrainian ? 'Розмір тексту' : 'Text size';
  String get regular => isUkrainian ? 'Звичайний' : 'Regular';
  String get large => isUkrainian ? 'Збільшений' : 'Large';
  String get onHomeScreen => isUkrainian ? 'Шепіт на екрані' : 'Whisper on your screen';
  String get widgetTitle => isUkrainian ? 'Віджет «Шепіт дня»' : 'Daily Whisper widget';
  String get widgetDescription => isUkrainian
      ? 'Затисни порожнє місце на головному екрані → Віджети → Шепіт. Він покаже стан сьогоднішньої картки.'
      : 'Press and hold an empty area on the home screen → Widgets → Shepit. It shows today’s card status.';
  String get about => isUkrainian ? 'Про застосунок' : 'About';
  String get versionDescription => isUkrainian
      ? 'Версія 1.2 · Дані карток зберігаються локально на пристрої'
      : 'Version 1.2 · Card data stays locally on your device';
  String theme(String id) => switch (id) {
        'calm' => isUkrainian ? 'Спокій' : 'Calm',
        'focus' => isUkrainian ? 'Фокус' : 'Focus',
        'motion' => isUkrainian ? 'Рух' : 'Motion',
        'care' => isUkrainian ? 'Турбота' : 'Care',
        'courage' => isUkrainian ? 'Сміливість' : 'Courage',
        _ => isUkrainian ? 'Тихий знак' : 'Quiet sign',
      };
}

// ---------- Дані карток ----------

class WhisperCard {
  const WhisperCard({
    required this.id,
    required this.kind,
    required this.themeId,
    required this.title,
    required this.body,
    required this.focus,
    required this.imageAsset,
  });

  final String id;
  final String kind;
  final String themeId;
  final String title;
  final String body;
  final String focus;
  final String imageAsset;

  WhisperCard copyWith({String? kind, String? title, String? body, String? focus}) =>
      WhisperCard(
        id: id,
        kind: kind ?? this.kind,
        themeId: themeId,
        title: title ?? this.title,
        body: body ?? this.body,
        focus: focus ?? this.focus,
        imageAsset: imageAsset,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'themeId': themeId,
        'title': title,
        'body': body,
        'focus': focus,
        'imageAsset': imageAsset,
      };

  factory WhisperCard.fromJson(Map<String, dynamic> json) {
    final body = (json['body'] ?? json['text'] ?? '').toString();
    final themeId = (json['themeId'] ?? 'calm').toString();
    return WhisperCard(
      id: (json['id'] ?? 'legacy-${body.hashCode}').toString(),
      kind: (json['kind'] ?? json['type'] ?? 'Шепіт дня').toString(),
      themeId: themeId,
      title: (json['title'] ?? themeId).toString(),
      body: body,
      focus: (json['focus'] ?? '').toString(),
      imageAsset: (json['imageAsset'] ?? _imageForTheme(themeId)).toString(),
    );
  }
}

class _CardText {
  const _CardText(this.kind, this.title, this.body, this.focus);
  final String kind;
  final String title;
  final String body;
  final String focus;
}

String _imageForTheme(String themeId) => switch (themeId) {
      'focus' => 'assets/images/shepit_focus.png',
      'motion' => 'assets/images/shepit_motion.png',
      'care' => 'assets/images/shepit_care.png',
      'courage' => 'assets/images/shepit_courage.png',
      _ => 'assets/images/shepit_calm_reference.png',
    };

class CardBank {
  static const _cards = <WhisperCard>[
    WhisperCard(id: 'calm-1', kind: 'Передчуття', themeId: 'calm', title: 'Темп, який підходить', body: 'Те, що здається затримкою, може виявитися правильним темпом.', focus: 'Не прискорюй відповідь, яку ще не почув у собі.', imageAsset: 'assets/images/shepit_calm_reference.png'),
    WhisperCard(id: 'calm-2', kind: 'Крилата думка', themeId: 'calm', title: 'Пауза теж рух', body: 'Тиша не завжди означає порожнечу. Іноді вона збирає все важливе.', focus: 'Зроби три повільні вдихи, перш ніж братися за наступну справу.', imageAsset: 'assets/images/shepit_calm_reference.png'),
    WhisperCard(id: 'calm-3', kind: 'Цитата', themeId: 'calm', title: 'Тиша', body: '«Тиша теж відповідь».', focus: 'Сьогодні не заповнюй кожну паузу словами.', imageAsset: 'assets/images/shepit_calm_reference.png'),
    WhisperCard(id: 'focus-1', kind: 'Передчуття', themeId: 'focus', title: 'Одна річ', body: 'Одна невелика завершена справа сьогодні змінить відчуття всього дня.', focus: 'Назви її — і прибери все, що не веде до неї.', imageAsset: 'assets/images/shepit_focus.png'),
    WhisperCard(id: 'focus-2', kind: 'Крилата думка', themeId: 'focus', title: 'Ясність поруч', body: 'Увага змінює звичні речі: вони нарешті починають звучати чітко.', focus: 'Вимкни зайве на десять хвилин.', imageAsset: 'assets/images/shepit_focus.png'),
    WhisperCard(id: 'focus-3', kind: 'Цитата', themeId: 'focus', title: 'Малий крок', body: '«Великі речі робляться низкою малих справ».', focus: 'Обери найменший можливий наступний крок.', imageAsset: 'assets/images/shepit_focus.png'),
    WhisperCard(id: 'motion-1', kind: 'Передчуття', themeId: 'motion', title: 'Легкий зсув', body: 'Сьогодні достатньо змінити напрям лише на кілька градусів.', focus: 'Спробуй інший маршрут, порядок дій або перше слово.', imageAsset: 'assets/images/shepit_motion.png'),
    WhisperCard(id: 'motion-2', kind: 'Крилата думка', themeId: 'motion', title: 'Не чекай ідеального', body: 'Рух починається не тоді, коли зникає сумнів, а коли ти не дозволяєш йому зупинити себе.', focus: 'Зроби один невидимий для інших, але важливий для себе крок.', imageAsset: 'assets/images/shepit_motion.png'),
    WhisperCard(id: 'motion-3', kind: 'Цитата', themeId: 'motion', title: 'Шлях', body: '«Подорож у тисячу лі починається з одного кроку».', focus: 'Почни до того, як з’явиться ідеальна впевненість.', imageAsset: 'assets/images/shepit_motion.png'),
    WhisperCard(id: 'care-1', kind: 'Передчуття', themeId: 'care', title: 'М’яке місце', body: 'Там, де ти обереш турботу замість поспіху, день стане трохи ширшим.', focus: 'Зроби для себе одну маленьку добру річ без пояснень.', imageAsset: 'assets/images/shepit_care.png'),
    WhisperCard(id: 'care-2', kind: 'Крилата думка', themeId: 'care', title: 'Достатньо', body: 'Турбота не мусить бути гучною, щоб бути справжньою.', focus: 'Напиши людині, про яку подумав, одне тепле речення.', imageAsset: 'assets/images/shepit_care.png'),
    WhisperCard(id: 'care-3', kind: 'Цитата', themeId: 'care', title: 'Ніжність', body: '«Будь ніжним із собою. Ти вчишся».', focus: 'Замінюй одну сувору думку на точнішу й добрішу.', imageAsset: 'assets/images/shepit_care.png'),
    WhisperCard(id: 'courage-1', kind: 'Передчуття', themeId: 'courage', title: 'Твоя іскра', body: 'Те, що ти давно відкладаєш, сьогодні може відповісти на чесний перший крок.', focus: 'Назви вголос те, чого насправді хочеш.', imageAsset: 'assets/images/shepit_courage.png'),
    WhisperCard(id: 'courage-2', kind: 'Крилата думка', themeId: 'courage', title: 'Місце для сміливості', body: 'Сміливість часто звучить не як гучне «так», а як спокійне «спробую».', focus: 'Зроби одну дію, яку можеш завершити сьогодні.', imageAsset: 'assets/images/shepit_courage.png'),
    WhisperCard(id: 'courage-3', kind: 'Цитата', themeId: 'courage', title: 'Початок', body: '«Той, хто має навіщо жити, витримає майже будь-яке як».', focus: 'Повернися до свого «навіщо» хоча б на хвилину.', imageAsset: 'assets/images/shepit_courage.png'),
  ];

  static const _english = <String, _CardText>{
    'calm-1': _CardText('Premonition', 'A fitting pace', 'What feels like a delay may turn out to be the right pace.', 'Do not rush an answer you have not heard within yourself yet.'),
    'calm-2': _CardText('Thought', 'A pause is movement too', 'Silence does not always mean emptiness. Sometimes it gathers what matters.', 'Take three slow breaths before the next task.'),
    'calm-3': _CardText('Quote', 'Silence', '“Silence is an answer too.”', 'Do not fill every pause with words today.'),
    'focus-1': _CardText('Premonition', 'One thing', 'One small finished task today will change the feeling of your whole day.', 'Name it, then remove what does not lead to it.'),
    'focus-2': _CardText('Thought', 'Clarity is close', 'Attention changes familiar things: they finally start to sound clear.', 'Turn off the unnecessary for ten minutes.'),
    'focus-3': _CardText('Quote', 'A small step', '“Great things are made from a series of small tasks.”', 'Choose the smallest possible next step.'),
    'motion-1': _CardText('Premonition', 'A gentle shift', 'Today it is enough to change direction by only a few degrees.', 'Try a different route, order of actions, or first word.'),
    'motion-2': _CardText('Thought', 'Do not wait for perfect', 'Movement starts not when doubt disappears, but when you do not let it stop you.', 'Take one small step that matters to you, even if no one else sees it.'),
    'motion-3': _CardText('Quote', 'The path', '“A journey of a thousand li begins with one step.”', 'Begin before perfect confidence arrives.'),
    'care-1': _CardText('Premonition', 'A softer place', 'Where you choose care over hurry, the day becomes a little wider.', 'Do one small kind thing for yourself without explaining it.'),
    'care-2': _CardText('Thought', 'Enough', 'Care does not have to be loud to be real.', 'Write one warm sentence to the person who came to mind.'),
    'care-3': _CardText('Quote', 'Gentleness', '“Be gentle with yourself. You are learning.”', 'Replace one harsh thought with a truer and kinder one.'),
    'courage-1': _CardText('Premonition', 'Your spark', 'What you have long postponed may answer an honest first step today.', 'Say aloud what you truly want.'),
    'courage-2': _CardText('Thought', 'A place for courage', 'Courage often sounds not like a loud “yes”, but a quiet “I will try”.', 'Do one action you can finish today.'),
    'courage-3': _CardText('Quote', 'The beginning', '“One who has a why to live can endure almost any how.”', 'Return to your “why” for at least a minute.'),
  };

  static WhisperCard cardFor({
    required DateTime date,
    required String selectionMode,
    required Set<String> selectedThemes,
  }) {
    var pool = _cards;
    if (selectionMode == 'themes' && selectedThemes.isNotEmpty) {
      final filtered = _cards.where((card) => selectedThemes.contains(card.themeId)).toList();
      if (filtered.isNotEmpty) pool = filtered;
    }
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static WhisperCard localize(WhisperCard card, String languageCode) {
    if (languageCode != 'en') return card;
    final text = _english[card.id];
    return text == null
        ? card
        : card.copyWith(kind: text.kind, title: text.title, body: text.body, focus: text.focus);
  }
}

class HistoryEntry {
  HistoryEntry({required this.date, required this.card, this.favorite = false});
  final String date;
  final WhisperCard card;
  bool favorite;
  Map<String, dynamic> toJson() => {'date': date, 'card': card.toJson(), 'favorite': favorite};
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        date: (json['date'] ?? '').toString(),
        card: WhisperCard.fromJson(Map<String, dynamic>.from(json['card'] as Map? ?? const {})),
        favorite: (json['favorite'] as bool?) ?? false,
      );
}

class ShepitStorage {
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shepit_data.json');
  }

  static Map<String, dynamic> _defaults() => {
        'history': <dynamic>[], 'notificationsEnabled': false, 'notifyHour': 9,
        'notifyMinute': 0, 'selectionMode': 'random', 'selectedThemes': <dynamic>[],
        'darkMode': true, 'reducedMotion': false, 'textScale': 'regular',
        'languageMode': 'system',
      };

  static Future<Map<String, dynamic>> load() async {
    try {
      final file = await _file();
      if (await file.exists()) return Map<String, dynamic>.from(jsonDecode(await file.readAsString()) as Map);
    } catch (_) {}
    return _defaults();
  }

  static Future<void> save(Map<String, dynamic> data) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _humanDate(DateTime date, String languageCode) {
  const uk = ['січня','лютого','березня','квітня','травня','червня','липня','серпня','вересня','жовтня','листопада','грудня'];
  const en = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  return languageCode == 'uk' ? '${date.day} ${uk[date.month - 1]}' : '${en[date.month - 1]} ${date.day}';
}

String _monthYear(String key, String languageCode) {
  final date = DateTime.tryParse(key);
  if (date == null) return key;
  const uk = ['Січень','Лютий','Березень','Квітень','Травень','Червень','Липень','Серпень','Вересень','Жовтень','Листопад','Грудень'];
  const en = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  return '${languageCode == 'uk' ? uk[date.month - 1] : en[date.month - 1]} ${date.year}';
}

// ---------- Нагадування та Android-віджет ----------

class NotificationScheduler {
  static const _baseId = 500;
  static const _daysAhead = 30;
  static Future<void> requestPermission() async => await _notifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  static Future<void> cancelAll() async {
    for (var offset = 0; offset < _daysAhead; offset++) { await _notifications.cancel(_baseId + offset); }
  }
  static Future<void> scheduleUpcoming(int hour, int minute, AppStrings s) async {
    await cancelAll();
    final android = AndroidNotificationDetails('shepit_daily', s.notificationChannel,
        channelDescription: s.notificationDescription, importance: Importance.defaultImportance, priority: Priority.defaultPriority);
    final now = tz.TZDateTime.now(tz.local);
    for (var offset = 1; offset <= _daysAhead; offset++) {
      final target = DateTime.now().add(Duration(days: offset));
      final when = tz.TZDateTime(tz.local, target.year, target.month, target.day, hour, minute);
      if (!when.isBefore(now)) {
        await _notifications.zonedSchedule(_baseId + offset, s.notificationTitle, s.notificationBody, when,
            NotificationDetails(android: android), androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
      }
    }
  }
  static Future<void> showTestNow(AppStrings s) async {
    final android = AndroidNotificationDetails('shepit_daily', s.notificationChannel,
        channelDescription: s.notificationDescription, importance: Importance.defaultImportance, priority: Priority.defaultPriority);
    await _notifications.show(999, s.notificationTitle, s.notificationBody, NotificationDetails(android: android));
  }
}

class WidgetBridge {
  static const _channel = MethodChannel('com.shepit.shepit/widget');
  static Future<void> update({required WhisperCard? card, required bool revealed, required AppStrings strings}) async {
    final localized = card == null ? null : CardBank.localize(card, strings.languageCode);
    final full = localized?.body ?? strings.hiddenWidgetText;
    final preview = full.length > 88 ? '${full.substring(0, 85)}…' : full;
    try {
      await _channel.invokeMethod<void>('updateWidget', {
        'revealed': revealed, 'kind': localized?.kind ?? strings.dailyWhisper,
        'text': revealed ? preview : strings.hiddenWidgetText,
        'hiddenText': strings.hiddenWidgetText, 'action': revealed ? strings.openApp : strings.openWhisper,
        'dailyLabel': strings.dailyWhisper, 'languageCode': strings.languageCode,
      });
    } on MissingPluginException {}
  }
}

// ---------- Оболонка застосунку ----------

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.onThemeChanged, required this.onLanguageModeChanged});
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<String> onLanguageModeChanged;
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;
  bool _loaded = false;
  List<HistoryEntry> _history = [];
  bool _notificationsEnabled = false, _darkMode = true, _reducedMotion = false;
  int _notifyHour = 9, _notifyMinute = 0;
  String _selectionMode = 'random', _textScale = 'regular', _languageMode = 'system';
  Set<String> _selectedThemes = <String>{};
  WhisperCard? _todayCard;
  bool get _revealedToday => _todayCard != null;
  String get _activeLanguage => _languageMode == 'uk' || _languageMode == 'en'
      ? _languageMode : (WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'uk' ? 'uk' : 'en');
  AppStrings get _strings => AppStrings.forCode(_activeLanguage);

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await ShepitStorage.load();
    final history = ((data['history'] as List?) ?? const []).whereType<Map>()
        .map((item) => HistoryEntry.fromJson(Map<String, dynamic>.from(item))).toList();
    final today = _dateKey(DateTime.now());
    HistoryEntry? todayEntry;
    for (final entry in history) { if (entry.date == today) { todayEntry = entry; break; } }
    if (!mounted) return;
    setState(() {
      _history = history; _notificationsEnabled = data['notificationsEnabled'] as bool? ?? false;
      _notifyHour = data['notifyHour'] as int? ?? 9; _notifyMinute = data['notifyMinute'] as int? ?? 0;
      _selectionMode = (data['selectionMode'] ?? 'random').toString();
      _selectedThemes = ((data['selectedThemes'] as List?) ?? const []).map((x) => x.toString()).where(_themeIds.contains).toSet();
      _darkMode = data['darkMode'] as bool? ?? true; _reducedMotion = data['reducedMotion'] as bool? ?? false;
      _textScale = (data['textScale'] ?? 'regular').toString(); _languageMode = (data['languageMode'] ?? 'system').toString();
      _todayCard = todayEntry?.card; _loaded = true;
    });
    widget.onThemeChanged(_darkMode); widget.onLanguageModeChanged(_languageMode);
    if (_notificationsEnabled) await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute, _strings);
    await _updateWidget();
  }

  Future<void> _persist() => ShepitStorage.save({
    'history': _history.map((x) => x.toJson()).toList(), 'notificationsEnabled': _notificationsEnabled,
    'notifyHour': _notifyHour, 'notifyMinute': _notifyMinute, 'selectionMode': _selectionMode,
    'selectedThemes': _selectedThemes.toList(), 'darkMode': _darkMode, 'reducedMotion': _reducedMotion,
    'textScale': _textScale, 'languageMode': _languageMode,
  });
  Future<void> _updateWidget() => WidgetBridge.update(card: _todayCard, revealed: _revealedToday, strings: _strings);
  Future<void> _revealToday() async {
    if (_revealedToday) return;
    final card = CardBank.cardFor(date: DateTime.now(), selectionMode: _selectionMode, selectedThemes: _selectedThemes);
    setState(() { _todayCard = card; _history.insert(0, HistoryEntry(date: _dateKey(DateTime.now()), card: card)); });
    await _persist(); await _updateWidget();
  }
  Future<void> _toggleFavorite(HistoryEntry entry) async { setState(() => entry.favorite = !entry.favorite); await _persist(); }
  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    if (enabled) { await NotificationScheduler.requestPermission(); await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute, _strings); }
    else { await NotificationScheduler.cancelAll(); }
    await _persist();
  }
  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _notifyHour, minute: _notifyMinute));
    if (picked == null) return;
    setState(() { _notifyHour = picked.hour; _notifyMinute = picked.minute; });
    if (_notificationsEnabled) await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute, _strings);
    await _persist();
  }
  Future<void> _setDarkMode(bool value) async { setState(() => _darkMode = value); widget.onThemeChanged(value); await _persist(); }
  Future<void> _setReducedMotion(bool value) async { setState(() => _reducedMotion = value); await _persist(); }
  Future<void> _setTextScale(String value) async { setState(() => _textScale = value); await _persist(); }
  Future<void> _setSelectionMode(String value) async { setState(() => _selectionMode = value); await _persist(); }
  Future<void> _toggleTheme(String id) async { setState(() => _selectedThemes.contains(id) ? _selectedThemes.remove(id) : _selectedThemes.add(id)); await _persist(); }
  Future<void> _setLanguageMode(String value) async {
    setState(() => _languageMode = value); widget.onLanguageModeChanged(value);
    if (_notificationsEnabled) await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute, _strings);
    await _persist(); await _updateWidget();
  }
  Future<void> _showArchive() async => await showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (context) => ArchiveSheet(history: _history, onToggleFavorite: _toggleFavorite));

  @override Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator(color: _apricot)));
    final scale = _textScale == 'large' ? 1.12 : 1.0;
    return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: Scaffold(
      body: IndexedStack(index: _tabIndex, children: [
        _TodayScreen(todayCard: _todayCard, history: _history, reducedMotion: _reducedMotion, onReveal: _revealToday, onToggleFavorite: _todayCard == null ? null : () => _toggleFavorite(_history.first), onOpenArchive: _showArchive),
        _SettingsScreen(notificationsEnabled: _notificationsEnabled, notifyHour: _notifyHour, notifyMinute: _notifyMinute, selectionMode: _selectionMode, selectedThemes: _selectedThemes, darkMode: _darkMode, reducedMotion: _reducedMotion, textScale: _textScale, languageMode: _languageMode, onToggleNotifications: _toggleNotifications, onPickTime: _pickTime, onSetSelectionMode: _setSelectionMode, onToggleTheme: _toggleTheme, onSetDarkMode: _setDarkMode, onSetReducedMotion: _setReducedMotion, onSetTextScale: _setTextScale, onSetLanguageMode: _setLanguageMode),
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex: _tabIndex, onDestinationSelected: (x) => setState(() => _tabIndex = x), destinations: [
        NavigationDestination(icon: const Icon(Icons.auto_awesome_outlined), selectedIcon: const Icon(Icons.auto_awesome), label: AppStrings.of(context).today),
        NavigationDestination(icon: const Icon(Icons.tune_outlined), selectedIcon: const Icon(Icons.tune), label: AppStrings.of(context).settings),
      ]),
    ));
  }
}

const _themeIds = <String>{'calm', 'focus', 'motion', 'care', 'courage'};

// ---------- Екран «Сьогодні» ----------

class _TodayScreen extends StatelessWidget {
  const _TodayScreen({required this.todayCard, required this.history, required this.reducedMotion, required this.onReveal, required this.onToggleFavorite, required this.onOpenArchive});
  final WhisperCard? todayCard; final List<HistoryEntry> history; final bool reducedMotion;
  final Future<void> Function() onReveal; final Future<void> Function()? onToggleFavorite; final Future<void> Function() onOpenArchive;
  @override Widget build(BuildContext context) {
    final s = AppStrings.of(context); final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = todayCard == null ? null : CardBank.localize(todayCard!, s.languageCode);
    final recent = history.where((x) => x.card.id != todayCard?.id).take(3).toList();
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 30), children: [
      Row(children: [
        _BrandMark(isDark: isDark), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.appName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 25, fontWeight: FontWeight.w700)),
          Text(_humanDate(DateTime.now(), s.languageCode), style: TextStyle(color: isDark ? _lavender : const Color(0xFF6E7080), fontFamily: 'sans-serif', fontSize: 13)),
        ])),
        IconButton(tooltip: s.openArchive, onPressed: onOpenArchive, icon: const Icon(Icons.history_rounded)),
      ]),
      const SizedBox(height: 30),
      Text(current == null ? s.yourSpace : s.yourWhisper, style: TextStyle(color: isDark ? _lavender : const Color(0xFF6E7080), fontFamily: 'sans-serif', fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      AnimatedSwitcher(duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 240), switchInCurve: Curves.easeOutCubic,
        child: current == null ? _ClosedWhisperCard(onOpen: onReveal, isDark: isDark) : _OpenWhisperCard(card: current, isFavorite: history.isNotEmpty && history.first.favorite, onFavorite: onToggleFavorite, isDark: isDark)),
      const SizedBox(height: 28), _HistoryPreview(recent: recent, favoriteCount: history.where((x) => x.favorite).length, onOpenArchive: onOpenArchive),
    ]));
  }
}

class _BrandMark extends StatelessWidget { const _BrandMark({required this.isDark}); final bool isDark;
  @override Widget build(BuildContext context) => Container(width: 46, height: 46, decoration: BoxDecoration(color: isDark ? _nightRaised : const Color(0xFFF1E7DF), shape: BoxShape.circle), padding: const EdgeInsets.all(9), child: CustomPaint(painter: _WhisperMarkPainter(isDark: isDark))); }
class _WhisperMarkPainter extends CustomPainter { const _WhisperMarkPainter({required this.isDark}); final bool isDark;
  @override void paint(Canvas canvas, Size size) { final whisper = Paint()..color = isDark ? _lavender : const Color(0xFF65658B)..style = PaintingStyle.stroke..strokeWidth = size.width * .085..strokeCap = StrokeCap.round; final trace = Path()..moveTo(size.width*.09,size.height*.74)..cubicTo(size.width*.29,size.height*.94,size.width*.75,size.height*.86,size.width*.82,size.height*.38)..cubicTo(size.width*.85,size.height*.18,size.width*.67,size.height*.06,size.width*.50,size.height*.10); canvas.drawPath(trace, whisper); final star=Paint()..color=_apricot; final x=size.width*.53,y=size.height*.46,r=size.width*.17; final p=Path()..moveTo(x,y-r)..quadraticBezierTo(x+r*.18,y-r*.18,x+r,y)..quadraticBezierTo(x+r*.18,y+r*.18,x,y+r)..quadraticBezierTo(x-r*.18,y+r*.18,x-r,y)..quadraticBezierTo(x-r*.18,y-r*.18,x,y-r)..close(); canvas.drawPath(p,star); }
  @override bool shouldRepaint(covariant _WhisperMarkPainter old) => old.isDark != isDark; }

class _ClosedWhisperCard extends StatelessWidget { const _ClosedWhisperCard({required this.onOpen, required this.isDark}); final Future<void> Function() onOpen; final bool isDark;
  @override Widget build(BuildContext context) { final s=AppStrings.of(context); return Semantics(button:true,label:s.revealSemantics,child:InkWell(borderRadius:BorderRadius.circular(32),onTap:onOpen,child:Ink(height:410,decoration:BoxDecoration(borderRadius:BorderRadius.circular(32),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:isDark?const[_nightRaised,_night,Color(0xFF26213A)]:const[Color(0xFFFFF8F2),Color(0xFFF0E6E1),Color(0xFFE6D8DA)]),border:Border.all(color:isDark?_lineDark:const Color(0xFFE3D2C8))),child:Stack(children:[Positioned(right:-34,top:-30,child:_SoftOrb(color:_apricot.withOpacity(.18),size:170)),Positioned(left:-56,bottom:-70,child:_SoftOrb(color:_lavender.withOpacity(.14),size:210)),Center(child:Padding(padding:const EdgeInsets.symmetric(horizontal:36),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.auto_awesome_rounded,color:isDark?_apricot:const Color(0xFFB16E50),size:42),const SizedBox(height:24),Text(s.whisperNearby,textAlign:TextAlign.center,style:TextStyle(color:isDark?_paper:_ink,fontSize:28,height:1.08,fontWeight:FontWeight.w700)),const SizedBox(height:13),Text(s.closedCardDescription,textAlign:TextAlign.center,style:TextStyle(color:isDark?_lavender:const Color(0xFF6E7080),fontFamily:'sans-serif',fontSize:14,height:1.45)),const SizedBox(height:28),Container(padding:const EdgeInsets.symmetric(horizontal:18,vertical:12),decoration:BoxDecoration(color:_apricot,borderRadius:BorderRadius.circular(99)),child:Text(s.openWhisper,style:const TextStyle(color:_night,fontFamily:'sans-serif',fontWeight:FontWeight.w700)))]))) ])))); }
}

class _OpenWhisperCard extends StatelessWidget { const _OpenWhisperCard({required this.card,required this.isFavorite,required this.onFavorite,required this.isDark}); final WhisperCard card; final bool isFavorite,isDark; final Future<void> Function()? onFavorite;
  @override Widget build(BuildContext context) { final s=AppStrings.of(context); return Container(key:ValueKey(card.id),height:470,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(32),boxShadow:[BoxShadow(color:(isDark?Colors.black:const Color(0xFF6E5044)).withOpacity(.18),blurRadius:28,offset:const Offset(0,16))]),child:Stack(fit:StackFit.expand,children:[Image.asset(card.imageAsset,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF252B47),_night,Color(0xFF3A2E4C)])))),const DecoratedBox(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xA0101427),Color(0x21101427),Color(0xE9101427)],stops:[0,.46,1]))),Padding(padding:const EdgeInsets.fromLTRB(25,24,25,25),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[_Pill(text:card.kind),const Spacer(),IconButton.filledTonal(tooltip:isFavorite?s.removeFavorite:s.saveFavorite,onPressed:onFavorite,style:IconButton.styleFrom(backgroundColor:const Color(0x33101427),foregroundColor:isFavorite?_apricot:_paper),icon:Icon(isFavorite?Icons.bookmark_rounded:Icons.bookmark_border_rounded))]),const Spacer(),Text(card.title,style:const TextStyle(color:_paper,fontSize:32,fontWeight:FontWeight.w700,height:1.04)),const SizedBox(height:15),Text(card.body,style:const TextStyle(color:_paper,fontSize:17,height:1.42)),const SizedBox(height:20),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0x2BFFFFFF),border:Border.all(color:const Color(0x30FFFFFF)),borderRadius:BorderRadius.circular(18)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.wb_sunny_outlined,size:18,color:_apricotSoft),const SizedBox(width:9),Expanded(child:Text(card.focus,style:const TextStyle(color:_paper,fontFamily:'sans-serif',fontSize:13,height:1.35))) ]))]))])); }
}
class _Pill extends StatelessWidget { const _Pill({required this.text}); final String text; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),decoration:BoxDecoration(color:const Color(0x2BFFFFFF),borderRadius:BorderRadius.circular(99),border:Border.all(color:const Color(0x38FFFFFF))),child:Text(text.toUpperCase(),style:const TextStyle(color:_paper,fontFamily:'sans-serif',fontSize:10,letterSpacing:.9,fontWeight:FontWeight.w700))); }
class _SoftOrb extends StatelessWidget { const _SoftOrb({required this.color,required this.size}); final Color color; final double size; @override Widget build(BuildContext context)=>Container(width:size,height:size,decoration:BoxDecoration(shape:BoxShape.circle,color:color)); }

class _HistoryPreview extends StatelessWidget { const _HistoryPreview({required this.recent,required this.favoriteCount,required this.onOpenArchive}); final List<HistoryEntry> recent; final int favoriteCount; final Future<void> Function() onOpenArchive;
  @override Widget build(BuildContext context) { final s=AppStrings.of(context);final isDark=Theme.of(context).brightness==Brightness.dark;final fg=Theme.of(context).colorScheme.onSurface;return Container(decoration:BoxDecoration(color:isDark?_nightSurface:_paperSurface,borderRadius:BorderRadius.circular(24),border:Border.all(color:isDark?_lineDark:const Color(0xFFE8DED6))),child:ExpansionTile(shape:const Border(),collapsedShape:const Border(),iconColor:_apricot,collapsedIconColor:isDark?_lavender:const Color(0xFF70718A),title:Text(s.previousWhispers,style:TextStyle(color:fg,fontWeight:FontWeight.w700,fontSize:17)),subtitle:Text(favoriteCount==0?s.collection:s.favoritesCount(favoriteCount),style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',fontSize:12)),children:[if(recent.isEmpty)Padding(padding:const EdgeInsets.fromLTRB(18,4,18,18),child:Text(s.firstHistoryHint,style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',height:1.35)))else ...recent.map((entry){final card=CardBank.localize(entry.card,s.languageCode);return ListTile(leading:Icon(entry.favorite?Icons.bookmark_rounded:Icons.auto_awesome_outlined,color:entry.favorite?_apricot:(isDark?_lavender:const Color(0xFF70718A))),title:Text(card.title,style:TextStyle(color:fg,fontWeight:FontWeight.w600)),subtitle:Text('${card.kind} · ${_humanDate(DateTime.parse(entry.date),s.languageCode)}',style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',fontSize:12)));}),Padding(padding:const EdgeInsets.fromLTRB(12,0,12,12),child:TextButton.icon(onPressed:onOpenArchive,icon:const Icon(Icons.arrow_forward_rounded),label:Text(s.openArchive))) ])); }
}

// ---------- Архів ----------
class ArchiveSheet extends StatefulWidget { const ArchiveSheet({super.key,required this.history,required this.onToggleFavorite}); final List<HistoryEntry> history; final Future<void> Function(HistoryEntry) onToggleFavorite; @override State<ArchiveSheet> createState()=>_ArchiveSheetState(); }
class _ArchiveSheetState extends State<ArchiveSheet> { bool _onlyFavorites=false;
  @override Widget build(BuildContext context){final s=AppStrings.of(context);final isDark=Theme.of(context).brightness==Brightness.dark;final fg=Theme.of(context).colorScheme.onSurface;final visible=widget.history.where((x)=>!_onlyFavorites||x.favorite).toList();final groups=<String,List<HistoryEntry>>{};for(final e in visible){groups.putIfAbsent(_monthYear(e.date,s.languageCode),()=>[]).add(e);}return FractionallySizedBox(heightFactor:.9,child:Column(children:[const SizedBox(height:12),Container(width:40,height:4,decoration:BoxDecoration(color:isDark?_lineDark:const Color(0xFFD9CCC3),borderRadius:BorderRadius.circular(99))),Padding(padding:const EdgeInsets.fromLTRB(22,18,14,10),child:Row(children:[Expanded(child:Text(s.archive,style:TextStyle(color:fg,fontSize:25,fontWeight:FontWeight.w700))),FilterChip(selected:_onlyFavorites,showCheckmark:false,avatar:Icon(_onlyFavorites?Icons.bookmark_rounded:Icons.bookmark_border_rounded,size:17),label:Text(s.favorites),onSelected:(v)=>setState(()=>_onlyFavorites=v))])),Expanded(child:visible.isEmpty?Center(child:Padding(padding:const EdgeInsets.all(36),child:Text(_onlyFavorites?s.emptyFavorites:s.emptyArchive,textAlign:TextAlign.center,style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',height:1.45)))):ListView(padding:const EdgeInsets.fromLTRB(16,2,16,32),children:[for(final group in groups.entries)...[Padding(padding:const EdgeInsets.fromLTRB(6,16,6,8),child:Text(group.key.toUpperCase(),style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',fontSize:11,letterSpacing:1.1,fontWeight:FontWeight.w700))),...group.value.map((entry)=>_ArchiveCard(entry:entry,onToggleFavorite:()async{await widget.onToggleFavorite(entry);if(mounted)setState((){});}))]]))])); }
}
class _ArchiveCard extends StatelessWidget { const _ArchiveCard({required this.entry,required this.onToggleFavorite});final HistoryEntry entry;final Future<void> Function() onToggleFavorite;@override Widget build(BuildContext context){final s=AppStrings.of(context);final card=CardBank.localize(entry.card,s.languageCode);final isDark=Theme.of(context).brightness==Brightness.dark;final fg=Theme.of(context).colorScheme.onSurface;return Container(margin:const EdgeInsets.only(bottom:10),decoration:BoxDecoration(color:isDark?_nightRaised:const Color(0xFFF8F1EB),borderRadius:BorderRadius.circular(20)),child:ListTile(contentPadding:const EdgeInsets.fromLTRB(16,12,10,12),leading:Container(width:42,height:42,decoration:BoxDecoration(color:_apricot.withOpacity(isDark ? .16 : .2),shape:BoxShape.circle),child:const Icon(Icons.auto_awesome_rounded,color:_apricot,size:20)),title:Text(card.title,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:fg,fontWeight:FontWeight.w700)),subtitle:Padding(padding:const EdgeInsets.only(top:4),child:Text('${card.kind} · ${_humanDate(DateTime.parse(entry.date),s.languageCode)}',style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',fontSize:12))),trailing:IconButton(tooltip:entry.favorite?s.removeFavorite:s.saveFavorite,onPressed:onToggleFavorite,icon:Icon(entry.favorite?Icons.bookmark_rounded:Icons.bookmark_border_rounded,color:entry.favorite?_apricot:(isDark?_lavender:const Color(0xFF70718A))))));}}

// ---------- Налаштування ----------
class _SettingsScreen extends StatelessWidget { const _SettingsScreen({required this.notificationsEnabled,required this.notifyHour,required this.notifyMinute,required this.selectionMode,required this.selectedThemes,required this.darkMode,required this.reducedMotion,required this.textScale,required this.languageMode,required this.onToggleNotifications,required this.onPickTime,required this.onSetSelectionMode,required this.onToggleTheme,required this.onSetDarkMode,required this.onSetReducedMotion,required this.onSetTextScale,required this.onSetLanguageMode});final bool notificationsEnabled,darkMode,reducedMotion;final int notifyHour,notifyMinute;final String selectionMode,textScale,languageMode;final Set<String> selectedThemes;final Future<void> Function(bool) onToggleNotifications,onSetDarkMode,onSetReducedMotion;final Future<void> Function() onPickTime;final Future<void> Function(String) onSetSelectionMode,onToggleTheme,onSetTextScale,onSetLanguageMode;
  @override Widget build(BuildContext context){final s=AppStrings.of(context);final isDark=Theme.of(context).brightness==Brightness.dark;final fg=Theme.of(context).colorScheme.onSurface;final muted=isDark?_lavender:const Color(0xFF70718A);return SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(20,18,20,34),children:[Text(s.settings,style:TextStyle(color:fg,fontSize:30,fontWeight:FontWeight.w700)),const SizedBox(height:6),Text(s.settingsIntro,style:TextStyle(color:muted,fontFamily:'sans-serif',height:1.4)),const SizedBox(height:28),_SectionTitle(label:s.language),_SettingsPanel(children:[RadioListTile<String>(value:'system',groupValue:languageMode,onChanged:(v){if(v!=null)onSetLanguageMode(v);},title:Text(s.systemLanguage),subtitle:Text(s.systemLanguageDescription)),const Divider(height:1),RadioListTile<String>(value:'uk',groupValue:languageMode,onChanged:(v){if(v!=null)onSetLanguageMode(v);},title:Text(s.ukrainian),subtitle:Text(s.languageDescription)),const Divider(height:1),RadioListTile<String>(value:'en',groupValue:languageMode,onChanged:(v){if(v!=null)onSetLanguageMode(v);},title:Text(s.english),subtitle:Text(s.languageDescription))]),const SizedBox(height:25),_SectionTitle(label:s.myRhythm),_SettingsPanel(children:[SwitchListTile.adaptive(value:notificationsEnabled,onChanged:onToggleNotifications,secondary:const Icon(Icons.notifications_none_rounded),title:Text(s.reminder),subtitle:Text(s.reminderDescription)),const Divider(height:1),ListTile(enabled:notificationsEnabled,onTap:notificationsEnabled?onPickTime:null,leading:const Icon(Icons.schedule_rounded),title:Text(s.reminderTime),subtitle:Text('${notifyHour.toString().padLeft(2,'0')}:${notifyMinute.toString().padLeft(2,'0')}'),trailing:const Icon(Icons.chevron_right_rounded)),const Divider(height:1),ListTile(leading:const Icon(Icons.send_outlined),title:Text(s.testReminder),subtitle:Text(s.testReminderDescription),onTap:()async{await NotificationScheduler.requestPermission();await NotificationScheduler.showTestNow(s);})]),const SizedBox(height:25),_SectionTitle(label:s.myCards),_SettingsPanel(children:[RadioListTile<String>(value:'random',groupValue:selectionMode,onChanged:(v){if(v!=null)onSetSelectionMode(v);},title:Text(s.randomWhisper),subtitle:Text(s.randomDescription)),const Divider(height:1),RadioListTile<String>(value:'themes',groupValue:selectionMode,onChanged:(v){if(v!=null)onSetSelectionMode(v);},title:Text(s.chosenThemes),subtitle:Text(s.chosenThemesDescription)),if(selectionMode=='themes')... [const Divider(height:1),Padding(padding:const EdgeInsets.fromLTRB(18,16,18,18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.allowedThemes,style:TextStyle(color:fg,fontWeight:FontWeight.w700)),const SizedBox(height:6),Text(selectedThemes.isEmpty?s.noThemes:s.themesSelected,style:TextStyle(color:muted,fontFamily:'sans-serif',fontSize:12,height:1.35)),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:_themeIds.map((id)=>FilterChip(selected:selectedThemes.contains(id),label:Text(s.theme(id)),onSelected:(_)=>onToggleTheme(id))).toList())]))]]),const SizedBox(height:25),_SectionTitle(label:s.mySpace),_SettingsPanel(children:[SwitchListTile.adaptive(value:darkMode,onChanged:onSetDarkMode,secondary:const Icon(Icons.dark_mode_outlined),title:Text(s.darkTheme),subtitle:Text(s.darkThemeDescription)),const Divider(height:1),SwitchListTile.adaptive(value:reducedMotion,onChanged:onSetReducedMotion,secondary:const Icon(Icons.motion_photos_off_outlined),title:Text(s.reduceMotion),subtitle:Text(s.reduceMotionDescription)),const Divider(height:1),Padding(padding:const EdgeInsets.fromLTRB(18,15,18,18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.textSize),const SizedBox(height:10),SegmentedButton<String>(segments:[ButtonSegment(value:'regular',label:Text(s.regular)),ButtonSegment(value:'large',label:Text(s.large))],selected:{textScale},onSelectionChanged:(set){if(set.isNotEmpty)onSetTextScale(set.first);})]))]),const SizedBox(height:25),_SectionTitle(label:s.onHomeScreen),_SettingsPanel(children:[ListTile(leading:const Icon(Icons.widgets_outlined),title:Text(s.widgetTitle),subtitle:Text(s.widgetDescription))]),const SizedBox(height:25),_SectionTitle(label:s.about),_SettingsPanel(children:[ListTile(leading:const Icon(Icons.info_outline_rounded),title:Text(s.appName),subtitle:Text(s.versionDescription))]) ]));}
}
class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.label});final String label;@override Widget build(BuildContext context){final isDark=Theme.of(context).brightness==Brightness.dark;return Padding(padding:const EdgeInsets.only(left:4,bottom:9),child:Text(label.toUpperCase(),style:TextStyle(color:isDark?_lavender:const Color(0xFF70718A),fontFamily:'sans-serif',fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1.05)));}}
class _SettingsPanel extends StatelessWidget { const _SettingsPanel({required this.children});final List<Widget> children;@override Widget build(BuildContext context){final isDark=Theme.of(context).brightness==Brightness.dark;return Container(decoration:BoxDecoration(color:isDark?_nightSurface:_paperSurface,borderRadius:BorderRadius.circular(22),border:Border.all(color:isDark?_lineDark:const Color(0xFFE8DED6))),child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Column(children:children)));}}
