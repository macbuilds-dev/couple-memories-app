import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import '../../controller/utils/database_admin.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../widgets/admin/admin_app_bar_widget.dart';
import '../widgets/admin/memories_preview_widget.dart';
import '../widgets/admin/deleted_memories_preview_widget.dart';

class MemoriesAdminScreen extends StatefulWidget {
  const MemoriesAdminScreen({Key? key}) : super(key: key);

  @override
  State<MemoriesAdminScreen> createState() => _MemoriesAdminScreenState();
}

class _MemoriesAdminScreenState extends State<MemoriesAdminScreen> {
  final MemoryController _memoryController = Get.find<MemoryController>();
  List<Map<String, dynamic>>? _memories;
  List<Map<String, dynamic>>? _deletedMemories;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    final allMemories = await DatabaseAdmin.getAllMemoriesRaw();
    final deletedMemories = await DatabaseAdmin.getDeletedMemoriesRaw();

    setState(() {
      _memories = allMemories;
      _deletedMemories = deletedMemories;
      _isLoading = false;
    });
  }

  Future<void> _restoreMemory(int id) async {
    await _memoryController.restoreMemory(id);
    await _loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBarWidget(title: 'Manage Memories'),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadMemories,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MemoriesPreviewWidget(memories: _memories),
                      SizedBox(height: 3.h),
                      DeletedMemoriesPreviewWidget(
                        deletedMemories: _deletedMemories,
                        onRestore: _restoreMemory,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
