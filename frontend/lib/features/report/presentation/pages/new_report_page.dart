import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class NewReportPage extends StatefulWidget {
  const NewReportPage({super.key});

  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Crime type dropdown
  String _selectedCrimeType = 'Phishing';
  final List<String> _crimeTypes = [
    'Phishing',
    'Ransomware',
    'Identity Theft',
    'Online Fraud',
    'Malware',
    'Data Breach',
    'Cyberstalking',
    'Hacking',
    'Social Engineering',
    'Other',
  ];

  // Evidence files
  List<_EvidenceFile> _photos = [];
  List<_EvidenceFile> _videos = [];
  List<_EvidenceFile> _audios = [];

  // Options
  bool _reportAnonymously = false;
  bool _useCurrentLocation = false;
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.status == ReportStateStatus.created || 
              state.status == ReportStateStatus.submitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report submitted successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
            context.pop();
          } else if (state.status == ReportStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
            setState(() => _isSubmitting = false);
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crime Details Section
                  _buildSectionTitle('Crime Details'),
                  const SizedBox(height: 16),

                  // Type of Crime
                  _buildLabel('Type of Crime'),
                  const SizedBox(height: 8),
                  _buildCrimeTypeDropdown(),
                  const SizedBox(height: 20),

                  // Incident Description
                  _buildLabel('Incident Description'),
                  const SizedBox(height: 8),
                  _buildDescriptionField(),
                  const SizedBox(height: 28),

                  // Attach Evidence Section
                  _buildSectionTitle('Attach Evidence'),
                  const SizedBox(height: 16),

                  // Upload Photos
                  _buildUploadButton(
                    icon: Icons.image_outlined,
                    label: 'Upload Photos / Screenshots',
                    count: _photos.length,
                    onTap: _pickPhotos,
                  ),
                  const SizedBox(height: 12),

                  // Upload Video
                  _buildUploadButton(
                    icon: Icons.videocam_outlined,
                    label: 'Upload Video',
                    count: _videos.length,
                    onTap: _pickVideo,
                  ),
                  const SizedBox(height: 12),

                  // Upload Audio
                  _buildUploadButton(
                    icon: Icons.mic_outlined,
                    label: 'Upload Audio',
                    count: _audios.length,
                    onTap: _pickAudio,
                  ),

                  // Show attached files
                  if (_photos.isNotEmpty ||
                      _videos.isNotEmpty ||
                      _audios.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAttachedFilesList(),
                  ],

                  const SizedBox(height: 28),

                  // Location Section
                  _buildSectionTitle('Location'),
                  const SizedBox(height: 16),

                  // Use Current Location
                  _buildLocationButton(),
                  const SizedBox(height: 16),

                  // Or Enter Manually
                  Text(
                    'Or Enter Manually',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLocationTextField(),
                  const SizedBox(height: 24),

                  // Report Anonymously Toggle
                  _buildAnonymousToggle(),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
    );
  }

  Widget _buildCrimeTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E4A6F), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCrimeType,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E3A5F),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          items: _crimeTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCrimeType = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 6,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Describe what happened in as much detail as possible...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFF1E3A5F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E4A6F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E4A6F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please describe the incident';
        }
        if (value.trim().length < 20) {
          return 'Please provide more details (at least 20 characters)';
        }
        return null;
      },
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E4A6F), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachedFilesList() {
    final allFiles = [
      ..._photos.map((f) => _AttachedItem(file: f, type: 'photo')),
      ..._videos.map((f) => _AttachedItem(file: f, type: 'video')),
      ..._audios.map((f) => _AttachedItem(file: f, type: 'audio')),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attached Files (${allFiles.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allFiles.map((item) {
              return _buildFileChip(item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileChip(_AttachedItem item) {
    IconData icon;
    switch (item.type) {
      case 'photo':
        icon = Icons.image;
        break;
      case 'video':
        icon = Icons.videocam;
        break;
      case 'audio':
        icon = Icons.mic;
        break;
      default:
        icon = Icons.attach_file;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              item.file.name,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeFile(item),
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _useCurrentLocation
              ? const Color(0xFF3B82F6).withOpacity(0.2)
              : const Color(0xFF1E3A5F).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _useCurrentLocation
                ? const Color(0xFF3B82F6)
                : const Color(0xFF2E4A6F),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.my_location, color: const Color(0xFF3B82F6), size: 24),
            const SizedBox(width: 12),
            Text(
              _useCurrentLocation
                  ? 'Location Detected'
                  : 'Use Current Location',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const Spacer(),
            if (_useCurrentLocation)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTextField() {
    return TextFormField(
      controller: _locationController,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      enabled: !_useCurrentLocation,
      decoration: InputDecoration(
        hintText: 'Enter address or city',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: _useCurrentLocation
            ? const Color(0xFF1E3A5F).withOpacity(0.3)
            : const Color(0xFF1E3A5F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E4A6F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E4A6F)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF2E4A6F).withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Row(
              children: [
                Text(
                  'Report Anonymously',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.info_outline, size: 18, color: Colors.white54),
              ],
            ),
          ),
          Switch(
            value: _reportAnonymously,
            onChanged: (value) {
              setState(() => _reportAnonymously = value);
            },
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.4),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF3B82F6).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // Action Methods

  Future<void> _pickPhotos() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (images.isNotEmpty) {
        setState(() {
          _photos.addAll(
            images.map(
              (img) =>
                  _EvidenceFile(path: img.path, name: img.name, type: 'image'),
            ),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _videos.add(
            _EvidenceFile(path: video.path, name: video.name, type: 'video'),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick video');
    }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _audios.addAll(
            result.files.map(
              (file) => _EvidenceFile(
                path: file.path ?? '',
                name: file.name,
                type: 'audio',
              ),
            ),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick audio');
    }
  }

  void _removeFile(_AttachedItem item) {
    setState(() {
      switch (item.type) {
        case 'photo':
          _photos.removeWhere((f) => f.path == item.file.path);
          break;
        case 'video':
          _videos.removeWhere((f) => f.path == item.file.path);
          break;
        case 'audio':
          _audios.removeWhere((f) => f.path == item.file.path);
          break;
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    // In real app, use geolocator package
    setState(() {
      _useCurrentLocation = !_useCurrentLocation;
      if (_useCurrentLocation) {
        _locationController.clear();
      }
    });

    if (_useCurrentLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location detected successfully'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please describe the incident');
      return;
    }

    setState(() => _isSubmitting = true);

    // Map string crime type to enum
    final reportType = _mapCrimeTypeToEnum(_selectedCrimeType);

    // Build evidence list
    final evidenceFiles = <File>[
      ..._photos.map((f) => File(f.path)),
      ..._videos.map((f) => File(f.path)),
      ..._audios.map((f) => File(f.path)),
    ];

    // Submit report via bloc
    context.read<ReportBloc>().add(
      CreateReport(
        params: CreateReportParams(
          type: reportType,
          title: _selectedCrimeType,
          description: _descriptionController.text.trim(),
          severity: SeverityLevel.medium,
          isAnonymous: _reportAnonymously,
          locationString: _useCurrentLocation
              ? 'Current Location'
              : _locationController.text.trim(),
          evidenceFiles: evidenceFiles,
        ),
      ),
    );
  }

  ReportType _mapCrimeTypeToEnum(String type) {
    switch (type.toLowerCase()) {
      case 'phishing':
        return ReportType.phishing;
      case 'ransomware':
        return ReportType.ransomware;
      case 'identity theft':
        return ReportType.identityTheft;
      case 'online fraud':
        return ReportType.onlineFraud;
      case 'malware':
        return ReportType.malware;
      case 'data breach':
        return ReportType.dataBreach;
      case 'cyberstalking':
        return ReportType.cyberstalking;
      case 'hacking':
        return ReportType.hacking;
      case 'social engineering':
        return ReportType.socialEngineering;
      default:
        return ReportType.other;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}

// Helper classes

class _EvidenceFile {
  final String path;
  final String name;
  final String type;

  _EvidenceFile({required this.path, required this.name, required this.type});
}

class _AttachedItem {
  final _EvidenceFile file;
  final String type;

  _AttachedItem({required this.file, required this.type});
}
