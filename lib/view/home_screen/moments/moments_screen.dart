import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/model/moments_filter.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/home_screen/discover/discover_widgets.dart';
import 'package:yaaram/view/home_screen/moments/moment_card_widget.dart';
import 'package:yaaram/view/widgets/delete_memory_dialog.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  final MemoryController _memoryController = Get.find<MemoryController>();
  final AuthController _auth = Get.find<AuthController>();
  MomentsFilter _filter = MomentsFilter.all;
  String? _partnerUid;

  @override
  void initState() {
    super.initState();
    _loadPartner();
  }

  Future<void> _loadPartner() async {
    final uid = await _memoryController.partnerUid();
    if (mounted) setState(() => _partnerUid = uid);
  }

  void _openMemory(Memory memory) {
    if (memory.isTogetherMoment) {
      NavigationHelper.toTogetherMoment(memory);
      return;
    }
    NavigationHelper.toDiscoverPreview(memory);
  }

  Future<void> _addNote(Memory memory) async {
    final text = await showQuickNoteDialog(context);
    if (text == null) return;
    await _memoryController.addNoteToMemory(memory.id, text);
  }

  Future<void> _setReminder(Memory memory) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: memory.reminderAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(memory.reminderAt ?? DateTime.now()),
    );
    if (time == null) return;
    final when = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );
    await _memoryController.setReminder(memory.id, when);
  }

  Map<String, List<Memory>> _groupByDay(List<Memory> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<Memory>>{};

    for (final memory in items) {
      final day = DateTime(memory.date.year, memory.date.month, memory.date.day);
      final String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(memory.date);
      }
      groups.putIfAbsent(label, () => []).add(memory);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final myUid = _auth.uid ?? '';

    return Obx(() {
      final items = _memoryController.momentsMemoriesFor(
        myUid,
        _partnerUid,
        _filter,
      );
      final groups = _groupByDay(items);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 4.w, 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moments',
                          style: AppTheme.getHeadingStyle(
                            fontSize: AppTheme.fontSizeTitle.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        Text(
                          'Memories you share, like, and leave notes on together.',
                          style: AppTheme.getBodyStyle(
                            fontSize: AppTheme.fontSizeSmall.sp,
                            color: AppTheme.textPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _FilterButton(
                    filter: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No moments here yet',
                        style: AppTheme.getBodyStyle(
                          color: AppTheme.textPrimary.withValues(alpha: 0.65),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final label = groups.keys.elementAt(index);
                        final section = groups[label]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                                    child: Text(
                                      label,
                                      style: AppTheme.getCaptionStyle(
                                        fontSize: AppTheme.fontSizeSmall.sp,
                                        color: AppTheme.textSecondary.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 3.w,
                                mainAxisSpacing: 3.w,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: section.length,
                              itemBuilder: (context, i) {
                                final memory = section[i];
                                final isOwner =
                                    memory.createdBy == myUid || memory.createdBy == null;
                                return MomentCardWidget(
                                  memory: memory,
                                  isLiked: memory.isLikedBy(myUid),
                                  showOwnerActions: isOwner,
                                  onTap: () => _openMemory(memory),
                                  onLike: () =>
                                      _memoryController.toggleLikeMemory(memory.id),
                                  onAddNote: () => _addNote(memory),
                                  onEdit: isOwner
                                      ? () => NavigationHelper.toAddMemory(
                                            memoryToEdit: memory,
                                          )
                                      : null,
                                  onDelete: isOwner
                                      ? () => DeleteMemoryDialog.show(
                                            memory: memory,
                                            onConfirm: () => _memoryController
                                                .deleteMemory(memory.id),
                                          )
                                      : null,
                                  onReminder: isOwner ? () => _setReminder(memory) : null,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
      );
    });
  }
}

class _FilterButton extends StatelessWidget {
  final MomentsFilter filter;
  final ValueChanged<MomentsFilter> onChanged;

  const _FilterButton({
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: PopupMenuButton<MomentsFilter>(
        initialValue: filter,
        icon: Icon(Icons.tune, color: AppTheme.secondaryColor, size: 6.w),
        onSelected: onChanged,
        itemBuilder: (context) => MomentsFilter.values
            .map(
              (f) => PopupMenuItem(
                value: f,
                child: Text(f.label),
              ),
            )
            .toList(),
      ),
    );
  }
}
