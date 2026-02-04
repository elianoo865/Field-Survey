import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Formatters {
  static String ts(Timestamp? t) {
    if (t == null) return '-';
    try {
      return DateFormat('yyyy/MM/dd  HH:mm').format(t.toDate());
    } catch (_) {
      return t.toDate().toIso8601String();
    }
  }

  static String boolAr(bool v, {String yes = 'نعم', String no = 'لا'}) => v ? yes : no;
}
