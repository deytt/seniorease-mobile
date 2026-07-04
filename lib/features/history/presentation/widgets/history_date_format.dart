const _monthsPt = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

/// Rótulo do cabeçalho de um grupo diário: "Hoje", "Ontem" ou "12 de jun"
/// (acrescenta o ano quando é diferente do atual).
String historyDayLabel(DateTime day, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(day.year, day.month, day.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';

  final base = '${target.day} de ${_monthsPt[target.month - 1]}';
  return target.year == now.year ? base : '$base de ${target.year}';
}

/// Hora no formato 24h `HH:mm` (ex.: `08:05`).
String historyTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$hour:$min';
}
