import '../models/settings_models.dart';

String formatFileSize(int bytes, AppSettings settings) {
  if (bytes < 0) {
    return '—';
  }

  final useBits = settings.baseUnit == SizeBaseUnit.bit;
  final value = useBits ? bytes * 8 : bytes;
  final binary = settings.unitSystem == SizeUnitSystem.binary;
  final divisor = binary ? 1024.0 : 1000.0;
  final byteLabels = binary
      ? const ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB']
      : const ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'];
  final bitLabels = binary
      ? const ['b', 'Kib', 'Mib', 'Gib', 'Tib', 'Pib', 'Eib']
      : const ['b', 'Kb', 'Mb', 'Gb', 'Tb', 'Pb', 'Eb'];
  final labels = useBits ? bitLabels : byteLabels;

  var scaled = value.toDouble();
  var unitIndex = 0;
  while (scaled >= divisor && unitIndex < labels.length - 1) {
    scaled /= divisor;
    unitIndex += 1;
  }

  final fractionDigits = unitIndex == 0
      ? 0
      : scaled >= 100
      ? 0
      : scaled >= 10
      ? 1
      : 2;
  final number = scaled.toStringAsFixed(fractionDigits);
  return '$number ${labels[unitIndex]}';
}

String sizeUnitDescription(AppSettings settings) {
  final binary = settings.unitSystem == SizeUnitSystem.binary;
  final bits = settings.baseUnit == SizeBaseUnit.bit;
  if (bits) {
    return binary ? 'IEC · 1024 进制 · bit' : 'SI · 1000 进制 · bit';
  }
  return binary ? 'IEC · 1024 进制 · Byte' : 'SI · 1000 进制 · Byte';
}
