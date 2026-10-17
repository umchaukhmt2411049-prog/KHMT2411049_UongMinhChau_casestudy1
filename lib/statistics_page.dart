import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'database/database_helper.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'transactions_page.dart';

const Color _blue = Color(0xFF1677F2);
const Color _ink = Color(0xFF102447);
const Color _muted = Color(0xFF6E83A3);
const List<Color> _chartColors = [
  Color(0xFFFF405D),
  Color(0xFF1677F2),
  Color(0xFF24BD78),
  Color(0xFFFFB34D),
  Color(0xFF8064F7),
  Color(0xFF4A6FAE),
];

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedPeriod = 'Tháng này';
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();
      if (!mounted) return;
      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu thống kê: $e')),
      );
    }
  }

  DateTime? _parseTransactionDate(dynamic rawDate) {
    final raw = rawDate?.toString().trim() ?? '';
    if (raw.isEmpty) return null;

    // Hỗ trợ cả ngày dd/MM/yyyy đang dùng trong app và ngày ISO yyyy-MM-dd.
    final normalized = raw.replaceAll('-', '/');
    final parts = normalized.split('/');
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);
      if (first != null && second != null && third != null) {
        if (parts[0].length == 4) {
          return DateTime(first, second, third);
        }
        return DateTime(third, second, first);
      }
    }

    return DateTime.tryParse(raw);
  }

  bool _matchesSelectedPeriod(Map<String, dynamic> item) {
    final date = _parseTransactionDate(item['date']);
    // Nếu một bản ghi cũ có ngày không hợp lệ, không âm thầm loại khỏi số liệu.
    if (date == null) return true;

    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'Tháng này':
        return date.year == now.year && date.month == now.month;
      case 'Quý này':
        final currentQuarter = (now.month - 1) ~/ 3;
        final transactionQuarter = (date.month - 1) ~/ 3;
        return date.year == now.year && transactionQuarter == currentQuarter;
      case 'Năm nay':
        return date.year == now.year;
      default:
        return true;
    }
  }

  List<Map<String, dynamic>> get _periodTransactions =>
      transactions.where(_matchesSelectedPeriod).toList();

  double get totalExpense {
    return _periodTransactions
        .where((item) => item['type']?.toString() == 'expense')
        .fold<double>(
          0,
          (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0),
        );
  }

  Map<String, double> get expensesByCategory {
    final result = <String, double>{};
    for (final item in _periodTransactions) {
      if (item['type']?.toString() != 'expense') continue;
      final category = (item['category'] ?? 'Khác').toString();
      final amount = (item['amount'] as num?)?.toDouble() ?? 0;
      result[category] = (result[category] ?? 0) + amount;
    }
    return result;
  }

  String formatMoney(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    var count = 0;

    for (var i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return '${buffer.toString().split('').reversed.join()} đ';
  }

  @override
  Widget build(BuildContext context) {
    final entries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shownEntries = entries.take(6).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            children: [
              const Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: ['Tháng này', 'Quý này', 'Năm nay']
                    .map((period) {
                  final isSelected = selectedPeriod == period;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() => selectedPeriod = period);
                        },
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _blue
                                : const Color(0xFFEAF2FC),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : _ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 205,
                child: Center(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(170, 170),
                          painter: _DonutPainter(
                            shownEntries.map((entry) => entry.value).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatMoney(totalExpense),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Tổng chi tiêu',
                              style: TextStyle(
                                fontSize: 10,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (shownEntries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Chưa có dữ liệu chi tiêu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: _muted),
                  ),
                ),
              ...List.generate(shownEntries.length, (index) {
                final entry = shownEntries[index];
                final percent = totalExpense == 0
                    ? 0.0
                    : entry.value / totalExpense * 100;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _chartColors[index % _chartColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 11, color: _ink),
                        ),
                      ),
                      SizedBox(
                        width: 94,
                        child: Text(
                          formatMoney(entry.value),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 10, color: _ink),
                        ),
                      ),
                      SizedBox(
                        width: 42,
                        child: Text(
                          '${percent.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 10, color: _muted),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) async {
          if (index == 2) return;
          if (index == 0) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          } else if (index == 1) {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const TransactionsPage()),
            );
          } else if (index == 3) {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;

  _DonutPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;
    final rect = Offset.zero & size;

    if (total <= 0) {
      paint.color = const Color(0xFFE5EDF7);
      canvas.drawArc(rect.deflate(13), -math.pi / 2, math.pi * 2, false, paint);
      return;
    }

    var startAngle = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweepAngle = values[i] / total * math.pi * 2;
      paint.color = _chartColors[i % _chartColors.length];
      canvas.drawArc(rect.deflate(13), startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
