import 'package:flutter/material.dart';

const _blue = Color(0xFF1677F2);
const _ink = Color(0xFF102447);

class FilterPage extends StatefulWidget {
  final String initialType;
  final List<String> initialCategories;
  const FilterPage({super.key, this.initialType = 'all', this.initialCategories = const []});
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late String type;
  late Set<String> categories;
  static const names = ['Ăn uống', 'Mua sắm', 'Đi lại', 'Học tập', 'Khác'];

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    categories = widget.initialCategories.toSet();
  }

  IconData iconFor(String name) {
    switch (name) {
      case 'Ăn uống': return Icons.restaurant;
      case 'Mua sắm': return Icons.shopping_cart;
      case 'Đi lại': return Icons.directions_car;
      case 'Học tập': return Icons.menu_book;
      default: return Icons.category;
    }
  }

  Color colorFor(String name) {
    switch (name) {
      case 'Ăn uống': return const Color(0xFFFF536B);
      case 'Mua sắm': return const Color(0xFF00A7E8);
      case 'Đi lại': return const Color(0xFF25BF7A);
      case 'Học tập': return const Color(0xFF8561F5);
      default: return const Color(0xFF9B59F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(backgroundColor: const Color(0xFFF8FBFF), foregroundColor: _ink, elevation: 0, centerTitle: true,
        title: const Text('Bộ lọc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 18), children: [
        const Text('Loại giao dịch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ink)),
        const SizedBox(height: 5),
        _typeRow('Tất cả', 'all'),
        _typeRow('Thu nhập', 'income'),
        _typeRow('Chi tiêu', 'expense'),
        const SizedBox(height: 13),
        const Text('Danh mục', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ink)),
        const SizedBox(height: 7),
        Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE0EAF7)), borderRadius: BorderRadius.circular(10)),
          child: Column(children: names.map((name) {
            final checked = categories.contains(name);
            return InkWell(onTap: () => setState(() => checked ? categories.remove(name) : categories.add(name)),
              child: SizedBox(height: 31, child: Row(children: [
                const SizedBox(width: 9),
                Container(width: 19, height: 19, decoration: BoxDecoration(color: colorFor(name), borderRadius: BorderRadius.circular(5)), child: Icon(iconFor(name), size: 12, color: Colors.white)),
                const SizedBox(width: 9), Expanded(child: Text(name, style: const TextStyle(fontSize: 11, color: _ink))),
                SizedBox(width: 29, child: Checkbox(value: checked, onChanged: (v) => setState(() => v == true ? categories.add(name) : categories.remove(name)),
                  activeColor: _blue, side: const BorderSide(color: Color(0xFF8EA4C0)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact)),
                const SizedBox(width: 4)
              ])));
          }).toList())),
        const SizedBox(height: 18),
        SizedBox(height: 42, child: ElevatedButton(onPressed: () => Navigator.pop(context, {'type': type, 'categories': categories.toList()}),
          style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
          child: const Text('Áp dụng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
      ])),
    );
  }

  Widget _typeRow(String label, String value) => SizedBox(height: 26, child: InkWell(
    onTap: () => setState(() => type = value),
    child: Row(children: [
      SizedBox(width: 22, height: 24, child: Checkbox(value: type == value, onChanged: (v) { if (v == true) setState(() => type = value); },
        activeColor: _blue, side: const BorderSide(color: Color(0xFF8EA4C0)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact)),
      const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 11, color: _ink))
    ])));
}
