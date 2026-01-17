import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/datasources/verification_remote_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/di/injection_container.dart' as di;

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final ImagePicker _imagePicker = ImagePicker();
  late final VerificationRemoteDataSource _verificationDataSource;

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isAnalyzing = false;
  VerificationResult? _verificationResult;

  @override
  void initState() {
    super.initState();
    // Initialize verification data source
    _verificationDataSource = VerificationRemoteDataSourceImpl(
      apiClient: di.sl<ApiClient>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: _verificationResult != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _resetVerification,
              )
            : null,
        title: const Text(
          'Evidence Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section
            _buildUploadSection(),

            // Verification Results
            if (_verificationResult != null) ...[
              const SizedBox(height: 32),
              _buildVerificationResults(),
            ],

            // Verify Another File Button
            if (_verificationResult != null) ...[
              const SizedBox(height: 32),
              _buildVerifyAnotherButton(),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _isAnalyzing ? null : _pickMedia,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: Colors.white.withOpacity(0.3),
            strokeWidth: 1,
            gap: 6,
          ),
          child: Column(
            children: [
              const Text(
                'Tap to upload media for analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload an image or video to check its\nauthenticity, metadata, and edit history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _pickMedia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Upload Image/Video',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Analysis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Image Preview with gradient overlay
        _buildImagePreview(),
        const SizedBox(height: 16),

        // Authenticity Result
        _buildAuthenticityResult(),
        const SizedBox(height: 24),

        // Verification Checks
        _buildVerificationCheck(
          icon: Icons.access_time,
          label: 'Metadata Check',
          status: _verificationResult!.metadataStatus,
          statusText: _verificationResult!.metadataVerified
              ? 'Verified'
              : 'Not Verified',
        ),
        const SizedBox(height: 12),
        _buildVerificationCheck(
          icon: Icons.history,
          label: 'Edit History',
          status: _verificationResult!.editHistoryStatus,
          statusText: _verificationResult!.editHistory,
        ),
        const SizedBox(height: 12),
        _buildVerificationCheck(
          icon: Icons.fingerprint,
          label: 'Digital Signature',
          status: _verificationResult!.signatureStatus,
          statusText: _verificationResult!.signatureValid ? 'Valid' : 'Invalid',
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _selectedFileBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    _selectedFileBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 48,
                            color: Colors.white54,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAuthenticityResult() {
    final isHighAuthenticity = _verificationResult!.authenticityLevel == 'High';
    final isMediumAuthenticity =
        _verificationResult!.authenticityLevel == 'Medium';

    Color iconColor;
    Color bgColor;

    if (isHighAuthenticity) {
      iconColor = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withOpacity(0.2);
    } else if (isMediumAuthenticity) {
      iconColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFF59E0B).withOpacity(0.2);
    } else {
      iconColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFEF4444).withOpacity(0.2);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(Icons.verified, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(
              'Authenticity: ${_verificationResult!.authenticityLevel}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _verificationResult!.authenticityDescription,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCheck({
    required IconData icon,
    required String label,
    required VerificationStatus status,
    required String statusText,
  }) {
    Color statusColor;
    IconData? statusIcon;

    switch (status) {
      case VerificationStatus.verified:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case VerificationStatus.warning:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.warning;
        break;
      case VerificationStatus.invalid:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        break;
      case VerificationStatus.neutral:
        statusColor = Colors.white.withOpacity(0.7);
        statusIcon = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
          Row(
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
              if (statusIcon != null) ...[
                const SizedBox(width: 6),
                Icon(statusIcon, size: 18, color: statusColor),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyAnotherButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _resetVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Verify Another File',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Action Methods

  Future<void> _pickMedia() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E3A5F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Media Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildMediaOption(
              icon: Icons.image_outlined,
              label: 'Image from Gallery',
              onTap: () => Navigator.pop(context, 'image_gallery'),
            ),
            const SizedBox(height: 12),
            _buildMediaOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: () => Navigator.pop(context, 'image_camera'),
            ),
            const SizedBox(height: 12),
            _buildMediaOption(
              icon: Icons.videocam_outlined,
              label: 'Video from Gallery',
              onTap: () => Navigator.pop(context, 'video_gallery'),
            ),
            const SizedBox(height: 12),
            _buildMediaOption(
              icon: Icons.file_present_outlined,
              label: 'Select File',
              onTap: () => Navigator.pop(context, 'file'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (result == null) return;

    Uint8List? fileBytes;
    String? fileName;

    try {
      switch (result) {
        case 'image_gallery':
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 100,
          );
          if (image != null) {
            fileBytes = await image.readAsBytes();
            fileName = image.name;
          }
          break;
        case 'image_camera':
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 100,
          );
          if (image != null) {
            fileBytes = await image.readAsBytes();
            fileName = image.name;
          }
          break;
        case 'video_gallery':
          final XFile? video = await _imagePicker.pickVideo(
            source: ImageSource.gallery,
          );
          if (video != null) {
            fileBytes = await video.readAsBytes();
            fileName = video.name;
          }
          break;
        case 'file':
          final FilePickerResult? pickerResult =
              await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png',
              'gif',
              'mp4',
              'mov',
              'avi',
            ],
          );
          if (pickerResult != null) {
            final file = pickerResult.files.single;
            fileBytes = file.bytes;
            fileName = file.name;
          }
          break;
      }

      if (fileBytes != null && fileName != null) {
        setState(() {
          _selectedFileBytes = fileBytes;
          _selectedFileName = fileName;
          _isAnalyzing = true;
        });

        // Call verification analysis
        await _analyzeMedia(fileBytes, fileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick media: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 24),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeMedia(Uint8List fileBytes, String fileName) async {
    try {
      // Call real API for verification
      final verificationData = await _verificationDataSource.verifyEvidence(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      // Parse the results
      final results = verificationData['results'];
      final summary = verificationData['summary'];

      // Map authenticity level
      String authenticityLevel = 'Medium';
      if (results['authenticityLevel'] == 'High') {
        authenticityLevel = 'High';
      } else if (results['authenticityLevel'] == 'Low') {
        authenticityLevel = 'Low';
      }

      // Determine statuses
      VerificationStatus metadataStatus = results['metadataVerified'] == true
          ? VerificationStatus.verified
          : VerificationStatus.warning;

      VerificationStatus editStatus = VerificationStatus.neutral;
      if (results['editHistory'] != null &&
          results['editHistory'] != 'No Edits') {
        editStatus = VerificationStatus.warning;
      }

      VerificationStatus signatureStatus = results['signatureValid'] == true
          ? VerificationStatus.verified
          : VerificationStatus.invalid;

      final mockResult = VerificationResult(
        authenticityLevel: authenticityLevel,
        authenticityDescription: results['authenticityDescription'] ??
            'File has been analyzed for authenticity.',
        metadataVerified: results['metadataVerified'] ?? false,
        metadataStatus: metadataStatus,
        editHistory: results['editHistory'] ?? 'Unknown',
        editHistoryStatus: editStatus,
        signatureValid: results['signatureValid'] ?? false,
        signatureStatus: signatureStatus,
        trustScore: summary['trustScore'] ?? 50,
        recommendations: List<String>.from(summary['recommendations'] ?? []),
        fileHash: results['fileHash'],
        manipulationScore: results['manipulationScore'] ?? 0,
      );

      setState(() {
        _isAnalyzing = false;
        _verificationResult = mockResult;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _resetVerification() {
    setState(() {
      _selectedFileBytes = null;
      _selectedFileName = null;
      _verificationResult = null;
      _isAnalyzing = false;
    });
  }
}

// Verification Result Model
class VerificationResult {
  final String authenticityLevel; // High, Medium, Low
  final String authenticityDescription;
  final bool metadataVerified;
  final VerificationStatus metadataStatus;
  final String editHistory;
  final VerificationStatus editHistoryStatus;
  final bool signatureValid;
  final VerificationStatus signatureStatus;
  final int trustScore;
  final List<String> recommendations;
  final String? fileHash;
  final int manipulationScore;

  VerificationResult({
    required this.authenticityLevel,
    required this.authenticityDescription,
    required this.metadataVerified,
    required this.metadataStatus,
    required this.editHistory,
    required this.editHistoryStatus,
    required this.signatureValid,
    required this.signatureStatus,
    this.trustScore = 50,
    this.recommendations = const [],
    this.fileHash,
    this.manipulationScore = 0,
  });
}

enum VerificationStatus { verified, warning, invalid, neutral }

// Custom Dashed Border Painter
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // This is just a placeholder - the actual dashed border is handled by the container
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
