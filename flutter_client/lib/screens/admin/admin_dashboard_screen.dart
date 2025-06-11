import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/screens/admin/admin_scaffold.dart';
import 'package:hobby_reads_flutter/providers/user_providers.dart';
import 'package:hobby_reads_flutter/providers/hobby_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(allUsersProvider);
    final hobbiesAsyncValue = ref.watch(allHobbiesProvider);

    return AdminScaffold(
      currentRoute: '/admin',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor and manage your HobbyReads platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  usersAsyncValue.when(
                    data: (users) {
                      final now = DateTime.now();
                      final firstDayOfMonth = DateTime(now.year, now.month, 1);
                      final newUsersThisMonth = users
                          .where((user) =>
                              user.createdAt != null &&
                              user.createdAt!.isAfter(firstDayOfMonth))
                          .length;

                      return _StatCard(
                        title: 'Total Users',
                        count: users.length,
                        newCount: newUsersThisMonth,
                        icon: Icons.people_outline,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: ${error.toString()}'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  hobbiesAsyncValue.when(
                    data: (hobbies) {
                      final now = DateTime.now();
                      final firstDayOfMonth = DateTime(now.year, now.month, 1);
                      final newHobbiesThisMonth = hobbies
                          .where((hobby) =>
                              hobby.createdAt != null &&
                              hobby.createdAt!.isAfter(firstDayOfMonth))
                          .length;

                      return _StatCard(
                        title: 'Total Hobbies',
                        count: hobbies.length,
                        newCount: newHobbiesThisMonth,
                        icon: Icons.category_outlined,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: ${error.toString()}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final int newCount;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.newCount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: Colors.green[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$newCount new this month',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: 48,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
