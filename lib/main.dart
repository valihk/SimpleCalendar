import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: CalendarPage()));

class CalendarPage extends StatefulWidget {
 const CalendarPage({super.key});
 @override State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
 Jalali month = Jalali.now();
 Jalali? selected = Jalali.now();
 static const names = ['فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور','مهر','آبان','آذر','دی','بهمن','اسفند'];
 String key(Jalali d) => '${d.year}-${d.month}-${d.day}';
 @override Widget build(BuildContext context) {
  final first = Jalali(month.year, month.month, 1);
  final offset = first.weekDay - 1;
  final count = ((offset + month.monthLength + 6) ~/ 7) * 7;
  final today = Jalali.now();
  return Scaffold(appBar: AppBar(title: const Text('تقویم ساده'), centerTitle: true), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: () => setState(() => month = Jalali(month.year, month.month, 1).addMonths(-1)), icon: const Icon(Icons.chevron_left)), Text('${names[month.month-1]} ${month.year}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), IconButton(onPressed: () => setState(() => month = Jalali(month.year, month.month, 1).addMonths(1)), icon: const Icon(Icons.chevron_right))]),
   Row(children: ['ش','ی','د','س','چ','پ','ج'].map((x) => Expanded(child: Center(child: Text(x)))).toList()),
   const SizedBox(height: 10),
   GridView.builder(shrinkWrap: true, itemCount: count, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7), itemBuilder: (context, i) { final n = i-offset+1; if (n < 1 || n > month.monthLength) return const SizedBox.shrink(); final d = Jalali(month.year, month.month, n); final active = selected != null && key(d) == key(selected!); final isToday = key(d) == key(today); return InkWell(onTap: () => setState(() => selected = d), child: Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(color: active ? Colors.indigo : (isToday ? Colors.indigo.shade100 : null), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('$n', style: TextStyle(color: active ? Colors.white : Colors.black))))); }),
   const SizedBox(height: 16),
   Text(selected == null ? '' : 'روز انتخاب‌شده: ${selected!.day} ${names[selected!.month-1]} ${selected!.year}')
  ])));
 }
}
