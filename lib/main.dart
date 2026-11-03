import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(CampusApp(preferences: preferences));
}

class CampusApp extends StatefulWidget {
  final SharedPreferences preferences;
  const CampusApp({super.key, required this.preferences});
  @override
  State<CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends State<CampusApp> {
  final messenger = GlobalKey<ScaffoldMessengerState>();
  int page = 0;
  late bool dark = widget.preferences.getBool('dark') ?? false;
  late String name = widget.preferences.getString('name') ?? 'Alex';
  late Set<String> saved = (widget.preferences.getStringList('saved') ?? [])
      .toSet();
  late Set<String> read = (widget.preferences.getStringList('read') ?? [])
      .toSet();
  String category = 'All', department = 'All', query = '';
  bool savedOnly = false;
  int day = DateTime.now().weekday;
  final searchController = TextEditingController();
  static const titles = [
    'Overview',
    'Announcements',
    'Timetable',
    'Faculty directory',
    'Campus guide',
  ];
  static const labels = ['Home', 'Notices', 'Timetable', 'Faculty', 'Campus'];
  static const icons = [
    Icons.space_dashboard_outlined,
    Icons.campaign_outlined,
    Icons.calendar_month_outlined,
    Icons.people_outline,
    Icons.school_outlined,
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> persist(Future<bool> operation) async {
    try {
      if (!await operation && mounted) {
        toast('Your changes could not be saved. Please try again.');
      }
    } catch (_) {
      if (mounted) {
        toast('Storage is unavailable. Changes will last for this session.');
      }
    }
  }

  void navigate(int value) => setState(() {
    page = value;
    query = '';
    searchController.clear();
  });
  void toast(String text) =>
      messenger.currentState?.showSnackBar(SnackBar(content: Text(text)));
  void bookmark(Notice notice) {
    setState(() {
      if (!saved.add(notice.id)) saved.remove(notice.id);
    });
    persist(widget.preferences.setStringList('saved', saved.toList()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: plum,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    return MaterialApp(
      scaffoldMessengerKey: messenger,
      title: 'Campus · Student Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: dark
            ? const Color(0xFF17171D)
            : const Color(0xFFF6F6F9),
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: Builder(
        builder: (context) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            return Scaffold(
              bottomNavigationBar: wide
                  ? null
                  : NavigationBar(
                      selectedIndex: page,
                      onDestinationSelected: navigate,
                      destinations: List.generate(
                        5,
                        (i) => NavigationDestination(
                          icon: Icon(icons[i]),
                          label: labels[i],
                        ),
                      ),
                    ),
              body: SafeArea(
                child: Row(
                  children: [
                    if (wide) sidebar(context),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: wide ? 36 : 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                if (!wide) ...[
                                  const Icon(Icons.school_rounded, color: plum),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Text(
                                    wide ? titles[page] : 'campus.',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: dark
                                      ? 'Use light theme'
                                      : 'Use dark theme',
                                  onPressed: () {
                                    setState(() => dark = !dark);
                                    persist(
                                      widget.preferences.setBool('dark', dark),
                                    );
                                  },
                                  icon: Icon(
                                    dark
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Unread announcements',
                                  onPressed: () {
                                    navigate(1);
                                  },
                                  icon: Badge(
                                    isLabelVisible: notices.any(
                                      (n) => !read.contains(n.id),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Semantics(
                                  label: 'Edit student profile',
                                  button: true,
                                  child: InkWell(
                                    onTap: () => profile(context),
                                    borderRadius: BorderRadius.circular(24),
                                    child: CircleAvatar(
                                      backgroundColor: scheme.primaryContainer,
                                      child: Text(
                                        name.trim().isEmpty
                                            ? 'S'
                                            : name.trim()[0].toUpperCase(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                wide ? 36 : 20,
                                8,
                                wide ? 36 : 20,
                                28,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1240,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      switch (page) {
                                        0 => home(context),
                                        1 => noticePage(context),
                                        2 => timetable(context),
                                        3 => facultyPage(context),
                                        _ => campus(context),
                                      },
                                      const SizedBox(height: 32),
                                      Text(
                                        'CAMPUS COMPANION  /  DEMO CAMPUS\nSample schedules, contacts and notices. Not connected to a college.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          height: 1.8,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget sidebar(BuildContext context) => Container(
    width: 238,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        right: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: .1),
        ),
      ),
    ),
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(Icons.school_rounded, color: plum, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'campus.',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'A little closer to campus.',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 44),
        const Text(
          'YOUR WORKSPACE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          5,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                selected: page == i,
                selectedTileColor: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                leading: Icon(icons[i], size: 21),
                title: Text(
                  titles[i],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => navigate(i),
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.wb_sunny_outlined, color: teal),
              SizedBox(height: 12),
              Text(
                'Make today count.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Your classes, people and campus. All in one place.',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => profile(context),
          icon: const Icon(Icons.tune, size: 18),
          label: const Text('Profile & preferences'),
        ),
      ],
    ),
  );

  Widget heading(String eyebrow, String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: teal,
            fontSize: 11,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(subtitle, style: const TextStyle(fontSize: 14, height: 1.6)),
      ],
    ),
  );
  Widget box(Widget child, {Color? color}) => Card(
    color: color,
    child: Padding(padding: const EdgeInsets.all(22), child: child),
  );
  Widget section(
    String title, {
    String? action,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action)),
      ],
    ),
  );
  Widget tag(String text, {Color color = teal}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
  Widget grid(List<Widget> children, {double minimum = 290}) => LayoutBuilder(
    builder: (_, c) {
      final count = (c.maxWidth / minimum).floor().clamp(1, 3);
      final width = (c.maxWidth - (count - 1) * 16) / count;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(),
      );
    },
  );

  List<Lesson> get today =>
      lessons.where((l) => l.day == DateTime.now().weekday).toList();
  Lesson? get nextLesson {
    final now = DateTime.now();
    for (final l in today) {
      if (now.isBefore(
        DateTime(now.year, now.month, now.day, l.hour + (l.lab ? 2 : 1)),
      )) {
        return l;
      }
    }
    return null;
  }

  String time(int hour) =>
      '${hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}';

  Widget home(BuildContext context) {
    final now = DateTime.now();
    final next = nextLesson;
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          '${weekdays[now.weekday - 1]} · ${now.day}/${now.month}/${now.year}',
          'Hello, $name 👋',
          'A fresh day. Everything you need, right here.',
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF65435F), Color(0xFF87637F)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFE8D8B8), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'YOUR DAY, AT A GLANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                next?.subject ?? 'A little room to recharge.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                next == null
                    ? 'No more classes scheduled today. Explore what’s happening on campus.'
                    : '${time(next.hour)} · ${next.room}\n${next.teacher}',
                style: const TextStyle(color: Colors.white, height: 1.8),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: plum,
                ),
                onPressed: () {
                  setState(() => day = DateTime.now().weekday);
                  navigate(2);
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('My timetable'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        grid([
          stat(
            'CLASSES TODAY',
            '${today.length}',
            'Your learning lineup',
            Icons.calendar_today_outlined,
            teal,
          ),
          stat(
            'UNREAD NOTICES',
            '${notices.where((n) => !read.contains(n.id)).length}',
            'Keep up with campus',
            Icons.campaign_outlined,
            plum,
          ),
          stat(
            'SAVED FOR LATER',
            '${saved.length}',
            'Your bookmarked notices',
            Icons.bookmark_border,
            const Color(0xFFAF762C),
          ),
        ], minimum: 230),
        section('Your campus, one tap away'),
        grid(
          List.generate(
            4,
            (i) => box(
              InkWell(
                onTap: () => navigate(i + 1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: [
                          plum,
                          teal,
                          const Color(0xFF4770A0),
                          const Color(0xFFAF762C),
                        ][i].withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icons[i + 1],
                        color: [
                          plum,
                          teal,
                          const Color(0xFF4770A0),
                          const Color(0xFFAF762C),
                        ][i],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        labels[i + 1],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 13),
                  ],
                ),
              ),
            ),
          ),
          minimum: 230,
        ),
        section(
          'Latest on campus',
          action: 'View all',
          onTap: () => navigate(1),
        ),
        ...notices
            .take(3)
            .map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: noticeCard(context, n),
              ),
            ),
      ],
    );
  }

  Widget stat(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) => box(
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Icon(icon, color: color, size: 30),
      ],
    ),
  );

  Widget search(String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: searchController,
      onChanged: (s) => setState(() => query = s),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  searchController.clear();
                  setState(() => query = '');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    ),
  );
  Widget filters(
    List<String> values,
    String selected,
    ValueChanged<String> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (v) => ChoiceChip(
              label: Text(v),
              selected: selected == v,
              onSelected: (_) => onChanged(v),
            ),
          )
          .toList(),
    ),
  );
  Widget empty(String message) => SizedBox(
    width: double.infinity,
    child: box(
      Column(
        children: [
          const Icon(Icons.search_off, size: 40, color: teal),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() {
              query = '';
              searchController.clear();
              category = 'All';
              department = 'All';
              savedOnly = false;
            }),
            child: const Text('Reset filters'),
          ),
        ],
      ),
    ),
  );

  Widget noticePage(BuildContext context) {
    final matches = notices
        .where(
          (n) =>
              (category == 'All' || category == n.category) &&
              (!savedOnly || saved.contains(n.id)) &&
              '${n.title} ${n.body} ${n.author}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'The campus feed',
          'Stay in the know.',
          'Important updates, new opportunities, and everything in between.',
        ),
        search('Search announcements…'),
        filters(
          ['All', 'Academics', 'Events', 'Campus'],
          category,
          (v) => setState(() => category = v),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${matches.length} announcements',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            FilterChip(
              label: const Text('Saved only'),
              selected: savedOnly,
              onSelected: (v) => setState(() => savedOnly = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (matches.isEmpty) empty('No announcements match your filters.'),
        ...matches.map(
          (n) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: noticeCard(context, n),
          ),
        ),
      ],
    );
  }

  Widget noticeCard(BuildContext context, Notice n) => box(
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: () => openNotice(context, n),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    tag(
                      n.category,
                      color: n.category == 'Events' ? plum : teal,
                    ),
                    if (n.pinned) const Icon(Icons.push_pin_outlined, size: 14),
                    if (!read.contains(n.id))
                      const Text(
                        'NEW',
                        style: TextStyle(
                          color: teal,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  n.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  n.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 12),
                Text(
                  n.author,
                  style: const TextStyle(
                    fontSize: 11,
                    color: teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: saved.contains(n.id)
              ? 'Remove bookmark'
              : 'Save announcement',
          onPressed: () => bookmark(n),
          icon: Icon(
            saved.contains(n.id) ? Icons.bookmark : Icons.bookmark_border,
            color: plum,
          ),
        ),
      ],
    ),
  );

  void openNotice(BuildContext context, Notice n) {
    setState(() => read.add(n.id));
    persist(widget.preferences.setStringList('read', read.toList()));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(n.title),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                tag(n.category),
                const SizedBox(height: 20),
                Text(n.body, style: const TextStyle(height: 1.8)),
                const SizedBox(height: 20),
                Text(
                  'Published by ${n.author}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget timetable(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selected = lessons.where((l) => l.day == day).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Plan your week',
          'A little structure. A lot of possibility.',
          'Computer Science · Semester 3 · Section A · Sample timetable',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            7,
            (i) => ChoiceChip(
              label: Text(days[i]),
              selected: day == i + 1,
              onSelected: (_) => setState(() => day = i + 1),
            ),
          ),
        ),
        section(
          '${days[day - 1]} schedule',
          action: 'Today',
          onTap: () => setState(() => day = DateTime.now().weekday),
        ),
        if (selected.isEmpty)
          box(
            const SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.weekend_outlined, size: 44, color: teal),
                  SizedBox(height: 16),
                  Text(
                    'No classes scheduled. Enjoy your day!',
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(height: 8),
                  Text('Choose a weekday to see your classes.'),
                ],
              ),
            ),
          ),
        ...selected.map((l) {
          final now = DateTime.now();
          final start = DateTime(now.year, now.month, now.day, l.hour);
          final end = start.add(Duration(hours: l.lab ? 2 : 1));
          final current =
              day == now.weekday && !now.isBefore(start) && now.isBefore(end);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: box(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      tag(
                        '${time(l.hour)} – ${time(l.hour + (l.lab ? 2 : 1))}',
                        color: plum,
                      ),
                      if (current) tag('In progress'),
                      if (l.lab)
                        tag('Practical', color: const Color(0xFF9B6F2D)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.subject,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l.code}  ·  ${l.room}',
                    style: const TextStyle(height: 1.8),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 17, color: teal),
                      const SizedBox(width: 6),
                      Expanded(child: Text(l.teacher)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        const Text(
          'Lunch break · 12:00–2:00 PM on teaching days',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget facultyPage(BuildContext context) {
    final matches = faculty
        .where(
          (f) =>
              (department == 'All' || department == f.department) &&
              '${f.name} ${f.department} ${f.role}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'People who guide you',
          'Find a familiar face.',
          'Browse departments, find office hours, and connect with faculty.',
        ),
        search('Search by name, role or department…'),
        filters(
          [
            'All',
            'Computer Science',
            'Mathematics',
            'Humanities',
            'Electronics',
          ],
          department,
          (v) => setState(() => department = v),
        ),
        if (matches.isEmpty) empty('No faculty match your search.'),
        grid(
          matches
              .map(
                (f) => box(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: plum.withValues(alpha: .12),
                        child: Text(
                          f.initials,
                          style: const TextStyle(
                            color: plum,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        f.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(f.role, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),
                      tag(f.department),
                      const SizedBox(height: 18),
                      detail(Icons.location_on_outlined, f.office),
                      detail(Icons.schedule, f.hours),
                      const Divider(height: 28),
                      OutlinedButton.icon(
                        onPressed: () => contact(context, f),
                        icon: const Icon(Icons.mail_outline, size: 18),
                        label: const Text('Contact & details'),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget detail(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: teal),
        const SizedBox(width: 9),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, height: 1.5)),
        ),
      ],
    ),
  );
  void contact(BuildContext context, Faculty f) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(f.name),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${f.role} · ${f.department}'),
            const SizedBox(height: 20),
            SelectableText(f.email),
            const SizedBox(height: 16),
            detail(Icons.location_on_outlined, f.office),
            detail(Icons.schedule, f.hours),
            const SizedBox(height: 12),
            const Text(
              'Demo contact. Replace example.edu addresses with your college’s verified faculty details.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: f.email));
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Email address copied')),
              );
            }
          },
          child: const Text('Copy email'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              final launched = await launchUrl(
                Uri(scheme: 'mailto', path: f.email),
              );
              if (!launched && ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No email app available. Use Copy email instead.',
                    ),
                  ),
                );
              }
            } catch (_) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Unable to open email. Use Copy email instead.',
                    ),
                  ),
                );
              }
            }
          },
          child: const Text('Open email'),
        ),
      ],
    ),
  );

  Widget campus(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heading(
        'Know your surroundings',
        'Find your place on campus.',
        'Useful spaces, opening hours, and the little details that help.',
      ),
      box(
        const Row(
          children: [
            Icon(Icons.info_outline, color: teal),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Welcome to Demo Campus. Locations and opening hours below are illustrative. Verify details with your institution.',
                style: TextStyle(height: 1.6),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      grid(
        facilities
            .map(
              (f) => box(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(f.icon, color: teal, size: 32),
                    const SizedBox(height: 18),
                    Text(
                      f.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    detail(Icons.location_on_outlined, f.location),
                    detail(Icons.access_time, f.hours),
                    const SizedBox(height: 8),
                    Text(
                      f.description,
                      style: const TextStyle(fontSize: 13, height: 1.7),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
      section('A few campus essentials'),
      box(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carry your student ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Keep it handy for library access, lab sessions, and campus services.',
            ),
            Divider(height: 28),
            Text(
              'Respect shared spaces',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Keep quiet zones quiet, leave labs tidy, and use the recycling points.',
            ),
            Divider(height: 28),
            Text('Need a hand?', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              'Visit Student Services in the Admin Block for help finding the right office.',
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> profile(BuildContext context) async {
    final controller = TextEditingController(text: name);
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your campus profile'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  maxLength: 30,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Preferred name',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Computer Science · Semester 3 · Section A',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This demo uses one sample student timetable. Your name, theme, read notices and bookmarks are saved on this device.',
                  style: TextStyle(fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Save profile'),
          ),
        ],
      ),
    );
    // Wait for the dialog exit animation before disposing its field controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (result != null && mounted) {
      setState(() => name = result);
      persist(widget.preferences.setString('name', result));
    }
  }
}
