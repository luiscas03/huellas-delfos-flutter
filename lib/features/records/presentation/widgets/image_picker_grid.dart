import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../core/theme/app_colors.dart';

class ImagePickerGrid extends StatefulWidget {
  const ImagePickerGrid({
    super.key,
    required this.title,
    this.compact = false,
    this.onAdd,
    this.onRemove,
  });

  final String title;
  final bool compact;
  final void Function(File file)? onAdd;
  final void Function(File file)? onRemove;

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  Future<void> _pickImage(ImageSource source) async {
    final granted = source == ImageSource.camera
        ? await PermissionsHelper.requestCamera(context)
        : await PermissionsHelper.requestStorage(context);
    if (!granted) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() => _images.add(file));
    widget.onAdd?.call(file);
  }

  void _openViewer(File file) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Stack(
          children: [
            Image.file(file, fit: BoxFit.contain),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(widget.title, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Tomar Foto'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Icon(Icons.photo_library_outlined, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_images.isNotEmpty) ...[
          Text('${_images.length} foto(s) capturada(s)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _images.length,
            itemBuilder: (_, index) {
              final file = _images[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _openViewer(file),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 10))),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () {
                        final file = _images[index];
                        setState(() => _images.removeAt(index));
                        widget.onRemove?.call(file);
                      },
                      child: const CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.close, size: 12)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
