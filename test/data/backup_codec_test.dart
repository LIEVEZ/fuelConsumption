import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';

void main() {
  test('decode reports malformed json with a readable error', () {
    expect(
      () => BackupCodec().decode('not json'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('JSON 格式不正确'),
        ),
      ),
    );
  });

  test('decode reports missing required fields', () {
    expect(
      () => BackupCodec().decode('{"schemaVersion":1}'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('备份缺少字段: exportedAt'),
        ),
      ),
    );
  });

  test('decode requires object root', () {
    expect(
      () => BackupCodec().decode('[]'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('JSON 根节点必须是对象'),
        ),
      ),
    );
  });
}
