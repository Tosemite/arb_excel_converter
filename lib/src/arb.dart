import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

/// To match all args from a text.
final _kRegArgs = RegExp(r'{(\w+)}');

/// Parses .arb files to [Translation].
/// The [filename] is the main language.
Translation parseARB(String filename) {
  const metaSymbol = '@';
  final bytes = File(filename).readAsBytesSync();
  final body = Utf8Decoder().convert(bytes);
  final jsonBody = json.decode(body) as Map<String, dynamic>;
  final items = <ARBItem>[];
  final textKeys =
      jsonBody.keys.where((element) => !element.startsWith(metaSymbol));
  final language = withoutExtension(filename).split('_').last;
  for (final textKey in textKeys) {
    final text = jsonBody[textKey];
    if (text is! String) continue;
    String? description;
    String? category;
    final metadata = jsonBody[metaSymbol + textKey];
    if (metadata is Map<String, dynamic>) {
      description = metadata['description'];
      category = metadata['type'];
    }
    items.add(
      ARBItem(
        category: category,
        text: textKey,
        description: description,
        translations: {
          language: text,
        },
      ),
    );
  }
  return Translation(languages: [language], items: items);
}

/// Writes [Translation] to .arb files.
void writeARB(String filename, Translation data) {
  for (var i = 0; i < data.languages.length; i++) {
    final lang = data.languages[i];
    final isDefault = i == 0;
    final f = File('${withoutExtension(filename)}_$lang.arb');

    var buf = [];
    for (final item in data.items) {
      final data = item.toJSON(lang, isDefault);
      if (data != null) {
        buf.add(item.toJSON(lang, isDefault));
      }
    }

    buf = ['{', buf.join(',\n'), '}\n'];
    f.writeAsStringSync(buf.join('\n'));
  }
}

/// Describes an ARB record.
class ARBItem {
  static List<String> getArgs(String text) {
    final List<String> args = [];
    final matches = _kRegArgs.allMatches(text);
    for (final m in matches) {
      final arg = m.group(1);
      if (arg != null) {
        args.add(arg);
      }
    }

    return args;
  }

  ARBItem({
    this.category,
    required this.text,
    this.description,
    this.translations = const {},
  });

  final String? category;
  final String text;
  final String? description;
  final Map<String, String> translations;

  /// Serialize in JSON.
  String? toJSON(String lang, [bool isDefault = false]) {
    final value = translations[lang];
    if (value == null || value.isEmpty) return null;

    final args = getArgs(value);
    final hasMetadata = isDefault && (args.isNotEmpty || description != null);

    final List<String> buf = [];

    if (hasMetadata) {
      buf.add('  "$text": "${value.replaceAll('"', '\\"')}",');
      buf.add('  "@$text": {');
      if (description != null) {
        buf.add('    "description": "$description",');
      }
      if (category != null) {
        buf.add('    "type": "$category",');
      }
      if (args.isNotEmpty) {
        buf.add('    "placeholders": {');
        final List<String> group = [];
        for (final arg in args) {
          group.add('      "$arg": {}');
        }
        buf.add(group.join(',\n'));
        buf.add('    }');
      } else {
        buf.add('    "placeholders": {}');
      }

      buf.add('  }');
    } else {
      buf.add('  "$text": "$value"');
    }

    return buf.join('\n');
  }
}

/// Describes all arb records.
class Translation {
  Translation({this.languages = const [], this.items = const []});

  final List<String> languages;
  final List<ARBItem> items;
}
