import 'package:flutter/material.dart';
import 'dart:math';

class SpinningWheelPage extends StatefulWidget {
  const SpinningWheelPage({super.key});

  @override
  State<SpinningWheelPage> createState() => _SpinningWheelPageState();
}

class _SpinningWheelPageState extends State<SpinningWheelPage>
    with SingleTickerProviderStateMixin {
  final List<String> _options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
  ];
  final TextEditingController _optionsController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSpinning = false;
  String? _result;
  double _currentRotation = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 15000),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _currentRotation = _animation.value % (2 * pi);
        });
      }
    });

    _optionsController.text = _options.join('\n');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _updateOptions() {
    final newOptions = _optionsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (newOptions.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Need at least 2 options')));
      return;
    }

    setState(() {
      _options.clear();
      _options.addAll(newOptions);
      _isEditing = false;
    });
  }

  void _spinWheel() {
    if (_isSpinning || _options.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    final random = Random();
    final spins = 5 + random.nextDouble() * 3;
    final extraRotation = random.nextDouble() * 2 * pi;
    final endRotation = _currentRotation + (spins * 2 * pi) + extraRotation;

    _animation = Tween<double>(begin: _currentRotation, end: endRotation)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart,
          ),
        );

    _animationController.forward(from: 0).then((_) {
      final normalizedRotation = endRotation % (2 * pi);
      final sectionAngle = (2 * pi) / _options.length;
      final selectedIndex =
          ((2 * pi - normalizedRotation) / sectionAngle).floor() %
          _options.length;
      setState(() {
        _result = _options[selectedIndex];
      });

      _showResultDialog(_options[selectedIndex]);
    });
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Winner!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _spinWheel();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Spin Again'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _removeOptionByName(result);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeOptionByName(String optionName) {
    if (_options.length <= 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Need at least 2 options')));
      return;
    }

    setState(() {
      _options.remove(optionName);
      _optionsController.text = _options.join('\n');
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "$optionName" from wheel')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Spinning Wheel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Wheel Section
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Arrow indicator
                  CustomPaint(
                    size: const Size(40, 40),
                    painter: ArrowPainter(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 10),
                  // Wheel
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _isSpinning
                              ? _animation.value
                              : _currentRotation,
                          child: CustomPaint(
                            size: const Size(300, 300),
                            painter: WheelPainter(
                              options: _options,
                              colors: _generateColors(_options.length),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Spin Button
          FilledButton.icon(
            onPressed: _isSpinning ? null : _spinWheel,
            icon: const Icon(Icons.refresh),
            label: Text(_isSpinning ? 'Spinning...' : 'Spin the Wheel'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Options Section
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Options',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) {
                              _optionsController.text = _options.join('\n');
                            }
                          });
                        },
                        icon: Icon(_isEditing ? Icons.close : Icons.edit),
                        label: Text(_isEditing ? 'Cancel' : 'Edit'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _isEditing
                      ? Column(
                          children: [
                            TextField(
                              controller: _optionsController,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                hintText: 'Enter options (one per line)',
                                border: OutlineInputBorder(),
                                helperText:
                                    'Each line will be one option on the wheel',
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _updateOptions,
                                icon: const Icon(Icons.check),
                                label: const Text('Save Options'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current options (${_options.length}):',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._options.asMap().entries.map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _generateColors(
                                          _options.length,
                                        )[index],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  List<Color> _generateColors(int count) {
    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      final hue = (i * 360 / count) % 360;
      colors.add(HSLColor.fromAHSL(1, hue, 0.7, 0.6).toColor());
    }
    return colors;
  }
}

class WheelPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  WheelPainter({required this.options, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = (2 * pi) / options.length;

    for (int i = 0; i < options.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final startAngle = i * sectionAngle - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ArrowPainter extends CustomPainter {
  final Color color;

  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
