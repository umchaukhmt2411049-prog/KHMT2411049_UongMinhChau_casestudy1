import 'package:flutter/material.dart';
import 'add_transaction_page.dart';
import 'edit_transaction_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, size: 28),
                  const SizedBox(width: 18),
                  const Expanded(
                    child: Text(
                      'Quản lý thu chi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none, size: 29),
                      Positioned(
                        right: -2,
                        top: -3,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
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
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D88F8), Color(0xFF1764E8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: const [
                        Text(
                          'SỐ DƯ HIỆN TẠI  👁',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '5.000.000 đ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 31,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      right: 5,
                      bottom: 15,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          '━ • • •',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: summaryCard(
                      title: 'TỔNG THU NHẬP',
                      money: '8.000.000 đ',
                      backgroundColor: const Color(0xFFEAF8EC),
                      iconColor: const Color(0xFF69C879),
                      icon: Icons.arrow_downward,
                      moneyColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: summaryCard(
                      title: 'TỔNG CHI TIÊU',
                      money: '3.000.000 đ',
                      backgroundColor: const Color(0xFFFFEBED),
                      iconColor: const Color(0xFFFF7075),
                      icon: Icons.arrow_upward,
                      moneyColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    transactionItem(context, Icons.restaurant, Colors.orange, 'Ăn trưa', 'Ăn uống', '03/09/2024', '-50.000 đ', Colors.red),
                    transactionItem(context, Icons.directions_car, Colors.blue, 'Xăng xe', 'Di chuyển', '03/09/2024', '-100.000 đ', Colors.red),
                    transactionItem(context, Icons.attach_money, Colors.green, 'Lương tháng 9', 'Thu nhập', '01/09/2024', '+8.000.000 đ', Colors.green),
                    transactionItem(context, Icons.shopping_cart, Colors.purple, 'Mua sắm', 'Mua sắm', '31/08/2024', '-300.000 đ', Colors.red),
                    transactionItem(context, Icons.school, Colors.teal, 'Học phí', 'Giáo dục', '30/08/2024', '-500.000 đ', Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2878E8),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: const BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2878E8),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Thống kê'),
        ],
      ),
    );
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  money,
                  style: TextStyle(
                    fontSize: 12,
                    color: moneyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionItem(
      BuildContext context,
      IconData icon,
      Color iconColor,
      String title,
      String category,
      String date,
      String money,
      Color moneyColor,
      ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                money,
                style: TextStyle(
                  fontSize: 11,
                  color: moneyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditTransactionPage(),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
          ),
        ],
      ),
    );
  }
}
