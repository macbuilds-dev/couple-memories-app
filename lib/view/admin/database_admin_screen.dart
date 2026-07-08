import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import '../../controller/utils/database_admin.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../widgets/admin/admin_app_bar_widget.dart';
import '../widgets/admin/database_info_widget.dart';
import '../widgets/admin/table_info_widget.dart';
import '../widgets/admin/admin_actions_section_widget.dart';

class DatabaseAdminScreen extends StatefulWidget {
  const DatabaseAdminScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseAdminScreen> createState() => _DatabaseAdminScreenState();
}

class _DatabaseAdminScreenState extends State<DatabaseAdminScreen> {
  Map<String, dynamic>? _dbInfo;
  List<Map<String, dynamic>>? _tableInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() => _isLoading = true);
    final info = await DatabaseAdmin.getDatabaseInfo();
    final tables = await DatabaseAdmin.getTableInfo();

    setState(() {
      _dbInfo = info;
      _tableInfo = tables;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadDatabaseInfo();
    await Get.find<MemoryController>().loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBarWidget(title: 'Database'),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DatabaseInfoWidget(dbInfo: _dbInfo),
                    SizedBox(height: 3.h),
                    TableInfoWidget(tableInfo: _tableInfo),
                    SizedBox(height: 3.h),
                    AdminActionsSectionWidget(onRefresh: _onRefresh),
                  ],
                ),
              ),
      ),
    );
  }

}
