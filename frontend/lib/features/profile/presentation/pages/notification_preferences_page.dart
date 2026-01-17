import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  // Push Notifications
  bool _pushEnabled = true;
  bool _reportUpdates = true;
  bool _newThreats = true;
  bool _securityAlerts = true;
  bool _weeklyDigest = false;

  // Email Notifications
  bool _emailEnabled = true;
  bool _emailReportUpdates = true;
  bool _emailNewsletter = false;
  bool _emailSecurityAlerts = true;

  // In-App Notifications
  bool _inAppEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications Section
            _buildSectionHeader(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              enabled: _pushEnabled,
              onToggle: (value) => setState(() => _pushEnabled = value),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNotificationTile(
                icon: Icons.description_outlined,
                title: 'Report Updates',
                subtitle: 'Get notified when your reports are updated',
                value: _reportUpdates && _pushEnabled,
                enabled: _pushEnabled,
                onChanged: (value) => setState(() => _reportUpdates = value),
              ),
              _buildDivider(),
              _buildNotificationTile(
                icon: Icons.warning_amber_outlined,
                title: 'New Threat Alerts',
                subtitle: 'Receive alerts about new cyber threats',
                value: _newThreats && _pushEnabled,
                enabled: _pushEnabled,
                onChanged: (value) => setState(() => _newThreats = value),
              ),
              _buildDivider(),
              _buildNotificationTile(
                icon: Icons.security_outlined,
                title: 'Security Alerts',
                subtitle: 'Critical security notifications',
                value: _securityAlerts && _pushEnabled,
                enabled: _pushEnabled,
                onChanged: (value) => setState(() => _securityAlerts = value),
              ),
              _buildDivider(),
              _buildNotificationTile(
                icon: Icons.calendar_today_outlined,
                title: 'Weekly Digest',
                subtitle: 'Summary of weekly cyber activity',
                value: _weeklyDigest && _pushEnabled,
                enabled: _pushEnabled,
                onChanged: (value) => setState(() => _weeklyDigest = value),
              ),
            ]),
            const SizedBox(height: 24),

            // Email Notifications Section
            _buildSectionHeader(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              enabled: _emailEnabled,
              onToggle: (value) => setState(() => _emailEnabled = value),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNotificationTile(
                icon: Icons.update_outlined,
                title: 'Report Status Updates',
                subtitle: 'Email updates on report progress',
                value: _emailReportUpdates && _emailEnabled,
                enabled: _emailEnabled,
                onChanged: (value) =>
                    setState(() => _emailReportUpdates = value),
              ),
              _buildDivider(),
              _buildNotificationTile(
                icon: Icons.newspaper_outlined,
                title: 'Newsletter',
                subtitle: 'Monthly cybersecurity news and tips',
                value: _emailNewsletter && _emailEnabled,
                enabled: _emailEnabled,
                onChanged: (value) => setState(() => _emailNewsletter = value),
              ),
              _buildDivider(),
              _buildNotificationTile(
                icon: Icons.gpp_maybe_outlined,
                title: 'Security Alerts',
                subtitle: 'Important security notifications via email',
                value: _emailSecurityAlerts && _emailEnabled,
                enabled: _emailEnabled,
                onChanged: (value) =>
                    setState(() => _emailSecurityAlerts = value),
              ),
            ]),
            const SizedBox(height: 24),

            // In-App Notifications Section
            _buildSectionHeader(
              icon: Icons.phone_android_outlined,
              title: 'In-App Notifications',
              enabled: _inAppEnabled,
              onToggle: (value) => setState(() => _inAppEnabled = value),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNotificationTile(
                icon: Icons.volume_up_outlined,
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                value: _soundEnabled && _inAppEnabled,
                enabled: _inAppEnabled,
                onChanged: (value) => setState(() => _soundEnabled = value),
              ),
              _buildDivider(),
              _buildNotificationTile(
                icon: Icons.vibration_outlined,
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                value: _vibrationEnabled && _inAppEnabled,
                enabled: _inAppEnabled,
                onChanged: (value) => setState(() => _vibrationEnabled = value),
              ),
            ]),
            const SizedBox(height: 24),

            // Quick Actions
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.notifications_off_outlined,
                title: 'Mute All Notifications',
                subtitle: 'Temporarily disable all notifications',
                onTap: () => _showMuteDialog(),
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.restore_outlined,
                title: 'Reset to Defaults',
                subtitle: 'Restore default notification settings',
                onTap: () => _resetToDefaults(),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool enabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Switch(
          value: enabled,
          onChanged: onToggle,
          activeColor: const Color(0xFF3B82F6),
          activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.3),
          inactiveThumbColor: Colors.white.withOpacity(0.5),
          inactiveTrackColor: Colors.white.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.6),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E3A5F),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: const Color(0xFF3B82F6),
              activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.3),
              inactiveThumbColor: Colors.white.withOpacity(0.5),
              inactiveTrackColor: Colors.white.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  void _showMuteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Mute Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMuteOption('1 hour'),
            _buildMuteOption('8 hours'),
            _buildMuteOption('24 hours'),
            _buildMuteOption('Until I turn it back on'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuteOption(String duration) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        duration,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications muted for $duration'),
            backgroundColor: const Color(0xFF3B82F6),
          ),
        );
      },
    );
  }

  void _resetToDefaults() {
    setState(() {
      _pushEnabled = true;
      _reportUpdates = true;
      _newThreats = true;
      _securityAlerts = true;
      _weeklyDigest = false;
      _emailEnabled = true;
      _emailReportUpdates = true;
      _emailNewsletter = false;
      _emailSecurityAlerts = true;
      _inAppEnabled = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings reset to defaults'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}
