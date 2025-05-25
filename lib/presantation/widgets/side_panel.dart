import 'package:flutter/material.dart';
import '../../models/project.dart'; // Eğer yoksa eklemeyi unutma

class SidePanel extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onHomeTapped;
  final List<Project> projects;

  const SidePanel({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onHomeTapped,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onHomeTapped,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    selectedIndex == -1
                        ? const Color(0xFFD6E4FF)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.home, size: 18, color: Colors.black54),
                  SizedBox(width: 10),
                  Text(
                    'Ev',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          ...projects.asMap().entries.map((entry) {
            int index = entry.key;
            String name = entry.value.name;
            final isSelected = selectedIndex == index;
            return InkWell(
              onTap: () => onItemSelected(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFD6E4FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
