import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = false;
  bool _pinEnabled = true;
  bool _twoFactorEnabled = false;
  bool _loginAlerts = true;
  bool _rememberDevice = true;
  String _autoLock = '5 minutes';

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
          'Security',
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
            // Security Score Card
            _buildSecurityScoreCard(),
            const SizedBox(height: 24),

            // Authentication Methods
            _buildSectionTitle('Authentication'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID to login',
                value: _biometricEnabled,
                onChanged: (value) => _toggleBiometric(value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.pin_outlined,
                title: 'PIN Code',
                subtitle: 'Use a 6-digit PIN to secure your account',
                value: _pinEnabled,
                onChanged: (value) => setState(() => _pinEnabled = value),
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.password_outlined,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordDialog(),
              ),
            ]),
            const SizedBox(height: 24),

            // Two-Factor Authentication
            _buildSectionTitle('Two-Factor Authentication'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.security_outlined,
                title: 'Enable 2FA',
                subtitle: 'Add extra security with authenticator app',
                value: _twoFactorEnabled,
                onChanged: (value) => _toggle2FA(value),
              ),
              if (_twoFactorEnabled) ...[
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.qr_code_outlined,
                  title: 'View Recovery Codes',
                  subtitle: 'Backup codes for account recovery',
                  onTap: () => _showRecoveryCodes(),
                ),
              ],
            ]),
            const SizedBox(height: 24),

            // Session Security
            _buildSectionTitle('Session Security'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.timer_outlined,
                title: 'Auto-Lock',
                subtitle: 'Lock app after inactivity',
                value: _autoLock,
                options: [
                  '1 minute',
                  '5 minutes',
                  '15 minutes',
                  '30 minutes',
                  'Never'
                ],
                onChanged: (value) => setState(() => _autoLock = value!),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.devices_outlined,
                title: 'Remember This Device',
                subtitle: 'Skip verification on this device',
                value: _rememberDevice,
                onChanged: (value) => setState(() => _rememberDevice = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Login Alerts',
                subtitle: 'Get notified of new login attempts',
                value: _loginAlerts,
                onChanged: (value) => setState(() => _loginAlerts = value),
              ),
            ]),
            const SizedBox(height: 24),

            // Device Management
            _buildSectionTitle('Device Management'),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.smartphone_outlined,
                title: 'Active Sessions',
                subtitle: 'Manage devices logged into your account',
                onTap: () => _showActiveSessionsDialog(),
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.logout,
                title: 'Sign Out All Devices',
                subtitle: 'End all sessions except this one',
                iconColor: const Color(0xFFEF4444),
                onTap: () => _showSignOutAllDialog(),
              ),
            ]),
            const SizedBox(height: 24),

            // Activity Log
            _buildSectionTitle('Recent Activity'),
            const SizedBox(height: 12),
            _buildActivityLog(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    int score = 0;
    if (_pinEnabled) score += 25;
    if (_biometricEnabled) score += 25;
    if (_twoFactorEnabled) score += 30;
    if (_loginAlerts) score += 20;

    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = const Color(0xFF10B981);
      scoreLabel = 'Excellent';
    } else if (score >= 50) {
      scoreColor = const Color(0xFFF59E0B);
      scoreLabel = 'Good';
    } else {
      scoreColor = const Color(0xFFEF4444);
      scoreLabel = 'Needs Improvement';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.2),
            const Color(0xFF1E3A5F).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scoreLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score < 100
                      ? 'Enable more security features to improve'
                      : 'Your account is fully secured',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.5),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF3B82F6),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: iconColor == const Color(0xFFEF4444)
                          ? const Color(0xFFEF4444)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E3A5F)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                items: options.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                dropdownColor: const Color(0xFF1E3A5F),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog() {
    final activities = [
      _ActivityItem(
        icon: Icons.login,
        title: 'Login from Windows PC',
        subtitle: 'Chrome • New York, USA',
        time: '2 hours ago',
        color: const Color(0xFF10B981),
      ),
      _ActivityItem(
        icon: Icons.password,
        title: 'Password Changed',
        subtitle: 'Security update',
        time: '3 days ago',
        color: const Color(0xFF3B82F6),
      ),
      _ActivityItem(
        icon: Icons.security,
        title: '2FA Enabled',
        subtitle: 'Authenticator app added',
        time: '1 week ago',
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        children: activities.map((activity) {
          final isLast = activity == activities.last;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        activity.icon,
                        color: activity.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      activity.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) _buildDivider(),
            ],
          );
        }).toList(),
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

  void _toggleBiometric(bool value) async {
    if (value) {
      // Simulate biometric authentication
      HapticFeedback.mediumImpact();
      setState(() => _biometricEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric login enabled'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      setState(() => _biometricEnabled = false);
    }
  }

  void _toggle2FA(bool value) {
    if (value) {
      _showSetup2FADialog();
    } else {
      _showDisable2FADialog();
    }
  }

  void _showSetup2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enable Two-Factor Authentication',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code,
                  size: 120, color: Color(0xFF0A1628)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan this QR code with your authenticator app',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorEnabled = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication enabled'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDisable2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Disable 2FA?',
          style:
              TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will make your account less secure. Are you sure you want to disable two-factor authentication?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorEnabled = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Disable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecoveryCodes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Recovery Codes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Save these codes in a safe place. Each code can only be used once.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text('XXXX-XXXX-XXXX',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'monospace')),
                  SizedBox(height: 8),
                  Text('XXXX-XXXX-XXXX',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'monospace')),
                  SizedBox(height: 8),
                  Text('XXXX-XXXX-XXXX',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'monospace')),
                  SizedBox(height: 8),
                  Text('XXXX-XXXX-XXXX',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(
                  text:
                      'XXXX-XXXX-XXXX\nXXXX-XXXX-XXXX\nXXXX-XXXX-XXXX\nXXXX-XXXX-XXXX'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Codes copied to clipboard'),
                    backgroundColor: Color(0xFF3B82F6)),
              );
            },
            child:
                const Text('Copy', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPasswordField('Current Password'),
            const SizedBox(height: 12),
            _buildPasswordField('New Password'),
            const SizedBox(height: 12),
            _buildPasswordField('Confirm Password'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: Color(0xFF10B981)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Change', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label) {
    return TextField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: const Color(0xFF0A1628),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E3A5F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Sessions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildSessionItem('Windows PC', 'Chrome • Current session', true),
            const SizedBox(height: 12),
            _buildSessionItem('iPhone 14 Pro', 'Safari • 2 hours ago', false),
            const SizedBox(height: 12),
            _buildSessionItem('MacBook Pro', 'Chrome • 1 day ago', false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(String device, String details, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(12),
        border: isCurrent ? Border.all(color: const Color(0xFF3B82F6)) : null,
      ),
      child: Row(
        children: [
          Icon(
            device.contains('iPhone') ? Icons.phone_iphone : Icons.computer,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Current',
                          style:
                              TextStyle(fontSize: 10, color: Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(details,
                    style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon:
                  const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  void _showSignOutAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out All Devices',
          style:
              TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will end all sessions on other devices. You will need to sign in again on those devices.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out of all other devices'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}
