import 'package:flutter/material.dart';

class SidebarFooter extends StatelessWidget {
  final bool expanded;

  const SidebarFooter({
    super.key,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFA855F7).withValues(alpha: 0.2),
            child: const Text(
              'Z',
              style: TextStyle(
                color: Color(0xFFA855F7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Zeeshan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Free Plan',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white54, size: 20),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }
}
