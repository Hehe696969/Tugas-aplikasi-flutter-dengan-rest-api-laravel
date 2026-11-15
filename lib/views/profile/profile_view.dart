import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/auth_vm.dart';
import '../../core/routes/app_router.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authProvider.notifier).getProfile(),
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: Center(
        child: authState.loading && user == null
            ? const CircularProgressIndicator()
            : user == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authState.error ?? 'Data profil tidak tersedia.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref
                            .read(authProvider.notifier)
                            .getProfile(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 42,
                                child: Icon(
                                  Icons.person,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: const Text('Nama'),
                                subtitle: Text(user.name),
                              ),
                              ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: const Text('Email'),
                                subtitle: Text(user.email),
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_month),
                                title: const Text('Tanggal Bergabung'),
                                subtitle: Text(
                                  user.createdAt == null
                                      ? '-'
                                      : DateFormat('dd MMMM yyyy', 'id_ID')
                                          .format(user.createdAt!),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _logout,
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Logout'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
