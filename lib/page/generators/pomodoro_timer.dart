import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes default
  bool _isRunning = false;
  bool _isWorkSession = true;
  int _completedPomodoros = 0;

  // Settings
  int _workDuration = 25; // minutes
  int _shortBreakDuration = 5; // minutes
  int _longBreakDuration = 15; // minutes
  int _pomodorosUntilLongBreak = 4;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _remainingSeconds = _isWorkSession
          ? _workDuration * 60
          : (_completedPomodoros % _pomodorosUntilLongBreak == 0 &&
                _completedPomodoros > 0)
          ? _longBreakDuration * 60
          : _shortBreakDuration * 60;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_isWorkSession) {
        _completedPomodoros++;
        _isWorkSession = false;
        // Determine break type
        if (_completedPomodoros % _pomodorosUntilLongBreak == 0) {
          _remainingSeconds = _longBreakDuration * 60;
        } else {
          _remainingSeconds = _shortBreakDuration * 60;
        }
      } else {
        _isWorkSession = true;
        _remainingSeconds = _workDuration * 60;
      }
    });

    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _isWorkSession ? 'Break Complete!' : 'Work Session Complete!',
        ),
        content: Text(
          _isWorkSession
              ? 'Time to focus! Start your work session.'
              : _completedPomodoros % _pomodorosUntilLongBreak == 0
              ? 'Great work! Time for a long break.'
              : 'Good job! Time for a short break.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text('Start'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    int tempWork = _workDuration;
    int tempShortBreak = _shortBreakDuration;
    int tempLongBreak = _longBreakDuration;
    int tempPomodorosUntilLong = _pomodorosUntilLongBreak;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingSlider(
                'Work Duration',
                tempWork,
                1,
                60,
                (value) => tempWork = value,
              ),
              const SizedBox(height: 16),
              _buildSettingSlider(
                'Short Break',
                tempShortBreak,
                1,
                30,
                (value) => tempShortBreak = value,
              ),
              const SizedBox(height: 16),
              _buildSettingSlider(
                'Long Break',
                tempLongBreak,
                5,
                60,
                (value) => tempLongBreak = value,
              ),
              const SizedBox(height: 16),
              _buildSettingSlider(
                'Pomodoros Until Long Break',
                tempPomodorosUntilLong,
                2,
                10,
                (value) => tempPomodorosUntilLong = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _workDuration = tempWork;
                _shortBreakDuration = tempShortBreak;
                _longBreakDuration = tempLongBreak;
                _pomodorosUntilLongBreak = tempPomodorosUntilLong;
                _resetTimer();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSlider(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return StatefulBuilder(
      builder: (context, setSliderState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: $value min',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: '$value',
              onChanged: (newValue) {
                setSliderState(() {
                  onChanged(newValue.round());
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _isWorkSession
        ? 1 - (_remainingSeconds / (_workDuration * 60))
        : 1 -
              (_remainingSeconds /
                  ((_completedPomodoros % _pomodorosUntilLongBreak == 0 &&
                          _completedPomodoros > 0)
                      ? _longBreakDuration * 60
                      : _shortBreakDuration * 60));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings_outlined),
        //     onPressed: _showSettingsDialog,
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Session Type Indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _isWorkSession
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isWorkSession ? Colors.red : Colors.green,
                    width: 2,
                  ),
                ),
                child: Text(
                  _isWorkSession ? 'FOCUS TIME' : 'BREAK TIME',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isWorkSession ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Timer Circle
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isWorkSession ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 64,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isWorkSession ? 'Stay focused' : 'Take a rest',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filled(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Play/Pause Button
                  IconButton.filled(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    iconSize: 48,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(28),
                      backgroundColor: _isWorkSession
                          ? Colors.red
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Skip Button
                  IconButton.filled(
                    onPressed: () {
                      _timer?.cancel();
                      _onTimerComplete();
                    },
                    icon: const Icon(Icons.skip_next),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
