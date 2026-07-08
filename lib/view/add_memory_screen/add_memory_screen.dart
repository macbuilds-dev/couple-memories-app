import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../widgets/memory_card_media.dart';
import '../widgets/media_picker_widget.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/save_button_widget.dart';
import '../widgets/media_source_dialog.dart';

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
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _memoryController = Get.find<MemoryController>();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isTogetherMoment = false;
  DateTime _selectedDate = DateTime.now();
  List<MediaFile> _selectedMedia = [];
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isImage) async {
    try {
      if (isImage) {
        final pickedFiles = await _imagePicker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedMedia.addAll(
              pickedFiles.map((file) => MediaFile(
                    path: file.path,
                    type: MediaType.image,
                  )),
            );
          });
        }
      } else {
        final pickedFile = await _imagePicker.pickVideo(source: source);
        if (pickedFile != null) {
          setState(() {
            _selectedMedia.add(MediaFile(
              path: pickedFile.path,
              type: MediaType.video,
            ));
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
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _slideController,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Edit Memory' : 'Create a New Memory',
                            style: AppTheme.getTitleStyle(
                              fontSize: AppTheme.fontSizeTitle.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _isEditing
                                ? 'Update this beautiful moment'
                                : 'Capture this beautiful moment forever',
                            style: AppTheme.getScriptStyle(
                              fontSize: AppTheme.fontSizeLarge.sp,
                              color: AppTheme.textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          MediaPickerWidget(
                            onTap: _showMediaSourceDialog,
                          ),
                          if (_selectedMedia.isNotEmpty) SizedBox(height: 2.h),
                          if (_selectedMedia.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                                child: MemoryCardMedia(
                                  mediaFiles: _selectedMedia,
                                  showDeleteButton: true,
                                  onDelete: _removeMedia,
                                ),
                              ),
                            ),
                          SizedBox(height: 3.h),
                          CustomTextFieldWidget(
                            controller: _titleController,
                            label: 'Memory Title',
                            hint: 'Give this moment a beautiful name...',
                            icon: Icons.title,
                          ),
                          SizedBox(height: 2.5.h),
                          CustomTextFieldWidget(
                            controller: _descriptionController,
                            label: 'Your Story',
                            hint: 'What made this moment special?',
                            icon: Icons.edit_note,
                            maxLines: 5,
                          ),
                          SizedBox(height: 2.5.h),
                          CustomTextFieldWidget(
                            controller: _locationController,
                            label: 'Where?',
                            hint: 'The place where magic happened...',
                            icon: Icons.location_on,
                          ),
                          SizedBox(height: 2.5.h),
                          DatePickerWidget(
                            selectedDate: _selectedDate,
                            onDateSelected: (date) => setState(() => _selectedDate = date),
                          ),
                          SizedBox(height: 2.h),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'We were both there',
                              style: AppTheme.getBodyStyle(
                                fontSize: AppTheme.fontSizeMedium.sp,
                              ),
                            ),
                            subtitle: Text(
                              'Mark this as a together moment',
                              style: AppTheme.getCaptionStyle(
                                fontSize: AppTheme.fontSizeSmall.sp,
                                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                            value: _isTogetherMoment,
                            activeThumbColor: AppTheme.secondaryColor,
                            onChanged: (v) => setState(() => _isTogetherMoment = v),
                          ),
                          SizedBox(height: 4.h),
                          SaveButtonWidget(
                            onPressed: _saveMemory,
                            label: _isEditing ? 'Update Memory' : 'Save Memory',
                          ),
                          SizedBox(height: 2.5.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                color: AppTheme.textSecondary,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            _isEditing ? 'Edit Memory' : 'New Memory',
            style: AppTheme.getHeadingStyle(
              fontSize: AppTheme.fontSizeXXL.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _saveMemory() async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title for your memory',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

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

    if (createdMemory != null) {
      Get.back();
      NavigationHelper.toMemoryDetail(createdMemory);
    } else {
      Get.back();
    }
  }
}
