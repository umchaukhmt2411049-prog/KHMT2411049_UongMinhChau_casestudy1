import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'database/database_helper.dart';
import 'add_transaction_page.dart';
import 'edit_transaction_page.dart';
import 'filter_page.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';

const Color _blue = Color(0xFF1677F2);
const Color _ink = Color(0xFF102447);
const Color _muted = Color(0xFF6E83A3);
const Color _pageBg = Color(0xFFF8FBFF);

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController =
  TextEditingController();

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  String _selectedType = 'all';
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ĐỌC GIAO DỊCH TỪ SQLITE
  Future<void> _loadTransactions() async {
    try {
      final data =
      await DatabaseHelper.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tải được giao dịch: $e'),
        ),
      );
    }
  }

  // ĐỊNH DẠNG TIỀN
  String _text(dynamic value) => value?.toString() ?? '';

  String _money(double amount) {
    final raw = amount.round().toString();
    final buffer = StringBuffer();
    var count = 0;

    for (var i = raw.length - 1; i >= 0; i--) {
      buffer.write(raw[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join();
  }

  // ICON THEO DANH MỤC
  IconData _categoryIcon(
      String category, {
        required bool isIncome,
      }) {
    if (isIncome) return Icons.account_balance_wallet;

    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Di chuyển':
      case 'Đi lại':
        return Icons.directions_car;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Học tập':
      case 'Giáo dục':
        return Icons.menu_book;
      case 'Giải trí':
        return Icons.movie;
      default:
        return Icons.attach_money;
    }
  }

  // MÀU ICON THEO DANH MỤC
  Color _categoryColor(
      String category, {
        required bool isIncome,
      }) {
    if (isIncome) return const Color(0xFF27C47D);

    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF536B);
      case 'Di chuyển':
      case 'Đi lại':
        return const Color(0xFF8561F5);
      case 'Mua sắm':
        return const Color(0xFF00A7E8);
      case 'Học tập':
      case 'Giáo dục':
        return const Color(0xFF9B59F6);
      case 'Giải trí':
        return const Color(0xFF8561F5);
      default:
        return const Color(0xFF98A5B5);
    }
  }

  // KIỂM TRA DANH MỤC ĐƯỢC CHỌN
  bool _categoryMatches(
      String actual,
      List<String> selected,
      ) {
    if (selected.isEmpty) return true;

    for (final category in selected) {
      if (category == actual) return true;

      if ((category == 'Đi lại' && actual == 'Di chuyển') ||
          (category == 'Di chuyển' && actual == 'Đi lại')) {
        return true;
      }
    }

    return false;
  }

  // DANH SÁCH ĐÃ QUA TÌM KIẾM VÀ LỌC
  List<Map<String, dynamic>> get _visibleTransactions {
    final keyword =
    _searchController.text.trim().toLowerCase();

    return _transactions.where((transaction) {
      final type = _text(transaction['type']);
      final category = _text(transaction['category']);
      final note = _text(transaction['note']);
      final date = _text(transaction['date']);
      final amount = _text(transaction['amount']);

      final typeMatches =
          _selectedType == 'all' ||
              type == _selectedType;

      final categoryMatches =
      _categoryMatches(
        category,
        _selectedCategories,
      );

      final keywordMatches = keyword.isEmpty ||
          note.toLowerCase().contains(keyword) ||
          category.toLowerCase().contains(keyword) ||
          date.toLowerCase().contains(keyword) ||
          amount.contains(keyword);

      return typeMatches &&
          categoryMatches &&
          keywordMatches;
    }).toList();
  }

  // MỞ MÀN HÌNH BỘ LỌC
  Future<void> _openFilter() async {
    final result =
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterPage(
          initialType: _selectedType,
          initialCategories: _selectedCategories,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _selectedType =
          result['type']?.toString() ?? 'all';

      _selectedCategories =
          (result['categories'] as List<dynamic>? ?? [])
              .map((value) => value.toString())
              .toList();
    });
  }

  // MỞ MÀN HÌNH SỬA
  Future<void> _openEdit(
      Map<String, dynamic> transaction,
      ) async {
    final id = (transaction['id'] as num?)?.toInt();

    if (id == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionPage(
          transactionId: id,
        ),
      ),
    );

    if (result == true) {
      await _loadTransactions();
    }
  }

  // XÓA GIAO DỊCH
  Future<void> _deleteTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final id = (transaction['id'] as num?)?.toInt();

    if (id == null) return;

    final title = _text(transaction['note']).trim().isEmpty
        ? _text(transaction['category'])
        : _text(transaction['note']);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: Text(
          'Bạn có chắc muốn xóa "$title" không?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await DatabaseHelper.instance.deleteTransaction(id);
    await _loadTransactions();
  }

  // ĐIỀU HƯỚNG MENU DƯỚI
  Future<void> _navigateTab(int index) async {
    if (index == 1) return;

    // Khi trở về Trang chủ, pop route hiện tại để quay về đúng Home
    // đang giữ trong stack; Home sẽ tự tải lại dữ liệu khi màn hình này đóng.
    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
      return;
    }

    final Widget page = index == 2
        ? const StatisticsPage()
        : const ProfilePage();

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTransactions;

    return Scaffold(
      backgroundColor: _pageBg,

      // TIÊU ĐỀ
      appBar: AppBar(
        backgroundColor: _pageBg,
        foregroundColor: _ink,
        elevation: 0,
        toolbarHeight: 48,
        titleSpacing: 16,
        title: const Text(
          'Giao dịch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _ink,
          ),
        ),
      ),

      // NỘI DUNG
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: _blue,
          ),
        )
            : RefreshIndicator(
          onRefresh: _loadTransactions,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              12,
            ),
            children: [
              // TÌM KIẾM + BỘ LỌC
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _ink,
                        ),
                        decoration: InputDecoration(
                          hintText:
                          'Tìm kiếm giao dịch...',
                          hintStyle: const TextStyle(
                            fontSize: 11,
                            color: _muted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 17,
                            color: _muted,
                          ),
                          prefixIconConstraints:
                          const BoxConstraints(
                            minWidth: 34,
                          ),
                          suffixIcon:
                          _searchController.text.isEmpty
                              ? null
                              : IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.close,
                              size: 15,
                            ),
                            onPressed:
                            _searchController.clear,
                          ),
                          filled: true,
                          fillColor:
                          const Color(0xFFF0F5FC),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Material(
                      color: const Color(0xFFF0F5FC),
                      borderRadius:
                      BorderRadius.circular(9),
                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(9),
                        onTap: _openFilter,
                        child: const Icon(
                          Icons.filter_list_rounded,
                          size: 19,
                          color: _muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // TẤT CẢ / THU / CHI
              Row(
                children: [
                  _typeChip('Tất cả', 'all'),
                  const SizedBox(width: 7),
                  _typeChip('Thu nhập', 'income'),
                  const SizedBox(width: 7),
                  _typeChip('Chi tiêu', 'expense'),
                ],
              ),

              if (_selectedCategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt_outlined,
                        size: 13,
                        color: _muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Đã lọc ${_selectedCategories.length} danh mục',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _muted,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategories = [];
                          _selectedType = 'all';
                        }),
                        child: const Text(
                          'Xóa lọc',
                          style: TextStyle(
                            fontSize: 10,
                            color: _blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // DANH SÁCH GIAO DỊCH
              if (visible.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 39,
                        color: Color(0xFF9AAEC5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _transactions.isEmpty
                            ? 'Chưa có giao dịch nào'
                            : 'Không tìm thấy giao dịch phù hợp',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: List.generate(
                      visible.length,
                          (index) {
                        final transaction =
                        visible[index];

                        return _transactionTile(
                          transaction,
                          last: index ==
                              visible.length - 1,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // MENU DƯỚI
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onTap: _navigateTab,
      ),
    );
  }

  // NÚT CHỌN LOẠI GIAO DỊCH
  Widget _typeChip(
      String label,
      String value,
      ) {
    final selected = _selectedType == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(
              () => _selectedType = value,
        ),
        child: Container(
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _blue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? _blue
                  : const Color(0xFFDCE7F5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: selected ? Colors.white : _ink,
            ),
          ),
        ),
      ),
    );
  }

  // MỘT DÒNG GIAO DỊCH
  Widget _transactionTile(
      Map<String, dynamic> transaction, {
        required bool last,
      }) {
    final type = _text(transaction['type']);

    final category =
    _text(transaction['category']).isEmpty
        ? 'Khác'
        : _text(transaction['category']);

    final note = _text(transaction['note']);
    final date = _text(transaction['date']);

    final amount =
        (transaction['amount'] as num?)?.toDouble() ?? 0;

    final isIncome = type == 'income';

    final title =
    note.trim().isEmpty ? category : note;

    return InkWell(
      onTap: () => _openEdit(transaction),
      onLongPress: () => _deleteTransaction(transaction),
      child: Container(
        constraints: const BoxConstraints(minHeight: 49),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
            bottom: BorderSide(
              color: Color(0xFFEAF0F8),
            ),
          ),
        ),
        child: Row(
          children: [
            // ICON DANH MỤC
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: _categoryColor(
                  category,
                  isIncome: isIncome,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(
                  category,
                  isIncome: isIncome,
                ),
                color: Colors.white,
                size: 15,
              ),
            ),

            const SizedBox(width: 9),

            // TÊN + NGÀY
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            // SỐ TIỀN
            Text(
              '${isIncome ? '+' : '-'}${_money(amount)} đ',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isIncome
                    ? const Color(0xFF20AD68)
                    : const Color(0xFFFF405D),
              ),
            ),

            const SizedBox(width: 2),

            const Icon(
              Icons.chevron_right,
              size: 14,
              color: Color(0xFF94A7C0),
            ),
          ],
        ),
      ),
    );
  }
}

// THANH MENU DƯỚI CỦA MÀN HÌNH GIAO DỊCH
