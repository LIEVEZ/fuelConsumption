import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/legacy_refuel_note_parser.dart';

void main() {
  test('parses legacy refuel amount fields from note text', () {
    final amounts = LegacyRefuelNoteParser.parse(
      '油灯亮 · 机显金额 160.00 元 · 优惠 20.00 元 · 实付金额 140.00 元 · 92#汽油',
    );

    expect(amounts.machineAmount, 160);
    expect(amounts.paidAmount, 140);
    expect(amounts.discountAmount, 20);
  });

  test('derives missing machine amount from paid fallback and discount', () {
    final amounts = LegacyRefuelNoteParser.parse(
      '优惠 20.00 元 · 92#汽油',
      paidAmountFallback: 140,
    );

    expect(amounts.machineAmount, 160);
    expect(amounts.paidAmount, 140);
    expect(amounts.discountAmount, 20);
  });

  test('removes legacy amount parts from visible notes', () {
    final note = LegacyRefuelNoteParser.visibleNote(
      '油灯亮 · 机显单价 8.00 元/升 · 机显金额 160.00 元 · 优惠 20.00 元 · 实付金额 140.00 元 · 周末加油',
    );

    expect(note, '油灯亮 · 周末加油');
  });
}
