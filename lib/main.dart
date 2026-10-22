import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarPage(),
    ));

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Jalali month = Jalali.now();
  Jalali? selected = Jalali.now();
  final Map<String, List<String>> personalEvents = {};

  static const names = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  static const weekdays = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];

  // مناسبت‌ها و تعطیلات رسمی تقویم ایران برای سال ۱۴۰۵.
  // تاریخ‌های قمری ممکن است با اعلام رسمی یک روز جابه‌جا شوند.
  static const Map<String, List<String>> officialHolidays = {
    '1405-1-1': ['نوروز', 'عید سعید فطر'],
    '1405-1-2': ['عید نوروز', 'تعطیل عید فطر'],
    '1405-1-3': ['عید نوروز'],
    '1405-1-4': ['عید نوروز'],
    '1405-1-12': ['روز جمهوری اسلامی ایران'],
    '1405-1-13': ['روز طبیعت (سیزده‌بدر)'],
    '1405-1-25': ['شهادت امام جعفر صادق (ع)'],
    '1405-3-6': ['عید قربان'],
    '1405-3-14': ['عید غدیر خم', 'رحلت امام خمینی (ره)'],
    '1405-3-15': ['قیام ۱۵ خرداد'],
    '1405-4-3': ['تاسوعای حسینی'],
    '1405-4-4': ['عاشورای حسینی'],
    '1405-5-13': ['اربعین حسینی'],
    '1405-5-21': ['رحلت پیامبر (ص) و شهادت امام حسن (ع)'],
    '1405-5-22': ['شهادت امام رضا (ع)'],
    '1405-5-30': ['شهادت امام حسن عسکری (ع)'],
    '1405-6-8': ['میلاد پیامبر (ص) و امام جعفر صادق (ع)'],
    '1405-8-22': ['شهادت حضرت فاطمه زهرا (س)'],
    '1405-10-2': ['ولادت امام علی (ع) - روز پدر'],
    '1405-10-16': ['مبعث پیامبر (ص)'],
    '1405-11-4': ['ولادت امام زمان (عج) - نیمه شعبان'],
    '1405-11-22': ['پیروزی انقلاب اسلامی'],
    '1405-12-9': ['شهادت امام علی (ع)'],
    '1405-12-19': ['عید سعید فطر'],
    '1405-12-20': ['تعطیل عید سعید فطر'],
    '1405-12-29': ['ملی شدن صنعت نفت ایران'],
  };

  static const Map<String, List<String>> otherEvents = {
    '1405-1-1': ['آغاز سال نو'],
    '1405-1-13': ['روز طبیعت'],
    '1405-2-11': ['روز کارگر'],
    '1405-2-12': ['روز معلم'],
    '1405-3-1': ['روز بهره‌وری و بهینه‌سازی مصرف'],
    '1405-6-17': ['قیام ۱۷ شهریور'],
    '1405-7-20': ['روز بزرگداشت حافظ'],
    '1405-8-13': ['روز دانش‌آموز'],
    '1405-9-16': ['روز دانشجو'],
    '1405-9-30': ['شب یلدا'],
    '1405-11-15': ['جشن سپندارمذگان'],
  };

  String key(Jalali d) => '${d.year}-${d.month}-${d.day}';

  @override
  void initState() {
    super.initState();
    _loadPersonalEvents();
  }

  Future<void> _loadPersonalEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <String, List<String>>{};
    for (final k in prefs.getKeys()) {
      if (k.startsWith('calendar_event_')) {
        final values = prefs.getStringList(k);
        if (values != null && values.isNotEmpty) {
          loaded[k.substring('calendar_event_'.length)] = values;
        }
      }
    }
    if (mounted) setState(() => personalEvents.addAll(loaded));
  }

  List<String> eventsFor(Jalali d) => [
        ...?officialHolidays[key(d)],
        ...?otherEvents[key(d)],
        ...?personalEvents[key(d)],
      ];

  bool isOfficialHoliday(Jalali d) => officialHolidays.containsKey(key(d));

  Future<void> _addEvent() async {
    if (selected == null) return;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('افزودن رویداد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'مثلاً: وقت دکتر یا جلسه',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(dialogContext, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty || !mounted) return;

    final dateKey = key(selected!);
    final updated = [...?personalEvents[dateKey], value.trim()];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('calendar_event_$dateKey', updated);
    if (mounted) setState(() => personalEvents[dateKey] = updated);
  }

  Future<void> _removePersonalEvent(String dateKey, String event) async {
    final updated = [...?personalEvents[dateKey]]..remove(event);
    final prefs = await SharedPreferences.getInstance();
    if (updated.isEmpty) {
      await prefs.remove('calendar_event_$dateKey');
    } else {
      await prefs.setStringList('calendar_event_$dateKey', updated);
    }
    if (mounted) {
      setState(() {
        if (updated.isEmpty) {
          personalEvents.remove(dateKey);
        } else {
          personalEvents[dateKey] = updated;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = Jalali(month.year, month.month, 1);
    // هفته از شنبه شروع می‌شود؛ شنبه در ستون سمت راست قرار می‌گیرد.
    final offset = first.weekDay - 1;
    final count = ((offset + month.monthLength + 6) ~/ 7) * 7;
    final today = Jalali.now();
    final selectedEvents = selected == null ? <String>[] : eventsFor(selected!);
    final selectedKey = selected == null ? '' : key(selected!);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقویم شمسی'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'رفتن به امروز',
              onPressed: () => setState(() {
                month = Jalali.now();
                selected = Jalali.now();
              }),
              icon: const Icon(Icons.today),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'ماه قبل',
                    onPressed: () => setState(() {
                      month = Jalali(month.year, month.month, 1).addMonths(-1);
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Text(
                    '${names[month.month - 1]} ${month.year}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    tooltip: 'ماه بعد',
                    onPressed: () => setState(() {
                      month = Jalali(month.year, month.month, 1).addMonths(1);
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
              Row(
                textDirection: TextDirection.rtl,
                children: weekdays.asMap().entries.map((entry) {
                  final isFriday = entry.key == 6;
                  return Expanded(
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isFriday ? Colors.red.shade700 : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  itemCount: count,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, i) {
                    final n = i - offset + 1;
                    if (n < 1 || n > month.monthLength) {
                      return const SizedBox.shrink();
                    }

                    final d = Jalali(month.year, month.month, n);
                    final active = selected != null && key(d) == key(selected!);
                    final isToday = key(d) == key(today);
                    final isFriday = d.weekDay == 7;
                    final official = isOfficialHoliday(d);
                    final dayEvents = eventsFor(d);
                    final background = active
                        ? Colors.indigo
                        : official
                            ? Colors.red.shade50
                            : isToday
                                ? Colors.indigo.shade50
                                : null;
                    final foreground = active
                        ? Colors.white
                        : (official || isFriday)
                            ? Colors.red.shade700
                            : Colors.black87;

                    return InkWell(
                      onTap: () => setState(() => selected = d),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(9),
                          border: isToday && !active
                              ? Border.all(color: Colors.indigo, width: 1.5)
                              : official && !active
                                  ? Border.all(color: Colors.red.shade200)
                                  : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$n',
                              style: TextStyle(
                                color: foreground,
                                fontWeight: (official || isFriday || isToday || dayEvents.isNotEmpty)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (dayEvents.isNotEmpty)
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active
                                        ? Colors.white
                                        : official
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: const [
                  _Legend(color: Colors.red, label: 'تعطیل رسمی'),
                  _Legend(color: Colors.orange, label: 'مناسبت / رویداد'),
                  _Legend(color: Colors.indigo, label: 'امروز / انتخاب‌شده'),
                ],
              ),
              const SizedBox(height: 10),
              if (selected != null)
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selected!.day} ${names[selected!.month - 1]} ${selected!.year}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            IconButton(
                              tooltip: 'افزودن رویداد شخصی',
                              onPressed: _addEvent,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        Expanded(
                          child: selectedEvents.isEmpty
                              ? const Center(child: Text('رویدادی برای این روز ثبت نشده است.'))
                              : ListView(
                                  children: selectedEvents.map((event) {
                                    final personal = (personalEvents[selectedKey] ?? []).contains(event);
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        officialHolidays[selectedKey]?.contains(event) == true
                                            ? Icons.event_busy
                                            : Icons.event,
                                        color: officialHolidays[selectedKey]?.contains(event) == true
                                            ? Colors.red
                                            : Colors.orange,
                                      ),
                                      title: Text(event, style: const TextStyle(fontSize: 13)),
                                      trailing: personal
                                          ? IconButton(
                                              tooltip: 'حذف رویداد شخصی',
                                              icon: const Icon(Icons.delete_outline, size: 20),
                                              onPressed: () => _removePersonalEvent(selectedKey, event),
                                            )
                                          : null,
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 9),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      );
}
