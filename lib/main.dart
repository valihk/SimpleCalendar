import 'package:flutter/material.dart';
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

  static const names = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  // In the Jalali calendar, weekday 7 is Friday.
  String key(Jalali d) => '${d.year}-${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
    final first = Jalali(month.year, month.month, 1);
    final offset = first.weekDay - 1;
    final count = ((offset + month.monthLength + 6) ~/ 7) * 7;
    final today = Jalali.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقویم ساده'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                    .map((x) => Expanded(
                          child: Center(
                            child: Text(
                              x,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: x == 'ج' ? Colors.red : null,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                itemCount: count,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemBuilder: (context, i) {
                  final n = i - offset + 1;
                  if (n < 1 || n > month.monthLength) {
                    return const SizedBox.shrink();
                  }

                  final d = Jalali(month.year, month.month, n);
                  final active = selected != null && key(d) == key(selected!);
                  final isToday = key(d) == key(today);
                  final isHoliday = d.weekDay == 7;

                  final Color? background = active
                      ? Colors.indigo
                      : isToday
                          ? Colors.indigo.shade100
                          : null;
                  final Color foreground = active
                      ? Colors.white
                      : isHoliday
                          ? Colors.red.shade700
                          : Colors.black87;

                  return InkWell(
                    onTap: () => setState(() => selected = d),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(8),
                        border: isHoliday && !active
                            ? Border.all(color: Colors.red.shade200)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$n',
                          style: TextStyle(
                            color: foreground,
                            fontWeight: isHoliday || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 10),
                  SizedBox(width: 6),
                  Text('جمعه: تعطیل هفتگی'),
                  SizedBox(width: 16),
                  Icon(Icons.circle, color: Colors.indigo, size: 10),
                  SizedBox(width: 6),
                  Text('روز انتخاب‌شده'),
                ],
              ),
              const SizedBox(height: 16),
              if (selected != null)
                Text(
                  'روز انتخاب‌شده: ${selected!.day} ${names[selected!.month - 1]} ${selected!.year}',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
