import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:arb_excel_converter/arb_excel.dart';

const _kVersion = '0.1.0';

void main(List<String> args) {
  final parse = ArgParser();
  parse.addOption('arb',
      abbr: 'a', valueHelp: 'path to Excel file', help: 'Export Excel file to ARB');
  parse.addOption('excel',
      abbr: 'e', valueHelp: 'path to ARB file', help: 'Import ARB file to sheet');
  final flags = parse.parse(args);

  // Not enough args
  if (args.isEmpty) {
    usage(parse);
    exit(1);
  }

  if (flags['arb'] != null) {
    final excelPath = flags['arb'] as String;
    stdout.writeln('Generate ARB from: $excelPath');
    final data = parseExcel(filename: excelPath);
    writeARB('${withoutExtension(excelPath)}.arb', data);
    exit(0);
  }

  if (flags['excel'] != null) {
    final arbFile = flags['excel'] as String;
    stdout.writeln('Generate Excel from: $arbFile');
    final data = parseARB(arbFile);
    writeExcel('${withoutExtension(arbFile)}.xlsx', data);
    exit(0);
  }
}

void usage(ArgParser parse) {
  stdout.writeln('arb_sheet_converter v$_kVersion\n');
  stdout.writeln('USAGE:');
  stdout.writeln(parse.usage);
}
