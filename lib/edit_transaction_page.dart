import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class EditTransactionPage extends StatefulWidget {
  final int transactionId;

  const EditTransactionPage({
    super.key,
    required this.transactionId,
  });

  @override
  State<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState
    extends State<EditTransactionPage> {
  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController dateController =
  TextEditingController();

  final TextEditingController noteController =
  TextEditingController();

  String selectedType = 'expense';
  String selectedCategory = 'Ăn uống';

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadTransaction();
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // ==================================================
  // ĐỌC GIAO DỊCH CẦN SỬA
  // ==================================================
  Future<void> loadTransaction() async {
    final transaction =
    await DatabaseHelper.instance.getTransaction(
      widget.transactionId,
    );

    if (!mounted) return;

    if (transaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy giao dịch'),
        ),
      );

      Navigator.pop(context);
      return;
    }

    setState(() {
      selectedType =
          transaction['type']?.toString() ?? 'expense';

      selectedCategory =
          transaction['category']?.toString() ??
              'Ăn uống';

      amountController.text =
          transaction['amount']?.toString() ?? '';

      dateController.text =
          transaction['date']?.toString() ?? '';

      noteController.text =
          transaction['note']?.toString() ?? '';

      isLoading = false;
    });
  }

  // ==================================================
  // LƯU THAY ĐỔI
  // ==================================================
  Future<void> updateTransaction() async {
    final amount =
    double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập số tiền hợp lệ',
          ),
        ),
      );
      return;
    }

    if (dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    await DatabaseHelper.instance.updateTransaction(
      widget.transactionId,
      {
        'type': selectedType,
        'category': selectedCategory,
        'amount': amount,
        'date': dateController.text.trim(),
        'note': noteController.text.trim(),
      },
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật giao dịch'),
      ),
    );

    Navigator.pop(context, true);
  }

  // ==================================================
  // BUILD
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa giao dịch'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==================================================
            // LOẠI GIAO DỊCH
            // ==================================================
            const Text(
              'Loại giao dịch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                // CHI
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType =
                        'expense';
                      });
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color:
                        selectedType ==
                            'expense'
                            ? Colors.red
                            : Colors
                            .grey
                            .shade200,
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Text(
                        'Chi tiêu',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          color:
                          selectedType ==
                              'expense'
                              ? Colors.white
                              : Colors.black,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // THU
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType =
                        'income';
                      });
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color:
                        selectedType ==
                            'income'
                            ? Colors.green
                            : Colors
                            .grey
                            .shade200,
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Text(
                        'Thu nhập',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          color:
                          selectedType ==
                              'income'
                              ? Colors.white
                              : Colors.black,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // DANH MỤC
            // ==================================================
            const Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child:
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'Ăn uống',
                      child: Text('Ăn uống'),
                    ),
                    DropdownMenuItem(
                      value: 'Di chuyển',
                      child: Text('Di chuyển'),
                    ),
                    DropdownMenuItem(
                      value: 'Mua sắm',
                      child: Text('Mua sắm'),
                    ),
                    DropdownMenuItem(
                      value: 'Học tập',
                      child: Text('Học tập'),
                    ),
                    DropdownMenuItem(
                      value: 'Giải trí',
                      child: Text('Giải trí'),
                    ),
                    DropdownMenuItem(
                      value: 'Khác',
                      child: Text('Khác'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory =
                            value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SỐ TIỀN
            // ==================================================
            const Text(
              'Số tiền',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // NGÀY
            // ==================================================
            const Text(
              'Ngày',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Chọn ngày',
                suffixIcon: const Icon(
                  Icons.calendar_today,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
              onTap: () async {
                DateTime initialDate =
                DateTime.now();

                final currentText =
                dateController.text.trim();

                final parts =
                currentText.split('/');

                if (parts.length == 3) {
                  final day =
                  int.tryParse(parts[0]);

                  final month =
                  int.tryParse(parts[1]);

                  final year =
                  int.tryParse(parts[2]);

                  if (day != null &&
                      month != null &&
                      year != null) {
                    initialDate = DateTime(
                      year,
                      month,
                      day,
                    );
                  }
                }

                final pickedDate =
                await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate:
                  DateTime(2020),
                  lastDate:
                  DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() {
                    dateController.text =
                    '${pickedDate.day.toString().padLeft(2, '0')}/'
                        '${pickedDate.month.toString().padLeft(2, '0')}/'
                        '${pickedDate.year}';
                  });
                }
              },
            ),

            const SizedBox(height: 25),

            // ==================================================
            // GHI CHÚ
            // ==================================================
            const Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // NÚT CẬP NHẬT
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : updateTransaction,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.blue,
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Cập nhật giao dịch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}