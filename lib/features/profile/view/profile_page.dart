import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _name = 'Hritik Bhardwaj';
  static const _role = 'Marketing Manager';
  static const _phone = '+91 92127 16009';
  static const _email = 'hritik.bhardwaj@example.com';
  static const _country = 'India';
  static const _location = 'New Delhi, India';
  static const _timezone = 'IST (GMT +05:30)';
  static const _company = 'Acme Ads Pvt. Ltd.';
  static const _memberSince = 'Jan 2024';
  static const _plan = 'Pro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _ProfileHeader(
            name: _name,
            role: _role,
            plan: _plan,
            location: _location,
          ),
          const SizedBox(height: 20),
          const _StatsRow(),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Contact Information',
            children: const [
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: _phone,
              ),
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _email,
              ),
              _InfoTile(
                icon: Icons.public,
                label: 'Country',
                value: _country,
              ),
              _InfoTile(
                icon: Icons.schedule_outlined,
                label: 'Timezone',
                value: _timezone,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Work',
            children: const [
              _InfoTile(
                icon: Icons.business_outlined,
                label: 'Company',
                value: _company,
              ),
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: _role,
              ),
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Member since',
                value: _memberSince,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Preferences',
            children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                label: 'Push Notifications',
                value: true,
                onChanged: (_) {},
              ),
              _ToggleTile(
                icon: Icons.mail_outline,
                label: 'Weekly Performance Email',
                value: true,
                onChanged: (_) {},
              ),
              _ToggleTile(
                icon: Icons.warning_amber_outlined,
                label: 'Anomaly Alerts',
                value: false,
                onChanged: (_) {},
              ),
              _ToggleTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Account',
            children: [
              _ActionTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy & Security',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.logout,
                label: 'Log out',
                color: AppTheme.danger,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Ads Dashboard · v1.0.0',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.plan,
    required this.location,
  });

  final String name;
  final String role;
  final String plan;
  final String location;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, Color(0xFF4DD0E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          plan,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _StatCard(label: 'Campaigns', value: '12')),
        SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Active', value: '4')),
        SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Total Spend', value: '₹2.4L')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _ToggleTile extends StatefulWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<_ToggleTile> {
  late bool _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, size: 18, color: AppTheme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Switch.adaptive(
            value: _value,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (color ?? AppTheme.accent).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color ?? AppTheme.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
