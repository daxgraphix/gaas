import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _getNotifications(ThemeData theme) => [
    {
      'id': '1',
      'category': 'Achievements',
      'title': 'STREAK_SYNC_ACTIVE',
      'message': 'Neural link maintained for 5 days. Continue session?',
      'time': '2h_AGO',
      'icon': Icons.bolt,
      'color': theme.colorScheme.primary,
      'isRead': false,
      'action': 'View Streak',
      'priority': 'high',
    },
    {
      'id': '2',
      'category': 'Achievements',
      'title': 'ACHIEVEMENT_UNLOCKED',
      'message': 'Protocol "Star Collector" has been successfully initialized.',
      'time': '1d_AGO',
      'icon': Icons.military_tech,
      'color': theme.colorScheme.secondary,
      'isRead': false,
      'action': 'View Achievement',
      'priority': 'high',
    },
    {
      'id': '3',
      'category': 'Missions',
      'title': 'DAILY_MISSION_DEPLOYED',
      'message': 'Three new logic nodes available for processing.',
      'time': '2d_AGO',
      'icon': Icons.terminal,
      'color': theme.colorScheme.tertiary,
      'isRead': true,
      'action': 'Start Mission',
      'priority': 'medium',
    },
    {
      'id': '4',
      'category': 'System',
      'title': 'SYSTEM_UPGRADE',
      'message': 'Level 10 clearance granted. New sectors unlocked.',
      'time': '3d_AGO',
      'icon': Icons.security,
      'color': theme.colorScheme.primary,
      'isRead': true,
      'action': 'View Progress',
    },
    {
      'id': '5',
      'category': 'Rewards',
      'title': 'POINTS_BONUS',
      'message': 'Daily login bonus: +500 points awarded.',
      'time': '5h_AGO',
      'icon': Icons.star,
      'color': theme.colorScheme.secondary,
      'isRead': false,
      'action': 'Collect Bonus',
      'priority': 'medium',
    },
    {
      'id': '6',
      'category': 'Performance',
      'title': 'SPEED_IMPROVEMENT',
      'message': 'Response time improved by 15%. Keep up the great work!',
      'time': '1h_AGO',
      'icon': Icons.speed,
      'color': theme.colorScheme.primary,
      'isRead': true,
      'action': 'View Changelog',
      'priority': 'low',
    },
    {
      'id': '10',
      'category': 'Achievements',
      'title': 'STREAK_MASTER',
      'message': '7-day streak achieved! You\'re unstoppable!',
      'time': '4h_AGO',
      'icon': Icons.local_fire_department,
      'color': theme.colorScheme.error,
      'isRead': false,
      'action': 'Celebrate',
      'priority': 'high',
    },
  ];

  final List<String> _categories = ['All', 'Achievements', 'Missions', 'System', 'Rewards', 'Performance', 'Social'];

  List<Map<String, dynamic>> _getFilteredNotifications(List<Map<String, dynamic>> notifications) {
    if (_selectedCategory == 'All') return notifications;
    return notifications.where((n) => n['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications = _getNotifications(theme);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white70),
        ),
        title: const Text(
          'COMM_CENTER_V1',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 4,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
            color: Color(0xFF00FFFF),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusLine(notifications, theme),
            _buildCategoryFilter(theme),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _getFilteredNotifications(notifications).length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(_getFilteredNotifications(notifications)[index], theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.05),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusLine(List<Map<String, dynamic>> notifications, ThemeData theme) {
    final unreadCount = notifications.where((n) => !n['isRead']).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'UNREAD_MESSAGES: $unreadCount',
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => setState(() {
                for (var n in notifications) {
                  n['isRead'] = true;
                }
              }),
              child: const Text(
                '[ PURGE_ALL ]',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF00FFFF),
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item, ThemeData theme) {
    final bool isRead = item['isRead'];
    final Color color = item['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : theme.colorScheme.surface.withValues(alpha: 0.02),
        border: Border.all(
          color: isRead ? theme.colorScheme.outline.withValues(alpha: 0.1) : color.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (!isRead)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 2,
              child: Container(color: color),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item['icon'], color: isRead ? theme.colorScheme.onSurface.withValues(alpha: 0.15) : color, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: isRead ? theme.colorScheme.onSurface.withValues(alpha: 0.3) : theme.colorScheme.onPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            item['time'],
                            style: TextStyle(
                              fontSize: 8,
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['message'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isRead ? theme.colorScheme.onSurface.withValues(alpha: 0.15) : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (item['action'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Action: ${item['action']}')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: color.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                            child: Text(
                              item['action'],
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
