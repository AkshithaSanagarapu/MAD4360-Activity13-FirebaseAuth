import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'product_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signOut();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = AuthService.errorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    final formKey = GlobalKey<FormState>();
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();

    bool saving = false;
    String? error;

    try {
      final changed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Change Password'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: current,
                      obscureText: true,
                      enabled: !saving,
                      decoration: const InputDecoration(
                        labelText: 'Current password',
                      ),
                      validator: (value) =>
                          (value ?? '').isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: next,
                      obscureText: true,
                      enabled: !saving,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                      ),
                      validator: (value) => (value ?? '').length < 6
                          ? 'Use at least 6 characters'
                          : null,
                    ),
                    TextFormField(
                      controller: confirm,
                      obscureText: true,
                      enabled: !saving,
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                      ),
                      validator: (value) =>
                          value != next.text ? 'Passwords do not match' : null,
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await AuthService.instance.updatePassword(
                            current.text,
                            next.text,
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        } catch (exception) {
                          if (dialogContext.mounted) {
                            setDialogState(() {
                              error = AuthService.errorMessage(exception);
                              saving = false;
                            });
                          }
                        }
                      },
                child: Text(saving ? 'Updating...' : 'Update'),
              ),
            ],
          ),
        ),
      );

      if (changed == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } finally {
      current.dispose();
      next.dispose();
      confirm.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_circle, size: 90),
                const SizedBox(height: 16),
                Text(
                  'Signed in successfully',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  'Email: ${user?.email ?? "Unavailable"}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ProductHomePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Open Product Manager'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.password),
                  label: const Text('Change Password'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _loading ? null : _signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(_loading ? 'Signing out...' : 'Sign Out'),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
