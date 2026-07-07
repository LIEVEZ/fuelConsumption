import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('layer boundaries', () {
    test('domain stays framework and infrastructure free', () {
      _expectNoImports(
        rootPath: 'lib/src/domain',
        forbiddenFragments: const [
          'package:flutter',
          'package:flutter_riverpod',
          'package:drift',
          'src/application',
          'src/data',
          'src/presentation',
          'src/screens',
          'src/widgets',
        ],
      );
    });

    test('application stays framework and data free', () {
      _expectNoImports(
        rootPath: 'lib/src/application',
        forbiddenFragments: const [
          'package:flutter',
          'package:flutter_riverpod',
          'package:drift',
          'src/data',
          'src/presentation',
          'src/screens',
          'src/widgets',
        ],
      );
    });

    test('data mappers do not reuse backup json serializers', () {
      _expectNoImports(
        rootPath: 'lib/src/data',
        forbiddenFragments: const [
          'src/application/backup/backup_serializers.dart',
        ],
      );
    });

    test('widgets do not depend on screens', () {
      _expectNoImports(
        rootPath: 'lib/src/widgets',
        forbiddenFragments: const ['src/screens'],
      );
    });

    test('ui layers do not depend on data implementations', () {
      for (final rootPath in const [
        'lib/src/presentation',
        'lib/src/screens',
        'lib/src/widgets',
      ]) {
        _expectNoImports(
          rootPath: rootPath,
          forbiddenFragments: const [
            'package:drift',
            'package:sqlite',
            'src/data',
          ],
        );
      }
    });
  });
}

void _expectNoImports({
  required String rootPath,
  required List<String> forbiddenFragments,
}) {
  final violations = <String>[];
  for (final file in _dartFiles(rootPath)) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (!line.startsWith('import ')) continue;
      for (final fragment in forbiddenFragments) {
        if (line.contains(fragment)) {
          violations.add('${file.path}:${index + 1}: $line');
        }
      }
    }
  }

  expect(violations, isEmpty, reason: violations.join('\n'));
}

Iterable<File> _dartFiles(String rootPath) {
  return Directory(rootPath)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
