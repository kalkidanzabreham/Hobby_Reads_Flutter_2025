import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const AdminNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 8,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              _AdminNavLink(
                title: 'Dashboard',
                isSelected: currentRoute == '/admin',
                onTap: () {
                  if (currentRoute != '/admin') {
                    Navigator.pushReplacementNamed(context, '/admin');
                  }
                },
              ),
              const SizedBox(width: 18),
              _AdminNavLink(
                title: 'Users',
                isSelected: currentRoute == '/admin/users',
                onTap: () {
                  if (currentRoute != '/admin/users') {
                    Navigator.pushReplacementNamed(context, '/admin/users');
                  }
                },
              ),
              const SizedBox(width: 18),
              _AdminNavLink(
                title: 'Hobbies',
                isSelected: currentRoute == '/admin/hobbies',
                onTap: () {
                  if (currentRoute != '/admin/hobbies') {
                    Navigator.pushReplacementNamed(context, '/admin/hobbies');
                  }
                },
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement logout
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Exit Admin'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdminNavLink extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminNavLink({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
} 