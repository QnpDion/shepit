import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

const BG = Color(0xFF0A0612);
const GOLD = Color(0xFFA5804F);
const GOLD_LIGHT = Color(0xFFD9C7A3);
const PURPLE = Color(0xFF6B4A9E);
const PURPLE_LIGHT = Color(0xFFB79CE0);
const CARD_BG = Color(0xFF15101F);

Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await _notifications.initialize(initSettings);
  tz_data.initializeTimeZones();
  try {
    final locationName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Europe/Kyiv'));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications();
  runApp(const ShepitApp());
}

class ShepitApp extends StatelessWidget {
  const ShepitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Шепіт',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BG,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PURPLE,
          brightness: Brightness.dark,
          primary: PURPLE_LIGHT,
          secondary: GOLD,
        ),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

// ---------- Модель картки ----------

class OracleCard {
  final String type;
  final String text;
  OracleCard(this.type, this.text);

  Map<String, dynamic> toJson() => {'type': type, 'text': text};
  factory OracleCard.fromJson(Map<String, dynamic> j) =>
      OracleCard(j['type'] as String, j['text'] as String);
}

class CardBank {
  static final List<String> _openers = [
    'Сьогодні зорі натякають:',
    'Карти лягли так:',
    'Доля шепоче:',
    'Знак дня:',
    'Прочитано між рядків:',
    'Тіні свічки показують:',
  ];
  static final List<String> _subjects = [
    'у справах',
    'у стосунках',
    'у грошових питаннях',
    "у здоров'ї",
    'у творчості',
    'у несподіваних зустрічах',
    'у давніх планах',
  ];
  static final List<String> _outcomes = [
    'чекає приємний поворот',
    'варто довіритись інтуїції',
    'прийде важлива звістка',
    "з'явиться нова можливість",
    'потрібно проявити терпіння',
    'старі зусилля нарешті окупляться',
    'краще зробити паузу',
  ];
  static final List<String> _caveats = [
    'але не поспішай.',
    'тримай це при собі.',
    'довірся моменту.',
    'усе стається вчасно.',
    'будь уважним до деталей.',
    'не ігноруй знаки.',
  ];

  static final List<String> _advice = [
    'Сьогодні не час собі у чомусь відмовляти.',
    'Сьогодні можна нічого не встигнути — і це нормально.',
    'Хтось чекає, щоб ти написав першим.',
    'Правильний час — це зараз, а не колись.',
    'Дозволь собі бути не в настрої.',
    'Маленька дія сьогодні — велика зміна завтра.',
    'Не завжди потрібно пояснювати своє рішення.',
    'Іноді найкращий план — відпочити.',
    'Почни день з питання собі: "Що насправді важливо сьогодні?"',
    'Одна маленька дія зараз важливіша за великий план "колись".',
    'Скажи вголос те, що довго тримав у собі.',
    'Прибери одну зайву річ зі свого простору — і з голови.',
    'Подякуй комусь щиро, без приводу.',
    'Не відповідай одразу — дай собі хвилину подумати.',
    'Зроби перший крок, навіть маленький.',
    'Сьогодні гарний день, щоб пробачити — собі чи іншим.',
    'Заплануй щось приємне тільки для себе.',
    'Вимкни сповіщення хоча б на годину.',
    'Запиши три речі, за які вдячний.',
    'Прогулянка вирішує більше, ніж здається.',
  ];

  static final List<String> _quotes = [
    'Тиша теж відповідь.',
    'Не всі шляхи ведуть уперед — деякі ведуть углиб.',
    'Терпіння — це теж дія.',
    'Малі кроки не означають повільний рух.',
    'Те, що відкладено, не завжди втрачено.',
    'Спокій — це теж перемога.',
    'Сумнів іноді мудріший за впевненість.',
    'Не кожна буря призначена для тебе.',
    'Час не лікує — він вчить жити з новим.',
    'Найкраще рішення часто найпростіше.',
    'Сила у тому, щоб почати заново.',
    'Те, що болить, ще не означає, що це неправильно.',
    'Іноді треба загубитись, щоб знайти новий шлях.',
    'Справжня зміна починається з малого визнання.',
    'Не поспішай туди, де ще не готовий бути.',
  ];

  static final List<String> _facts = [
    'Мед не псується — археологи знаходили їстівний мед у гробницях фараонів.',
    'Восьминоги мають три серця.',
    'Банани — це ягоди, а полуниця — ні.',
    'Найкоротша війна в історії тривала менше 40 хвилин.',
    'Людське серце б\'ється близько 100 000 разів на добу.',
    'Акули існують довше, ніж дерева.',
    'В одній краплі дощу може бути до мільйона бактерій.',
    'Місяць віддаляється від Землі приблизно на 3,8 см щороку.',
    'У жирафа язик темно-синього кольору.',
    'Перше фото людини зробили випадково, у 1838 році, у Парижі.',
  ];

  static int _seedFor(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static OracleCard cardFor(DateTime date) {
    final seed = _seedFor(date);
    final rnd = Random(seed);
    final typeRoll = rnd.nextInt(4);

    switch (typeRoll) {
      case 0:
        final opener = _openers[rnd.nextInt(_openers.length)];
        final subject = _subjects[rnd.nextInt(_subjects.length)];
        final outcome = _outcomes[rnd.nextInt(_outcomes.length)];
        final caveat = _caveats[rnd.nextInt(_caveats.length)];
        return OracleCard('Передбачення', '$opener $subject $outcome, $caveat');
      case 1:
        return OracleCard('Порада дня', _advice[rnd.nextInt(_advice.length)]);
      case 2:
        return OracleCard('Цитата', _quotes[rnd.nextInt(_quotes.length)]);
      default:
        return OracleCard('Цікавий факт', _facts[rnd.nextInt(_facts.length)]);
    }
  }
}

// ---------- Сховище ----------

class HistoryEntry {
  final String date; // yyyy-MM-dd
  final OracleCard card;
  HistoryEntry(this.date, this.card);

  Map<String, dynamic> toJson() => {'date': date, 'card': card.toJson()};
  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
      j['date'] as String, OracleCard.fromJson(j['card'] as Map<String, dynamic>));
}

class ShepitStorage {
  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/shepit_data.json');
  }

  static Future<Map<String, dynamic>> load() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {
      'history': [],
      'notificationsEnabled': false,
      'notifyHour': 9,
      'notifyMinute': 0,
    };
  }

  static Future<void> save(Map<String, dynamic> data) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _dateHuman(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return key;
  return '${parts[2]}.${parts[1]}.${parts[0]}';
}

// ---------- Планувальник сповіщень ----------

class NotificationScheduler {
  static const int _baseId = 500;
  static const int _daysAhead = 30;

  static Future<void> requestPermission() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> cancelAll() async {
    for (int i = 0; i < _daysAhead; i++) {
      await _notifications.cancel(_baseId + i);
    }
  }

  static Future<void> scheduleUpcoming(int hour, int minute) async {
    await cancelAll();
    const androidDetails = AndroidNotificationDetails(
      'shepit_daily',
      'Щоденний шепіт',
      channelDescription: "Щоденне передбачення, порада чи цитата від Шепоту",
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    for (int i = 1; i <= _daysAhead; i++) {
      final target = DateTime.now().add(Duration(days: i));
      final card = CardBank.cardFor(target);
      var when = tz.TZDateTime(
        tz.local,
        target.year,
        target.month,
        target.day,
        hour,
        minute,
      );
      if (when.isBefore(now)) continue;
      await _notifications.zonedSchedule(
        _baseId + i,
        'Шепіт: ${card.type}',
        card.text,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> showTestNow() async {
    final card = CardBank.cardFor(DateTime.now());
    const androidDetails = AndroidNotificationDetails(
      'shepit_daily',
      'Щоденний шепіт',
      channelDescription: "Щоденне передбачення, порада чи цитата від Шепоту",
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(999, 'Шепіт: ${card.type}', card.text, details);
  }
}

// ---------- UI: картка з переворотом ----------

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool flipped;
  final VoidCallback? onTap;
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
    this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.flipped) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped != oldWidget.flipped) {
      if (widget.flipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isBack = angle > pi / 2;
          final displayAngle = isBack ? angle - pi : angle;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(displayAngle),
            child: isBack ? widget.front : widget.back,
          );
        },
      ),
    );
  }
}

Widget _mysticCardShell({required Widget child}) {
  return Container(
    width: 280,
    height: 400,
    decoration: BoxDecoration(
      color: CARD_BG,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: GOLD, width: 1.5),
      boxShadow: [
        BoxShadow(color: PURPLE.withOpacity(0.45), blurRadius: 40, spreadRadius: 4),
      ],
      gradient: RadialGradient(
        colors: [PURPLE.withOpacity(0.35), CARD_BG],
        radius: 1.2,
      ),
    ),
    padding: const EdgeInsets.all(24),
    child: child,
  );
}

Widget _cardBack() {
  return _mysticCardShell(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: GOLD, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'ШЕПІТ',
          style: TextStyle(
            color: GOLD,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Торкнись, щоб дізнатись',
          style: TextStyle(color: PURPLE_LIGHT.withOpacity(0.8), fontSize: 13),
        ),
      ],
    ),
  );
}

Widget _cardFront(OracleCard card) {
  return _mysticCardShell(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.type.toUpperCase(),
          style: const TextStyle(
            color: GOLD,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          card.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: GOLD_LIGHT,
            fontSize: 17,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

// ---------- Головний екран ----------

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;
  bool _loaded = false;
  List<HistoryEntry> _history = [];
  bool _notificationsEnabled = false;
  int _notifyHour = 9;
  int _notifyMinute = 0;
  bool _revealedToday = false;
  OracleCard? _todayCard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ShepitStorage.load();
    final historyRaw = (data['history'] as List?) ?? [];
    final history = historyRaw
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<HistoryEntry>();

    final todayKey = _dateKey(DateTime.now());
    HistoryEntry? todayEntry;
    for (final h in history) {
      if (h.date == todayKey) {
        todayEntry = h;
        break;
      }
    }

    setState(() {
      _history = history;
      _notificationsEnabled = (data['notificationsEnabled'] as bool?) ?? false;
      _notifyHour = (data['notifyHour'] as int?) ?? 9;
      _notifyMinute = (data['notifyMinute'] as int?) ?? 0;
      _revealedToday = todayEntry != null;
      _todayCard = todayEntry?.card;
      _loaded = true;
    });

    if (_notificationsEnabled) {
      await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute);
    }
  }

  Future<void> _persist() async {
    await ShepitStorage.save({
      'history': _history.map((e) => e.toJson()).toList(),
      'notificationsEnabled': _notificationsEnabled,
      'notifyHour': _notifyHour,
      'notifyMinute': _notifyMinute,
    });
  }

  void _revealToday() {
    final card = CardBank.cardFor(DateTime.now());
    final entry = HistoryEntry(_dateKey(DateTime.now()), card);
    setState(() {
      _todayCard = card;
      _revealedToday = true;
      _history.insert(0, entry);
    });
    _persist();
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    if (value) {
      await NotificationScheduler.requestPermission();
      await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute);
    } else {
      await NotificationScheduler.cancelAll();
    }
    _persist();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notifyHour, minute: _notifyMinute),
    );
    if (picked != null) {
      setState(() {
        _notifyHour = picked.hour;
        _notifyMinute = picked.minute;
      });
      if (_notificationsEnabled) {
        await NotificationScheduler.scheduleUpcoming(_notifyHour, _notifyMinute);
      }
      _persist();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: BG,
        body: Center(child: CircularProgressIndicator(color: GOLD)),
      );
    }
    return Scaffold(
      backgroundColor: BG,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildTodayTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: CARD_BG,
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Сьогодні'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Історія'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Налаштування'),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return SafeArea(
      child: Center(
        child: FlipCard(
          flipped: _revealedToday,
          onTap: _revealedToday ? null : _revealToday,
          back: _cardBack(),
          front: _todayCard != null ? _cardFront(_todayCard!) : _cardBack(),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SafeArea(
      child: _history.isEmpty
          ? const Center(
              child: Text(
                'Історія порожня.\nВідкрий картку дня, щоб почати.',
                textAlign: TextAlign.center,
                style: TextStyle(color: GOLD_LIGHT),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const Divider(color: PURPLE, height: 1),
              itemBuilder: (context, index) {
                final entry = _history[index];
                return ListTile(
                  leading: const Icon(Icons.auto_awesome, color: GOLD),
                  title: Text(entry.card.text, style: const TextStyle(color: GOLD_LIGHT)),
                  subtitle: Text(
                    '${entry.card.type} · ${_dateHuman(entry.date)}',
                    style: const TextStyle(color: PURPLE_LIGHT),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSettingsTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            activeColor: GOLD,
            title: const Text('Push-сповіщення', style: TextStyle(color: GOLD_LIGHT)),
            subtitle: const Text(
              'Отримувати щоденне передбачення сповіщенням, без відкриття застосунку',
              style: TextStyle(color: PURPLE_LIGHT),
            ),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          ListTile(
            enabled: _notificationsEnabled,
            leading: const Icon(Icons.access_time, color: GOLD),
            title: const Text('Час сповіщення', style: TextStyle(color: GOLD_LIGHT)),
            subtitle: Text(
              '${_notifyHour.toString().padLeft(2, '0')}:${_notifyMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: PURPLE_LIGHT),
            ),
            onTap: _notificationsEnabled ? _pickTime : null,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: GOLD, side: const BorderSide(color: GOLD)),
            onPressed: () async {
              await NotificationScheduler.requestPermission();
              await NotificationScheduler.showTestNow();
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Надіслати тестове сповіщення зараз'),
          ),
        ],
      ),
    );
  }
}
ENDOFFILE