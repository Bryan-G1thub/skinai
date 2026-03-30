import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {};

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'How would you describe your skin type?',
      options: ['Oily', 'Dry', 'Combination', 'Normal', 'Sensitive'],
    ),
    QuizQuestion(
      question: 'What is your primary skin concern?',
      options: ['Acne', 'Aging', 'Dark spots', 'Redness', 'Dullness'],
    ),
    QuizQuestion(
      question: 'How often do you experience breakouts?',
      options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
    ),
    QuizQuestion(
      question: 'What is your current skincare routine?',
      options: ['Minimal', 'Basic', 'Moderate', 'Extensive'],
    ),
    QuizQuestion(
      question: 'How much sun exposure do you get daily?',
      options: ['Very little', 'Some', 'Moderate', 'A lot'],
    ),
  ];

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      context.go('/photo-capture');
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentQuestionIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousQuestion,
              )
            : null,
        title: Text(
          'Skin Quiz',
          style: AppTextStyles.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 32),
              Text(
                question.question,
                style: AppTextStyles.displaySmall,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    final isSelected = selectedAnswer == option;

                    return _OptionCard(
                      text: option,
                      isSelected: isSelected,
                      onTap: () => _selectAnswer(option),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAnswer != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    disabledBackgroundColor: AppColors.surfaceVariant,
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? 'Continue'
                        : 'Next Step',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;

  QuizQuestion({
    required this.question,
    required this.options,
  });
}
