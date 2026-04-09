import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

class PaymentReceiptUploadCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const PaymentReceiptUploadCard({
    super.key,
    required this.imagePath,
    required this.onPick,
    required this.onClear,
  });

  bool get hasImage => imagePath.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Tk.cartPaymentReceiptTitle.tr,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Tk.cartPaymentReceiptSubtitle.tr,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.input.withOpacity(context.isDark ? .32 : .55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasImage
                      ? context.primary.withOpacity(.40)
                      : context.border.withOpacity(.35),
                ),
              ),
              child: Column(
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.border.withOpacity(.35),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            color: context.primary,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Tk.cartPaymentReceiptPick.tr,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasImage
                              ? Tk.cartPaymentReceiptSelected.tr
                              : Tk.cartPaymentReceiptHint.tr,
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: onPick,
                        icon: Icon(
                          hasImage
                              ? Icons.refresh_rounded
                              : Icons.add_photo_alternate_outlined,
                          size: 18,
                        ),
                        label: Text(
                          hasImage
                              ? Tk.cartPaymentReceiptChange.tr
                              : Tk.cartPaymentReceiptPick.tr,
                        ),
                      ),
                      if (hasImage)
                        TextButton.icon(
                          onPressed: onClear,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: Text(Tk.commonDelete.tr),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
