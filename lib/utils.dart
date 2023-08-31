import 'dart:collection';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';

Dio dio = Dio();

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

Future<LinkedHashMap<DateTime, List<Event>>> fetchEventsFromAPI() async {
  Dio dio = Dio();
  final response = await dio
      .get('https://calendar-dev.dev-laravel.co/api/calendar/member/1');

  if (response.statusCode == 200) {
    LinkedHashMap<DateTime, List<Event>> eventsMap =
        LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    // 根據你的 API 返回的數據格式來解析 JSON。
    // 假設你的數據是 { "2023-09-01": ["Event 1", "Event 2"], ... }
    Map<String, dynamic> data = response.data;
    data.forEach((key, value) {
      DateTime date = DateTime.parse(key);
      List<Event> events =
          (value as List).map((e) => Event(e.toString())).toList();
      eventsMap[date] = events;
    });

    return eventsMap;
  } else {
    throw Exception('Failed to load events from the API');
  }
}

/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
