import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/couple_chat_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/chat_message_model.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/utils/media_utils.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/chat/partner_profile_preview_screen.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';
import 'package:yaaram/view/widgets/themed_icon_menu_button.dart';

class CoupleChatScreen extends StatefulWidget {
  const CoupleChatScreen({super.key});

  @override
  State<CoupleChatScreen> createState() => _CoupleChatScreenState();
}

class _CoupleChatScreenState extends State<CoupleChatScreen> {
  late final CoupleChatController _chat;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CoupleChatController>()) {
      _chat = Get.find<CoupleChatController>();
    } else {
      _chat = Get.put(CoupleChatController());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openPartnerProfile() {
    final pUid = _chat.partnerUid.value;
    final profile = _chat.partnerProfile.value;
    if (pUid == null || profile == null) return;

    Get.to(() => PartnerProfilePreviewScreen(
          partnerUid: pUid,
          initialProfile: profile,
        ));
  }

  Future<void> _showNicknameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _NicknameDialog(
        initial: _chat.partnerProfile.value?.nickname ?? '',
      ),
    );

    if (!mounted) return;
    if (result == null || result.isEmpty) return;

    try {
      await _chat.setPartnerNickname(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nickname updated for your partner')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    }
  }

  void _onMenuAction(String action) {
    switch (action) {
      case 'nickname':
        _showNicknameDialog();
      case 'bg':
        _chat.pickChatBackground();
      case 'clear_bg':
        _chat.clearChatBackground();
      case 'profile':
        _openPartnerProfile();
    }
  }

  void _onMessageAction(ChatMessage message, String action) {
    switch (action) {
      case 'memory':
        _saveMessageAsMemory(message);
      case 'open_memory':
        _openSharedMemory(message);
    }
  }

  void _saveMessageAsMemory(ChatMessage message) {
    final text = message.text?.trim();
    if (text == null || text.isEmpty) return;

    Get.toNamed(
      AppRoutes.addMemory,
      arguments: {
        'initialTitle': 'From our chat',
        'initialDescription': text,
      },
    );
  }

  void _openSharedMemory(ChatMessage message) {
    if (message.memoryId == null) return;
    final memories = Get.find<MemoryController>().memories;
    final memory = memories.cast<Memory?>().firstWhere(
          (m) => m?.id == message.memoryId,
          orElse: () => null,
        );
    if (memory != null) {
      NavigationHelper.toMemoryDetail(memory);
    } else {
      Get.snackbar('Memory not found', 'It may not be synced on this device yet.');
    }
  }

  Future<void> _send() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    try {
      await _chat.sendText(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send: $e')),
        );
      }
      return;
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      if (_chat.isLoadingPartner.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!_chat.isPartnerLinked) {
        return _ChatCoupleLinkPanel(
          onLinked: () async {
            await auth.refreshProfile();
            await _chat.reload();
          },
        );
      }

      final bgPath = _chat.backgroundPath.value;
      final partner = _chat.partnerProfile.value;
      final hasBgImage =
          bgPath != null && File(bgPath).existsSync();

      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: hasBgImage
                ? Image.file(File(bgPath!), fit: BoxFit.cover)
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                    ),
                  ),
          ),
          if (hasBgImage)
            Positioned.fill(
              child: ColoredBox(
                color: AppTheme.surfaceColor.withValues(alpha: 0.72),
              ),
            ),
          Column(
            children: [
              _ChatHeader(
                partner: partner,
                displayName: _chat.partnerDisplayName,
                onAvatarTap: _openPartnerProfile,
                onMenuAction: _onMenuAction,
              ),
              Expanded(
                child: Obx(() {
                  final stream = _chat.messagesStream;
                  if (stream == null) {
                    return const SizedBox.shrink();
                  }
                  final _ = _chat.pendingMessages.length;
                  return StreamBuilder<List<ChatMessage>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      final fromStream =
                          snapshot.data ?? const <ChatMessage>[];
                      if (fromStream.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _chat.prunePendingAgainst(fromStream);
                        });
                      }
                      final messages = _chat.mergeMessages(fromStream);
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          messages.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return _MessageList(
                        messages: messages,
                        myUid: auth.uid ?? '',
                        scrollController: _scrollController,
                        onMessageAction: _onMessageAction,
                      );
                    },
                  );
                }),
              ),
              _ChatComposer(
                controller: _textController,
                isSending: _chat.isSending.value,
                onSend: _send,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _ChatHeader extends StatelessWidget {
  final UserProfile? partner;
  final String displayName;
  final VoidCallback onAvatarTap;
  final ValueChanged<String> onMenuAction;

  const _ChatHeader({
    required this.partner,
    required this.displayName,
    required this.onAvatarTap,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final photoPath = partner?.photoPath;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 2.w, 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 5.5.w,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              backgroundImage: photoPath != null && File(photoPath).existsSync()
                  ? MediaUtils.imageProvider(photoPath)
                  : null,
              child: photoPath == null || !File(photoPath).existsSync()
                  ? Icon(
                      Icons.person_outline,
                      color: AppTheme.secondaryColor,
                      size: 5.5.w,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: GestureDetector(
              onTap: onAvatarTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getHeadingStyle(
                      fontSize: AppTheme.fontSizeLarge.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Tap photo for profile',
                    style: AppTheme.getCaptionStyle(
                      fontSize: AppTheme.fontSizeSmall.sp,
                      color: AppTheme.textPrimary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ThemedIconMenuButton<String>(
            triggerIcon: Icons.more_horiz,
            onSelected: onMenuAction,
            items: const [
              IconMenuItem(value: 'nickname', icon: Icons.badge),
              IconMenuItem(value: 'bg', icon: Icons.wallpaper),
              IconMenuItem(value: 'clear_bg', icon: Icons.hide_image),
              IconMenuItem(value: 'profile', icon: Icons.person),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final String myUid;
  final ScrollController scrollController;
  final void Function(ChatMessage, String) onMessageAction;

  const _MessageList({
    required this.messages,
    required this.myUid,
    required this.scrollController,
    required this.onMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'Say hello to your partner 💕',
            textAlign: TextAlign.center,
            style: AppTheme.getBodyStyle(
              color: AppTheme.textPrimary.withValues(alpha: 0.65),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMine = msg.senderId == myUid;
        return _MessageBubble(
          message: msg,
          isMine: isMine,
          onAction: (action) => onMessageAction(msg, action),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final ValueChanged<String> onAction;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a').format(message.createdAt);
    final isMemory = message.type == ChatMessage.typeMemoryShare;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showActions(context),
        child: Container(
          margin: EdgeInsets.only(bottom: 1.2.h),
          constraints: BoxConstraints(maxWidth: 72.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: isMine
                ? AppTheme.secondaryColor
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusMedium),
              topRight: Radius.circular(AppTheme.radiusMedium),
              bottomLeft: Radius.circular(isMine ? AppTheme.radiusMedium : 4),
              bottomRight: Radius.circular(isMine ? 4 : AppTheme.radiusMedium),
            ),
            border: isMine
                ? null
                : Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.15),
                  ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMemory) ...[
                if (message.memoryImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: SizedBox(
                      height: 18.h,
                      width: double.infinity,
                      child: MediaUtils.buildImage(
                        path: message.memoryImageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(height: 0.8.h),
                Text(
                  message.memoryTitle ?? 'Shared memory',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                    color: isMine ? Colors.white : AppTheme.textSecondary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              if (message.text?.trim().isNotEmpty == true) ...[
                if (isMemory) SizedBox(height: 0.4.h),
                Text(
                  message.text!,
                  style: AppTheme.getBodyStyle(
                    color: isMine ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
              SizedBox(height: 0.4.h),
              Text(
                time,
                style: AppTheme.getCaptionStyle(
                  fontSize: AppTheme.fontSizeSmall.sp,
                  color: isMine
                      ? Colors.white.withValues(alpha: 0.75)
                      : AppTheme.textSecondary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    final isMemory = message.type == ChatMessage.typeMemoryShare;
    final canSave = !isMemory && message.text?.trim().isNotEmpty == true;
    final canOpen = isMemory && message.memoryId != null;
    if (!canSave && !canOpen) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusMedium),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMemory && message.text?.trim().isNotEmpty == true)
              ListTile(
                leading: Icon(Icons.auto_awesome, color: AppTheme.secondaryColor),
                title: const Text('Save as memory'),
                onTap: () {
                  Navigator.pop(ctx);
                  onAction('memory');
                },
              ),
            if (isMemory && message.memoryId != null)
              ListTile(
                leading: Icon(Icons.photo_library, color: AppTheme.secondaryColor),
                title: const Text('Open memory'),
                onTap: () {
                  Navigator.pop(ctx);
                  onAction('open_memory');
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _ChatComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              style: AppTheme.getBodyStyle(),
              decoration: InputDecoration(
                hintText: 'Message your partner…',
                hintStyle: AppTheme.getBodyStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor.withValues(alpha: 0.92),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.4.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          SizedBox(width: 2.w),
          Material(
            color: AppTheme.secondaryColor,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: isSending ? null : onSend,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 12.w,
                height: 12.w,
                child: isSending
                    ? Padding(
                        padding: EdgeInsets.all(3.w),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.send_rounded, color: Colors.white, size: 5.5.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatCoupleLinkPanel extends StatefulWidget {
  final Future<void> Function() onLinked;

  const _ChatCoupleLinkPanel({required this.onLinked});

  @override
  State<_ChatCoupleLinkPanel> createState() => _ChatCoupleLinkPanelState();
}

class _ChatCoupleLinkPanelState extends State<_ChatCoupleLinkPanel> {
  final _codeController = TextEditingController();
  final _auth = Get.find<AuthController>();
  late String? _createdCode;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final profile = _auth.profile.value;
    final existing = profile?.coupleCode ?? profile?.coupleId;
    _createdCode =
        existing != null && existing.isNotEmpty ? existing : null;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createCouple() async {
    setState(() => _busy = true);
    try {
      final code = await _auth.createCouple();
      setState(() => _createdCode = code);
      await widget.onLinked();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinCouple() async {
    if (_codeController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-character couple code')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await _auth.joinCouple(_codeController.text);
      await widget.onLinked();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect to chat',
            style: AppTheme.getHeadingStyle(
              fontSize: AppTheme.fontSizeTitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Chat unlocks when both of you join the same couple code.',
            style: AppTheme.getBodyStyle(
              fontSize: AppTheme.fontSizeMedium.sp,
              color: AppTheme.textPrimary.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: 3.h),
          _linkCard(
            title: 'Enter partner code',
            subtitle: 'Join with their 6-character code',
            child: Column(
              children: [
                AppTextField(
                  controller: _codeController,
                  label: 'Couple code',
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _joinCouple,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Join & open chat'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.5.h),
          _linkCard(
            title: 'Generate code for partner',
            subtitle: 'Share your code so they can join you',
            child: Column(
              children: [
                if (_createdCode != null) ...[
                  SelectableText(
                    _createdCode!,
                    style: AppTheme.getHeadingStyle(
                      fontSize: AppTheme.fontSizeDisplay.sp,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _createdCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy code'),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Waiting for your partner to join…',
                    style: AppTheme.getCaptionStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _createCouple,
                      child: const Text('Generate couple code'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.getHeadingStyle(fontSize: AppTheme.fontSizeXL.sp),
          ),
          Text(
            subtitle,
            style: AppTheme.getCaptionStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }
}

class _NicknameDialog extends StatefulWidget {
  final String initial;

  const _NicknameDialog({required this.initial});

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: Text(
        'Set nickname',
        style: AppTheme.getHeadingStyle(color: AppTheme.textSecondary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 32,
        style: AppTheme.getBodyStyle(),
        decoration: InputDecoration(
          hintText: 'Sweet nickname for your partner',
          hintStyle: AppTheme.getBodyStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTheme.getBodyStyle()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(
            'Save',
            style: AppTheme.getBodyStyle(color: AppTheme.secondaryColor)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
