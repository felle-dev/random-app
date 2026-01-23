import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingTimerPage extends StatefulWidget {
  const ReadingTimerPage({super.key});

  @override
  State<ReadingTimerPage> createState() => _ReadingTimerPageState();
}

class _ReadingTimerPageState extends State<ReadingTimerPage> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  int _totalPagesRead = 0;
  int _todayMinutes = 0;
  int _totalSessions = 0;
  String _lastSessionDate = '';

  // Settings
  int _targetMinutes = 30;
  int _reminderInterval = 60;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if it's a new day
      final today = DateTime.now().toString().split(' ')[0];
      final lastDate = prefs.getString('reading_last_date') ?? '';

      setState(() {
        _totalPagesRead = prefs.getInt('reading_total_pages') ?? 0;
        _totalSessions = prefs.getInt('reading_total_sessions') ?? 0;
        _targetMinutes = prefs.getInt('reading_target_minutes') ?? 30;
        _reminderInterval = prefs.getInt('reading_reminder_interval') ?? 60;
        _lastSessionDate = lastDate;

        // Reset daily stats if it's a new day
        if (lastDate != today) {
          _todayMinutes = 0;
        } else {
          _todayMinutes = prefs.getInt('reading_today_minutes') ?? 0;
        }
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().split(' ')[0];

      await prefs.setInt('reading_total_pages', _totalPagesRead);
      await prefs.setInt('reading_total_sessions', _totalSessions);
      await prefs.setInt('reading_today_minutes', _todayMinutes);
      await prefs.setInt('reading_target_minutes', _targetMinutes);
      await prefs.setInt('reading_reminder_interval', _reminderInterval);
      await prefs.setString('reading_last_date', today);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> _resetStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reading_total_pages');
      await prefs.remove('reading_total_sessions');
      await prefs.remove('reading_today_minutes');
      await prefs.remove('reading_last_date');

      setState(() {
        _totalPagesRead = 0;
        _totalSessions = 0;
        _todayMinutes = 0;
        _lastSessionDate = '';
      });
    } catch (e) {
      debugPrint('Error resetting stats: $e');
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;

        // Check for reminder interval (show snackbar)
        if (_elapsedSeconds > 0 &&
            _elapsedSeconds % (_reminderInterval * 60) == 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You\'ve been reading for ${_elapsedSeconds ~/ 60} minutes! 📚',
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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

  void _endSession() {
    if (_elapsedSeconds < 60) {
      // Session too short, just reset
      _resetTimer();
      return;
    }

    _pauseTimer();
    _showEndSessionDialog();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _elapsedSeconds = 0;
    });
  }

  void _showEndSessionDialog() {
    int currentPages = 0;
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('End Reading Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Duration: ${_formatTime(_elapsedSeconds)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pages Read (Optional)',
                hintText: 'Enter number of pages',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
              onChanged: (value) {
                currentPages = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final minutes = _elapsedSeconds ~/ 60;
              setState(() {
                _totalPagesRead += currentPages;
                _todayMinutes += minutes;
                _totalSessions++;
              });

              await _saveData();

              if (mounted) {
                Navigator.pop(context);
                _resetTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Reading session saved! 🎉${currentPages > 0 ? " ($currentPages pages)" : ""}',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    int tempTarget = _targetMinutes;
    int tempReminder = _reminderInterval;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Timer Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSettingSlider('Daily Goal', tempTarget, 10, 180, (
                    value,
                  ) {
                    setDialogState(() {
                      tempTarget = value;
                    });
                  }, suffix: 'min'),
                  const SizedBox(height: 16),
                  _buildSettingSlider(
                    'Reminder Interval',
                    tempReminder,
                    15,
                    120,
                    (value) {
                      setDialogState(() {
                        tempReminder = value;
                      });
                    },
                    suffix: 'min',
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
                onPressed: () async {
                  setState(() {
                    _targetMinutes = tempTarget;
                    _reminderInterval = tempReminder;
                  });
                  await _saveData();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStatsDialog() {
    final avgPagesPerSession = _totalSessions > 0
        ? (_totalPagesRead / _totalSessions).toStringAsFixed(1)
        : '0';
    final avgMinutesPerSession = _totalSessions > 0
        ? ((_todayMinutes + (_elapsedSeconds ~/ 60)) / _totalSessions)
              .toStringAsFixed(1)
        : '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Sessions', '$_totalSessions'),
            const SizedBox(height: 12),
            _buildStatRow('Total Pages', '$_totalPagesRead'),
            const SizedBox(height: 12),
            _buildStatRow('Total Minutes', '$_todayMinutes'),
            const SizedBox(height: 12),
            _buildStatRow('Avg. Pages/Session', avgPagesPerSession),
            const SizedBox(height: 12),
            _buildStatRow('Avg. Minutes/Session', avgMinutesPerSession),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Statistics'),
                  content: const Text(
                    'Are you sure you want to reset all your reading statistics? This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _resetStats();
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset Stats'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSettingSlider(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value $suffix',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min) ~/ 5,
          label: '$value',
          onChanged: (newValue) {
            onChanged(newValue.round());
          },
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _todayMinutes / _targetMinutes;
    final progressClamped = progress > 1.0 ? 1.0 : progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: _showStatsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Status Indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _isRunning
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isRunning ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  _isRunning ? 'READING IN PROGRESS' : 'READY TO READ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isRunning ? Colors.blue : Colors.grey,
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
                          value: progressClamped,
                          strokeWidth: 12,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 64,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRunning
                                ? 'Keep reading...'
                                : 'Start your session',
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

              // Daily Progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$_todayMinutes / $_targetMinutes min',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: progress >= 1.0
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_totalPagesRead > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.book_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_totalPagesRead pages read',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filled(
                    onPressed: _elapsedSeconds > 0 ? _resetTimer : null,
                    icon: const Icon(Icons.refresh),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      disabledBackgroundColor: theme.colorScheme.surfaceVariant
                          .withOpacity(0.3),
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),

                  // End Session Button
                  IconButton.filled(
                    onPressed: _elapsedSeconds > 0 ? _endSession : null,
                    icon: const Icon(Icons.check),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      disabledBackgroundColor: theme.colorScheme.surfaceVariant
                          .withOpacity(0.3),
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
