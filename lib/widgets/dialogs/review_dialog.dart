import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/app_input_field.dart';
import 'package:rwnaqk/widgets/dialogs/app_dialog_shell.dart';
import 'package:rwnaqk/widgets/dialogs/rating_stars_input.dart';

class ReviewDialog extends StatefulWidget {
  final String title;
  final String? userName;
  final String? orderId;
  final String? avatarUrl;

  final int initialRating;
  final String initialComment;

  final void Function(int rating, String comment) onSubmit;

  const ReviewDialog({
    super.key,
    this.title = 'Review',
    this.userName,
    this.orderId,
    this.avatarUrl,
    this.initialRating = 0,
    this.initialComment = '',
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Review',
    String? userName,
    String? orderId,
    String? avatarUrl,
    int initialRating = 0,
    String initialComment = '',
    required void Function(int rating, String comment) onSubmit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ReviewDialog(
        title: title,
        userName: userName,
        orderId: orderId,
        avatarUrl: avatarUrl,
        initialRating: initialRating,
        initialComment: initialComment,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late final TextEditingController _commentCtrl;
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentCtrl = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(_rating, _commentCtrl.text.trim());
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ReviewTargetInfo(
            userName: widget.userName,
            orderId: widget.orderId,
            avatarUrl: widget.avatarUrl,
          ),

          const SizedBox(height: 16),

          RatingStarsInput(
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),

          const SizedBox(height: 16),

          AppInputField(
            controller: _commentCtrl,
            label: 'Your comment'.tr,
            hint: 'Write your review here'.tr,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),

          const SizedBox(height: 16),

          AppButton(
            text: 'Say it!'.tr,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _ReviewTargetInfo extends StatelessWidget {
  final String? userName;
  final String? orderId;
  final String? avatarUrl;

  const _ReviewTargetInfo({
    this.userName,
    this.orderId,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = (userName ?? '').trim().isNotEmpty;
    final hasOrder = (orderId ?? '').trim().isNotEmpty;

    return Row(
      children: [
        _AvatarCircle(avatarUrl: avatarUrl),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasName)
                Text(
                  userName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              if (hasOrder)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${'Order'.tr} #$orderId',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.destructive,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (!hasName && !hasOrder)
                Text(
                  'Share your experience'.tr,
                  style: TextStyle(
                    color: context.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? avatarUrl;

  const _AvatarCircle({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = (avatarUrl ?? '').trim().isNotEmpty;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.input,
        border: Border.all(color: context.border.withOpacity(.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person_rounded,
                color: context.muted,
                size: 20,
              ),
            )
          : Icon(
              Icons.person_rounded,
              color: context.muted,
              size: 20,
            ),
    );
  }
}