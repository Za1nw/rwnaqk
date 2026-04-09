import 'dart:io';
import 'package:flutter/material.dart';

/// كرت رفع صورة سند الحوالة/الإشعار
class PaymentReceiptUploadCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const PaymentReceiptUploadCard({
    super.key,
    required this.imageFile,
    required this.onPickImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إرفاق صورة سند الحوالة',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          if (imageFile == null)
            OutlinedButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('اختيار صورة'),
            )
          else
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                if (onRemoveImage != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onRemoveImage,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
