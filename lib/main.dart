import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BASDAI Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Увеличиваем все шрифты на 20%
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const BASDAICalculatorPage(),
    );
  }
}

// Виджет одного вопроса со слайдером (локальное состояние)
class QuestionSlider extends StatefulWidget {
  final String question;
  final String subtitle;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final IconData icon;

  const QuestionSlider({
    super.key,
    required this.question,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
    required this.icon,
  });

  @override
  State<QuestionSlider> createState() => _QuestionSliderState();
}

class _QuestionSliderState extends State<QuestionSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(QuestionSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _value = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            if (widget.subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  widget.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Expanded(
                  // НОВАЯ ТЕМА для слайдера
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,                              // толщина линии
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,                    // радиус кружочка (был 10)
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,                         // ореол при касании
                      ),
                      valueIndicatorTextStyle: const TextStyle(
                        fontSize: 14,               // увеличь по вкусу
                        color: Colors.white,
                      ),
                    ),
                    child: Slider(
                      value: _value,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _value.toInt().toString(),
                      onChanged: (newValue) {
                        setState(() {
                          _value = newValue;
                        });
                        widget.onChanged(newValue);
                      },
                      activeColor: Colors.blue,
                      thumbColor: Colors.blue,
                    ),
                  ),
                ),
                const Text('10', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _value.toInt().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
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

class BASDAICalculatorPage extends StatefulWidget {
  const BASDAICalculatorPage({super.key});

  @override
  State<BASDAICalculatorPage> createState() => _BASDAICalculatorPageState();
}

class _BASDAICalculatorPageState extends State<BASDAICalculatorPage> {
  double _fatigue = 0;
  double _spinalPain = 0;
  double _jointPain = 0;
  double _enthesitis = 0;
  double _morningStiffnessSeverity = 0;
  double _morningStiffnessDuration = 0;

  double _basdaiScore = 0;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _calculateBASDAI();
  }

  void _calculateBASDAI() {
    setState(() {
      double stiffnessAvg = (_morningStiffnessSeverity + _morningStiffnessDuration) / 2;
      _basdaiScore = (_fatigue + _spinalPain + _jointPain + _enthesitis + stiffnessAvg) / 5;
    });
  }

  void _onSliderChanged(double newValue, void Function(double) setter) {
    setter(newValue);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _calculateBASDAI();
    });
  }

  void _resetAll() {
    _debounceTimer?.cancel();
    setState(() {
      _fatigue = 0;
      _spinalPain = 0;
      _jointPain = 0;
      _enthesitis = 0;
      _morningStiffnessSeverity = 0;
      _morningStiffnessDuration = 0;
      _calculateBASDAI();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Все значения сброшены'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _getInterpretation(double score) {
    if (score == 0) return "Нет данных";
    if (score < 2) return "Низкая активность";
    if (score < 4) return "Умеренная активность";
    if (score < 6) return "Высокая активность";
    return "Очень высокая активность";
  }

  Color _getScoreColor(double score) {
    if (score == 0) return Colors.grey;
    if (score < 2) return Colors.green;
    if (score < 4) return Colors.orange;
    if (score < 6) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Определяем цвет активности (или серый при нуле)
    final scoreColor = _getScoreColor(_basdaiScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Калькулятор BASDAI',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: 'Сбросить все',
            onPressed: _resetAll,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Заголовок – оставим лёгкую карточку с elevation для отделения, можно тоже убрать при желании
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Индекс активности спондилоартрита',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BASDAI (Bath Ankylosing Spondylitis Disease Activity Index)',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Слайдеры вопросов
            QuestionSlider(
              question: '1. Уровень усталости / истощения',
              subtitle: 'за последнюю неделю',
              initialValue: _fatigue,
              icon: Icons.energy_savings_leaf,
              onChanged: (v) => _onSliderChanged(v, (val) => _fatigue = val),
            ),
            QuestionSlider(
              question: '2. Боль в позвоночнике',
              subtitle: 'шея, спина, бедра за последнюю неделю',
              initialValue: _spinalPain,
              icon: Icons.healing,
              onChanged: (v) => _onSliderChanged(v, (val) => _spinalPain = val),
            ),
            QuestionSlider(
              question: '3. Боль / припухлость в других суставах',
              subtitle: 'колени, плечи, пятки за последнюю неделю',
              initialValue: _jointPain,
              icon: Icons.accessibility_new,
              onChanged: (v) => _onSliderChanged(v, (val) => _jointPain = val),
            ),
            QuestionSlider(
              question: '4. Дискомфорт в местах прикрепления связок',
              subtitle: 'энтезиты за последнюю неделю',
              initialValue: _enthesitis,
              icon: Icons.timeline,
              onChanged: (v) => _onSliderChanged(v, (val) => _enthesitis = val),
            ),
            QuestionSlider(
              question: '5. Выраженность утренней скованности',
              subtitle: 'после пробуждения',
              initialValue: _morningStiffnessSeverity,
              icon: Icons.wb_sunny,
              onChanged: (v) => _onSliderChanged(v, (val) => _morningStiffnessSeverity = val),
            ),
            QuestionSlider(
              question: '6. Длительность утренней скованности',
              subtitle: 'от 0 (0 мин) до 10 (2+ часа)',
              initialValue: _morningStiffnessDuration,
              icon: Icons.timer,
              onChanged: (v) => _onSliderChanged(v, (val) => _morningStiffnessDuration = val),
            ),

            const SizedBox(height: 32),

            // Результат – ПЛОСКИЙ ДИЗАЙН, без объема, фиксированная высота
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                // Легкая граница вместо тени
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              child: Column(
                children: [
                  // Заголовок
                  Text(
                    'РЕЗУЛЬТАТ BASDAI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Большое число
                  Text(
                    _basdaiScore.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Интерпретация — всегда на одном месте
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),  // чтоб на узких экранах не упиралось в край
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: scoreColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _getInterpretation(_basdaiScore),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Справочная подпись
                  Text(
                    'BASDAI > 4 — высокая активность заболевания',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}