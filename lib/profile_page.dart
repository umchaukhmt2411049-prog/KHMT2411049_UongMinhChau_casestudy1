import 'package:flutter/material.dart';
import 'app_bottom_navigation.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'transactions_page.dart';

const Color _blue = Color(0xFF1677F2);
const Color _ink = Color(0xFF102447);
const Color _muted = Color(0xFF6E83A3);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title (chức năng có thể bổ sung sau).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          children: [
            const Text(
              'Cá nhân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _ink,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFBBD8FF), Color(0xFF8DBBFA)],
                    ),
                  ),
                  child: const Icon(Icons.person, size: 43, color: Colors.white),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'nguyenvana@example.com',
                        style: TextStyle(fontSize: 10, color: _muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0EAF7)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                children: [
                  _ProfileItem(
                    icon: Icons.person,
                    title: 'Thông tin cá nhân',
                    onTap: () => _showMessage(context, 'Thông tin cá nhân'),
                  ),
                  _ProfileItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Cài đặt ngân sách',
                    onTap: () => _showMessage(context, 'Cài đặt ngân sách'),
                  ),
                  _ProfileItem(
                    icon: Icons.settings,
                    title: 'Cài đặt',
                    onTap: () => _showMessage(context, 'Cài đặt'),
                  ),
                  _ProfileItem(
                    icon: Icons.help,
                    title: 'Trợ giúp',
                    onTap: () => _showMessage(context, 'Trợ giúp'),
                  ),
                  _ProfileItem(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    isLogout: true,
                    showDivider: false,
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Đăng xuất?'),
                          content: const Text('Bạn có muốn đăng xuất không?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) async {
          if (index == 3) return;
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
          } else if (index == 2) {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            );
          }
        },
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;
  final bool showDivider;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isLogout ? const Color(0xFFFF405D) : const Color(0xFF667F9E);
    final titleColor = isLogout ? const Color(0xFFFF405D) : _ink;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 43,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(icon, size: 17, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 11, color: titleColor),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8DA1BC)),
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: 12,
              endIndent: 12,
              color: Color(0xFFEAF0F8),
            ),
        ],
      ),
    );
  }
}
