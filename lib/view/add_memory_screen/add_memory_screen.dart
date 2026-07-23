import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';
import 'package:yaaram/view/widgets/date_picker_widget.dart';
import 'package:yaaram/view/widgets/media_picker_widget.dart';
import 'package:yaaram/view/widgets/media_source_dialog.dart';
import 'package:yaaram/view/widgets/memory_card_media.dart';
import 'package:yaaram/view/widgets/save_button_widget.dart';

class AddMemoryScreen extends StatefulWidget {
  final Memory? memoryToEdit;
  final String? initialTitle;
  final String? initialDescription;

  const AddMemoryScreen({
    Key? key,
    this.memoryToEdit,
    this.initialTitle,
    this.initialDescription,
  }) : super(key: key);

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _memoryController = Get.find<MemoryController>();
  final _settings = Get.find<SettingsController>();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isTogetherMoment = false;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  List<MediaFile> _selectedMedia = [];
  late AnimationController _enterController;

  bool get _isEditing => widget.memoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final memory = widget.memoryToEdit!;
      _titleController.text = memory.title;
      _descriptionController.text = memory.description;
      _locationController.text = memory.location;
      _selectedDate = memory.date;
      _selectedMedia = List.from(memory.mediaFiles);
      _isTogetherMoment = memory.isTogetherMoment;
    } else {
      if (widget.initialTitle != null) {
        _titleController.text = widget.initialTitle!;
      }
      if (widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
    }

    _enterController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isImage) async {
    try {
      if (isImage) {
        final pickedFiles = await _imagePicker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedMedia.addAll(
              pickedFiles.map(
                (file) => MediaFile(path: file.path, type: MediaType.image),
              ),
            );
          });
        }
      } else {
        final pickedFile = await _imagePicker.pickVideo(source: source);
        if (pickedFile != null) {
          setState(() {
            _selectedMedia.add(
              MediaFile(path: pickedFile.path, type: MediaType.video),
            );
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick media: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showMediaSourceDialog() {
    MediaSourceDialog.show(
      onTakePhoto: () => _pickMedia(ImageSource.camera, true),
      onRecordVideo: () => _pickMedia(ImageSource.camera, false),
      onChoosePhotos: () => _pickMedia(ImageSource.gallery, true),
      onChooseVideo: () => _pickMedia(ImageSource.gallery, false),
    );
  }

  void _removeMedia(int index) {
    setState(() => _selectedMedia.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final saveLabel = _isEditing
        ? 'Update Memory'
        : _settings.settings.value.newMemoryButton;

    return AppScreenShell(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textSecondary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _isEditing ? 'Edit Memory' : 'New Memory',
          style: AppTheme.getHeadingStyle(
            fontSize: AppTheme.fontSizeXL.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      child: FadeTransition(
        opacity: _enterController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _enterController,
            curve: Curves.easeOutCubic,
          )),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit this moment' : 'Create a new memory',
                  style: AppTheme.getTitleStyle(
                    fontSize: AppTheme.fontSizeTitle.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  _isEditing
                      ? 'Update the details so you both remember it clearly.'
                      : 'Capture photos, place, and the story behind it.',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                    color: AppTheme.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 3.5.h),
                Text(
                  'Photos & videos',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                    color: AppTheme.textSecondary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.2.h),
                MediaPickerWidget(onTap: _showMediaSourceDialog),
                if (_selectedMedia.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: MemoryCardMedia(
                      mediaFiles: _selectedMedia,
                      showDeleteButton: true,
                      onDelete: _removeMedia,
                    ),
                  ),
                ],
                SizedBox(height: 3.h),
                AppTextField(
                  controller: _titleController,
                  label: 'Memory title',
                  hint: 'Give this moment a name',
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 2.5.h),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Your story',
                  hint: 'What made this moment special?',
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 2.5.h),
                AppTextField(
                  controller: _locationController,
                  label: 'Where?',
                  hint: 'Place this memory happened',
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 2.5.h),
                DatePickerWidget(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) =>
                      setState(() => _selectedDate = date),
                ),
                SizedBox(height: 2.h),
                _TogetherMomentToggle(
                  value: _isTogetherMoment,
                  onChanged: (v) => setState(() => _isTogetherMoment = v),
                ),
                SizedBox(height: 4.h),
                SaveButtonWidget(
                  onPressed: _isSaving ? null : _saveMemory,
                  label: saveLabel,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMemory() async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Missing title',
        'Please enter a title for your memory',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.memoryToEdit!.copyWith(
          date: _selectedDate,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          mediaFiles: _selectedMedia,
          isTogetherMoment: _isTogetherMoment,
        );

        final success = await _memoryController.updateMemory(updated);
        if (success) {
          Get.back();
          final refreshed = _memoryController.memories
              .firstWhereOrNull((m) => m.id == updated.id);
          if (refreshed != null) {
            NavigationHelper.toMemoryDetail(refreshed);
          }
        }
        return;
      }

      final newMemory = Memory(
        id: DateTime.now().millisecondsSinceEpoch,
        date: _selectedDate,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        isFavorite: false,
        isDeleted: false,
        mediaFiles: _selectedMedia,
        isTogetherMoment: _isTogetherMoment,
      );

      final createdMemory = await _memoryController.addMemory(newMemory);
      Get.back();
      if (createdMemory != null) {
        NavigationHelper.toMemoryDetail(createdMemory);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _TogetherMomentToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TogetherMomentToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: value
                  ? AppTheme.secondaryColor
                  : AppTheme.secondaryColor.withValues(alpha: 0.25),
              width: value ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.secondaryColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We were both there',
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeMedium.sp,
                        color: AppTheme.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Mark this as a together moment',
                      style: AppTheme.getCaptionStyle(
                        fontSize: AppTheme.fontSizeSmall.sp,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                activeThumbColor: AppTheme.secondaryColor,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
