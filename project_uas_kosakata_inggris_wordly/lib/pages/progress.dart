import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/quiz_history.dart';
import '../database/database_helper_quiz.dart';

class ProgressPage extends StatefulWidget {
  final User currentUser;
  const ProgressPage({super.key, required this.currentUser});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<QuizHistory> _userQuizHistories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserQuizHistories();
  }

  Future<void> _loadUserQuizHistories() async {
    try {
      final histories = await DatabaseHelper().getQuizHistories(widget.currentUser.userId);
      setState(() {
        _userQuizHistories = histories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading quiz histories: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat riwayat quiz.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kemajuan Quiz'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userQuizHistories.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada data kemajuan.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Ayo mulai kerjakan quiz!', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      )
          : _buildHistoryGrid(),
    );
  }

  Widget _buildHistoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 160,
          ),
          itemCount: _userQuizHistories.length,
          itemBuilder: (context, index) {
            final history = _userQuizHistories[index];
            final tanggal = history.date.toLocal().toString().split('.')[0];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showDetailDialog(history),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. Level ${history.level} (${history.partOfSpeech})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('Skor: ${history.score}/${history.totalQuestions}'),
                      const SizedBox(height: 6),
                      Text('Tanggal: $tanggal'),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          history.score == history.totalQuestions ? Icons.star : Icons.check_circle,
                          color: history.score == history.totalQuestions ? Colors.amber : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailDialog(QuizHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Riwayat Quiz'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: ${history.date.toLocal().toString().split('.')[0]}'),
                Text('Level: ${history.level} (${history.partOfSpeech})'),
                Text('Skor: ${history.score}/${history.totalQuestions}'),
                const SizedBox(height: 12),
                const Text('Pertanyaan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (history.questions.isNotEmpty)
                  ...history.questions.map((q) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${q.definition}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('   Jawaban: ${q.word}', style: const TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                  ))
                else
                  const Text('Detail pertanyaan tidak tersedia.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
