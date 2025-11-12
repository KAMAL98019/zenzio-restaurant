import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../core/theme/text_styles.dart';

class UploadField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isOptional;
  final Function(String path) onFileSelected;
  final bool allowImages;
  final bool allowDocuments;

  const UploadField({
    Key? key,
    required this.label,
    required this.hint,
    this.isOptional = false,
    required this.onFileSelected,
    this.allowImages = true,
    this.allowDocuments = true,
  }) : super(key: key);

  @override
  State<UploadField> createState() => _UploadFieldState();
}

class _UploadFieldState extends State<UploadField> {
  String? _fileName;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickFile() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (widget.allowImages) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
            if (widget.allowDocuments)
              ListTile(
                leading: const Icon(Icons.file_present, color: AppColors.primary),
                title: const Text('Choose Document'),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _fileName = photo.name;
      });
      widget.onFileSelected(photo.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _fileName = image.name;
      });
      widget.onFileSelected(image.path);
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
      widget.onFileSelected(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.isOptional) ...[
              const SizedBox(width: 4),
              Text(
                '(Optional)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                color: _fileName != null ? AppColors.primary : AppColors.border,
                style: BorderStyle.solid,
                width: _fileName != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  _fileName != null ? Icons.check_circle : Icons.cloud_upload,
                  size: 48,
                  color: _fileName != null ? AppColors.primary : AppColors.textHint,
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? widget.hint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _fileName != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_fileName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tap to change',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
