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
    this.currentFilePath,
  }) : super(key: key);

  final String? currentFilePath;

  @override
  State<UploadField> createState() => _UploadFieldState();
}

class _UploadFieldState extends State<UploadField> {
  String? _filePathOrUrl;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _filePathOrUrl = widget.currentFilePath;
    _setFileNameFromPathOrUrl(_filePathOrUrl);
  }

  @override
  void didUpdateWidget(covariant UploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFilePath != oldWidget.currentFilePath) {
      _filePathOrUrl = widget.currentFilePath;
      _setFileNameFromPathOrUrl(_filePathOrUrl);
    }
  }
  
  void _setFileNameFromPathOrUrl(String? path) {
    if (path == null || path.isEmpty) {
      _fileName = null;
    } else if (path.startsWith('http')) {
      // It's a URL, use the last segment as the 'filename' for display
      _fileName = path.split('/').last;
    } else {
      // It's a local file path
      _fileName = path.split(Platform.pathSeparator).last;
    }
  }

  String? _fileName;

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
        _filePathOrUrl = photo.path;
        _setFileNameFromPathOrUrl(_filePathOrUrl);
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
        _filePathOrUrl = image.path;
        _setFileNameFromPathOrUrl(_filePathOrUrl);
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
        _filePathOrUrl = result.files.single.path!;
        _setFileNameFromPathOrUrl(_filePathOrUrl);
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
                color: _filePathOrUrl != null ? AppColors.primary : AppColors.border,
                style: BorderStyle.solid,
                width: _filePathOrUrl != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  _filePathOrUrl != null ? Icons.check_circle : Icons.cloud_upload,
                  size: 48,
                  color: _filePathOrUrl != null ? AppColors.primary : AppColors.textHint,
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? widget.hint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _filePathOrUrl != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_filePathOrUrl != null) ...[
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
