import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:yaaram/controller/memory_controller.dart';
import '../../../controller/utils/database_admin.dart';
import 'admin_section_card_widget.dart';
import 'admin_action_button_widget.dart';

class AdminActionsSectionWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const AdminActionsSectionWidget({
    Key? key,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardWidget(
      title: '🔧 Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminActionButtonWidget(
            label: 'Print Database Stats',
            icon: Icons.print,
            onTap: () async {
              await DatabaseAdmin.printDatabaseStats();
              Get.snackbar('Success', 'Stats printed to console',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          SizedBox(height: 1.h),
          AdminActionButtonWidget(
            label: 'Export Database',
            icon: Icons.download,
            onTap: () async {
              final export = await DatabaseAdmin.exportDatabase();
              final jsonString = const JsonEncoder.withIndent('  ').convert(export);

              Get.dialog(
                AlertDialog(
                  title: const Text('Database Export'),
                  content: SingleChildScrollView(
                    child: SelectableText(jsonString),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
          AdminActionButtonWidget(
            label: 'Show Database Path',
            icon: Icons.folder,
            onTap: () => DatabaseAdmin.showDatabasePath(),
          ),
          SizedBox(height: 1.h),
          AdminActionButtonWidget(
            label: 'Clear All Memories',
            icon: Icons.delete_forever,
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Clear All Memories'),
                  content: const Text(
                    'This will permanently delete all memories from the database. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.back();
                        final cleared = await DatabaseAdmin.clearAllMemories();
                        if (cleared) {
                          await Get.find<MemoryController>().loadMemories();
                          onRefresh?.call();
                          Get.snackbar(
                            'Cleared',
                            'All memories have been removed',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (onRefresh != null) ...[
            SizedBox(height: 1.h),
            AdminActionButtonWidget(
              label: 'Refresh',
              icon: Icons.refresh,
              onTap: onRefresh!,
            ),
          ],
        ],
      ),
    );
  }
}
