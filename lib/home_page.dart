import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'add_transaction_page.dart';
import 'edit_transaction_page.dart';
import 'database/database_helper.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import 'transactions_page.dart';
import 'app_route_observer.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;

  List<Map<String, dynamic>> transactions = [];

  bool isLoading = true;
  PageRoute<dynamic>? _subscribedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      _subscribedRoute = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Khi quay lại Home, đồng bộ lại tổng thu, tổng chi, số dư và danh sách.
    loadData();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Chỉ hiện loading ở lần mở Home đầu tiên
    loadData(showLoading: true);
  }

  // ==================================================
  // ĐỌC SQLITE - CHỈ ĐỌC 1 LẦN
  // ==================================================
  Future<void> loadData({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      // Chỉ cần đọc danh sách giao dịch 1 lần
      final data =
      await DatabaseHelper.instance.getTransactions();

      double income = 0;
      double expense = 0;

      // Tính tổng thu / chi ngay trong Flutter
      for (final transaction in data) {
        final type =
            transaction['type']?.toString() ?? 'expense';

        final amount =
            (transaction['amount'] as num?)?.toDouble() ?? 0;

        if (type == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      if (!mounted) return;

      setState(() {
        transactions = data;
        totalIncome = income;
        totalExpense = expense;
        balance = income - expense;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đọc dữ liệu: $e'),
        ),
      );
    }
  }

  // ==================================================
  // ĐỊNH DẠNG TIỀN
  // ==================================================
  String formatMoney(double money) {
    final value = money.round().toString();

    final buffer = StringBuffer();
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join();
  }

  // ==================================================
  // ICON THEO DANH MỤC
  // ==================================================
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;

      case 'Di chuyển':
        return Icons.directions_car;

      case 'Mua sắm':
        return Icons.shopping_cart;

      case 'Học tập':
        return Icons.school;

      case 'Giải trí':
        return Icons.movie;

      default:
        return Icons.category;
    }
  }

  // ==================================================
  // MÀU ICON THEO DANH MỤC
  // ==================================================
  Color getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return Colors.orange;

      case 'Di chuyển':
        return Colors.blue;

      case 'Mua sắm':
        return Colors.purple;

      case 'Học tập':
        return Colors.teal;

      case 'Giải trí':
        return Colors.pink;

      default:
        return Colors.grey;
    }
  }

  // ==================================================
  // BUILD
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      // ==================================================
      // NỘI DUNG
      // ==================================================
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              90,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // THANH TRÊN
                // ==================================================
                Row(
                  children: [
                    const Icon(
                      Icons.menu,
                      size: 27,
                      color: Color(0xFF202632),
                    ),

                    const SizedBox(width: 18),

                    const Expanded(
                      child: Text(
                        'Quản lý thu chi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                          color: Color(0xFF202632),
                        ),
                      ),
                    ),

                    Stack(
                      clipBehavior:
                      Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          size: 29,
                          color: Color(0xFF202632),
                        ),

                        Positioned(
                          right: -2,
                          top: -3,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration:
                            const BoxDecoration(
                              color: Colors.red,
                              shape:
                              BoxShape.circle,
                            ),
                            child:
                            const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // THẺ SỐ DƯ
                // ==================================================
                Container(
                  width: double.infinity,
                  height: 150,
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(18),
                    gradient:
                    const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4D88F8),
                        Color(0xFF1764E8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Center(
                            child: Text(
                              'SỐ DƯ HIỆN TẠI  👁',
                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize: 12,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Center(
                            child: Text(
                              '${formatMoney(balance)} đ',
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 31,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Ví
                      Positioned(
                        right: 3,
                        bottom: 16,
                        child: SizedBox(
                          width: 70,
                          height: 62,
                          child: Stack(
                            clipBehavior:
                            Clip.none,
                            children: [
                              // Tờ tiền
                              Positioned(
                                top: 0,
                                left: 13,
                                child:
                                Container(
                                  width: 35,
                                  height: 22,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                      0xFF71C983,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      4,
                                    ),
                                  ),
                                ),
                              ),

                              // Ví
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child:
                                Container(
                                  width: 62,
                                  height: 47,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                      0xFF2B83E8,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 0,
                                        top: 14,
                                        child:
                                        Container(
                                          width: 27,
                                          height: 25,
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            const Color(
                                              0xFF155AB7,
                                            ),
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              7,
                                            ),
                                          ),
                                          child:
                                          const Center(
                                            child:
                                            CircleAvatar(
                                              radius:
                                              4,
                                              backgroundColor:
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Đồng xu
                              Positioned(
                                left: 2,
                                bottom: -3,
                                child:
                                Container(
                                  width: 19,
                                  height: 19,
                                  decoration:
                                  const BoxDecoration(
                                    color:
                                    Color(
                                      0xFFFFC93D,
                                    ),
                                    shape:
                                    BoxShape
                                        .circle,
                                  ),
                                  child:
                                  const Icon(
                                    Icons
                                        .attach_money,
                                    color: Colors
                                        .orange,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Chỉ báo
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            '━ • • •',
                            style: TextStyle(
                              color:
                              Colors.white,
                              fontSize: 14,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // THU NHẬP / CHI TIÊU
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: summaryCard(
                        title:
                        'TỔNG THU NHẬP',
                        money:
                        '${formatMoney(totalIncome)} đ',
                        backgroundColor:
                        const Color(
                          0xFFEAF8EC,
                        ),
                        iconColor:
                        const Color(
                          0xFF69C879,
                        ),
                        icon: Icons
                            .arrow_downward,
                        moneyColor:
                        Colors.green,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: summaryCard(
                        title:
                        'TỔNG CHI TIÊU',
                        money:
                        '${formatMoney(totalExpense)} đ',
                        backgroundColor:
                        const Color(
                          0xFFFFEBED,
                        ),
                        iconColor:
                        const Color(
                          0xFFFF7075,
                        ),
                        icon:
                        Icons.arrow_upward,
                        moneyColor:
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ==================================================
                // GIAO DỊCH GẦN ĐÂY
                // ==================================================
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: [
                    const Text(
                      'Giao dịch gần đây',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                        color: Color(
                          0xFF202632,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsPage(),
                          ),
                        );
                        await loadData();
                      },
                      child: Text(
                        'Xem tất cả (${transactions.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2878E8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // DANH SÁCH GIAO DỊCH
                // ==================================================
                Container(
                  width: double.infinity,
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: transactions.isEmpty
                      ? const Padding(
                    padding:
                    EdgeInsets.all(
                      30,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons
                                .receipt_long,
                            size: 45,
                            color:
                            Colors.grey,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Chưa có giao dịch nào',
                            style:
                            TextStyle(
                              color: Colors
                                  .grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Column(
                    children:
                    transactions
                        .take(5)
                        .map(
                          (
                          transaction,
                          ) =>
                          transactionItem(
                            context,
                            transaction,
                          ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ==================================================
      // NÚT +
      // ==================================================
      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {
          final result =
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const AddTransactionPage(),
            ),
          );

          // Cập nhật dữ liệu nhưng không hiện
          // loading toàn màn hình
          if (result == true) {
            await loadData();
          }
        },
        backgroundColor:
        const Color(0xFF2878E8),
        elevation: 5,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),

      // ==================================================
      // MENU DƯỚI
      // ==================================================
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) async {
          if (index == 0) return;

          if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionsPage(),
              ),
            );
            await loadData();
          } else if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatisticsPage(),
              ),
            );
            await loadData();
          } else if (index == 3) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },
      ),
    );
  }

  // Ô THU NHẬP / CHI TIÊU
  // ==================================================
  Widget summaryCard({
    required String title,
    required String money,
    required Color backgroundColor,
    required Color iconColor,
    required IconData icon,
    required Color moneyColor,
  }) {
    return Container(
      height: 76,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: iconColor,
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  money,
                  style: TextStyle(
                    fontSize: 12,
                    color: moneyColor,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // ITEM GIAO DỊCH
  // ==================================================
  Widget transactionItem(
      BuildContext context,
      Map<String, dynamic> transaction,
      ) {
    final String type =
        transaction['type']?.toString() ??
            'expense';

    final String category =
        transaction['category']?.toString() ??
            'Khác';

    final String note =
        transaction['note']?.toString() ?? '';

    final String date =
        transaction['date']?.toString() ?? '';

    final double amount =
        (transaction['amount'] as num?)
            ?.toDouble() ??
            0;

    final bool isIncome =
        type == 'income';

    final String title =
    note.trim().isEmpty
        ? category
        : note;

    final String money =
        '${isIncome ? '+' : '-'}'
        '${formatMoney(amount)} đ';

    return Container(
      height: 72,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // ==================================================
          // ICON
          // ==================================================
          CircleAvatar(
            radius: 18,
            backgroundColor:
            getCategoryColor(category),
            child: Icon(
              isIncome
                  ? Icons.attach_money
                  : getCategoryIcon(
                category,
              ),
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          // ==================================================
          // TÊN + DANH MỤC
          // ==================================================
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.bold,
                    color: Color(
                      0xFF202632,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  category,
                  style:
                  const TextStyle(
                    fontSize: 11,
                    color:
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // NGÀY + TIỀN
          // ==================================================
          Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style:
                const TextStyle(
                  fontSize: 9,
                  color:
                  Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                money,
                style: TextStyle(
                  fontSize: 11,
                  color: isIncome
                      ? Colors.green
                      : Colors.red,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          // ==================================================
          // NÚT SỬA
          // ==================================================
          IconButton(
            onPressed: () async {
              final transactionId =
              (transaction['id']
              as num)
                  .toInt();

              final result =
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditTransactionPage(
                        transactionId:
                        transactionId,
                      ),
                ),
              );

              // Sau khi sửa xong:
              // đọc lại SQLite và cập nhật Home
              if (result == true) {
                await loadData();
              }
            },
            icon: const Icon(
              Icons.edit,
              size: 17,
              color:
              Color(0xFF1687F2),
            ),
            tooltip: 'Sửa',
          ),
        ],
      ),
    );
  }
}
