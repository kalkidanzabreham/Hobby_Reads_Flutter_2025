import 'package:flutter/material.dart';

class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const NavAppBar({
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
              Icon(
                Icons.menu_book,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
              const SizedBox(width: 18),
              _NavLink(
                title: 'Dashboard',
                isSelected: currentRoute == '/home',
                onTap: () {
                  if (currentRoute != '/home') {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              const SizedBox(width: 18),
              _NavLink(
                title: 'Books',
                isSelected: currentRoute.startsWith('/books') || currentRoute == '/add-book',
                onTap: () {
                  if (currentRoute != '/books') {
                    Navigator.pushReplacementNamed(context, '/books');
                  }
                },
              ),
              const SizedBox(width: 18),
              _NavLink(
                title: 'Connections',
                isSelected: currentRoute == '/connections',
                onTap: () {
                  if (currentRoute != '/connections') {
                    Navigator.pushReplacementNamed(context, '/connections');
                  }
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 16,
              child: const Text(
                'J',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavLink extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavLink({
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
          color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
} 