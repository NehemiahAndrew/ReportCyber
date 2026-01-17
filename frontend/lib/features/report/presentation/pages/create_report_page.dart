import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attackerInfoController = TextEditingController();
  final _financialLossController = TextEditingController();

  int _currentStep = 0;
  ReportType _selectedType = ReportType.phishing;
  SeverityLevel _selectedSeverity = SeverityLevel.medium;
  DateTime? _incidentDate;
  bool _isAnonymous = false;
  List<String> _affectedSystems = [];
  List<String> _suspiciousUrls = [];
  List<String> _suspiciousEmails = [];
  List<String> _suspiciousIps = [];
  List<File> _evidenceFiles = [];
  String _currency = 'USD';

  final _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load any saved draft
    context.read<ReportBloc>().add(const LoadLocalDraft());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _attackerInfoController.dispose();
    _financialLossController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  void _saveAsDraft() {
    final params = _buildReportParams(saveAsDraft: true);
    context.read<ReportBloc>().add(CreateReport(params: params));
  }

  void _submitReport() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = _buildReportParams(saveAsDraft: false);
      context.read<ReportBloc>().add(CreateReport(params: params));
    }
  }

  CreateReportParams _buildReportParams({bool saveAsDraft = false}) {
    return CreateReportParams(
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      severity: _selectedSeverity,
      isAnonymous: _isAnonymous,
      incidentDate: _incidentDate,
      affectedSystems: _affectedSystems,
      attackerInfo: _attackerInfoController.text.trim().isNotEmpty
          ? _attackerInfoController.text.trim()
          : null,
      suspiciousUrls: _suspiciousUrls,
      suspiciousEmails: _suspiciousEmails,
      suspiciousIps: _suspiciousIps,
      financialLoss: _financialLossController.text.isNotEmpty
          ? double.tryParse(_financialLossController.text)
          : null,
      currency: _currency,
      saveAsDraft: saveAsDraft,
    );
  }

  Future<void> _pickEvidence() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('Choose File'),
            onTap: () => Navigator.pop(context, 'file'),
          ),
        ],
      ),
    );

    if (result == null) return;

    File? file;

    if (result == 'camera') {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) file = File(image.path);
    } else if (result == 'gallery') {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) file = File(image.path);
    } else if (result == 'file') {
      final picked = await FilePicker.platform.pickFiles();
      if (picked != null && picked.files.single.path != null) {
        file = File(picked.files.single.path!);
      }
    }

    if (file != null) {
      setState(() {
        _evidenceFiles.add(file!);
      });
    }
  }

  void _addListItem(List<String> list, String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: _newItemController,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newItemController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newItemController.text.isNotEmpty) {
                setState(() {
                  list.add(_newItemController.text.trim());
                });
              }
              _newItemController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        actions: [
          TextButton(onPressed: _saveAsDraft, child: const Text('Save Draft')),
        ],
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.status == ReportStateStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Report created!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/reports/${state.selectedReport?.id}');
          } else if (state.status == ReportStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error creating report'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _submitReport();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: state.status == ReportStateStatus.creating
                            ? null
                            : details.onStepContinue,
                        child: state.status == ReportStateStatus.creating &&
                                _currentStep == 3
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_currentStep == 3 ? 'Submit' : 'Continue'),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // Step 1: Basic Info
                Step(
                  title: const Text('Basic Information'),
                  subtitle: const Text('Type and description'),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Type
                      Text(
                        'Incident Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ReportType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(_getTypeLabel(type)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedType = type);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Report Title',
                          hintText: 'Brief summary of the incident',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.length < 10) {
                            return 'Title must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Provide detailed information about the incident...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.length < 50) {
                            return 'Description must be at least 50 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Anonymous toggle
                      SwitchListTile(
                        title: const Text('Report Anonymously'),
                        subtitle: const Text(
                          'Your identity will not be linked to this report',
                        ),
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() => _isAnonymous = value);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                // Step 2: Details
                Step(
                  title: const Text('Incident Details'),
                  subtitle: const Text('When and how severe'),
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Severity
                      Text(
                        'Severity Level',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<SeverityLevel>(
                        segments: SeverityLevel.values.map((s) {
                          return ButtonSegment(
                            value: s,
                            label: Text(_getSeverityLabel(s)),
                          );
                        }).toList(),
                        selected: {_selectedSeverity},
                        onSelectionChanged: (selected) {
                          setState(() => _selectedSeverity = selected.first);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Incident Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Incident Date'),
                        subtitle: Text(
                          _incidentDate != null
                              ? '${_incidentDate!.day}/${_incidentDate!.month}/${_incidentDate!.year}'
                              : 'Not specified',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _incidentDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _incidentDate = date);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Affected Systems
                      _buildListSection(
                        title: 'Affected Systems',
                        items: _affectedSystems,
                        onAdd: () => _addListItem(_affectedSystems, 'System'),
                        onRemove: (index) {
                          setState(() => _affectedSystems.removeAt(index));
                        },
                      ),
                      const SizedBox(height: 16),

                      // Financial Loss
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _financialLossController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Financial Loss (if any)',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _currency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                              ),
                              items: ['USD', 'EUR', 'GBP', 'NGN']
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _currency = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Step 3: Threat Information
                Step(
                  title: const Text('Threat Information'),
                  subtitle: const Text('URLs, emails, IPs'),
                  isActive: _currentStep >= 2,
                  state:
                      _currentStep > 2 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Attacker Info
                      TextFormField(
                        controller: _attackerInfoController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Attacker Information (Optional)',
                          hintText:
                              'Any known information about the attacker...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Suspicious URLs
                      _buildListSection(
                        title: 'Suspicious URLs',
                        items: _suspiciousUrls,
                        onAdd: () => _addListItem(_suspiciousUrls, 'URL'),
                        onRemove: (index) {
                          setState(() => _suspiciousUrls.removeAt(index));
                        },
                      ),
                      const SizedBox(height: 16),

                      // Suspicious Emails
                      _buildListSection(
                        title: 'Suspicious Emails',
                        items: _suspiciousEmails,
                        onAdd: () => _addListItem(_suspiciousEmails, 'Email'),
                        onRemove: (index) {
                          setState(() => _suspiciousEmails.removeAt(index));
                        },
                      ),
                      const SizedBox(height: 16),

                      // Suspicious IPs
                      _buildListSection(
                        title: 'Suspicious IP Addresses',
                        items: _suspiciousIps,
                        onAdd: () => _addListItem(_suspiciousIps, 'IP Address'),
                        onRemove: (index) {
                          setState(() => _suspiciousIps.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),

                // Step 4: Evidence
                Step(
                  title: const Text('Evidence'),
                  subtitle: const Text('Upload supporting files'),
                  isActive: _currentStep >= 3,
                  state: StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attach Evidence',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload screenshots, documents, or other evidence. Files are encrypted and securely stored.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Evidence List
                      if (_evidenceFiles.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _evidenceFiles.length,
                          itemBuilder: (context, index) {
                            final file = _evidenceFiles[index];
                            return ListTile(
                              leading: const Icon(Icons.attachment),
                              title: Text(file.path.split('/').last),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _evidenceFiles.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Add Evidence Button
                      OutlinedButton.icon(
                        onPressed: _pickEvidence,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Evidence'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Card
                      Card(
                        color: AppColors.info.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.info),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All uploaded files are encrypted with AES-256 and can only be accessed by authorized personnel.',
                                  style: TextStyle(color: AppColors.info),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        if (items.isEmpty)
          Text(
            'No items added',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                onDeleted: () => onRemove(entry.key),
                deleteIconColor: AppColors.error,
              );
            }).toList(),
          ),
      ],
    );
  }

  String _getTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.phishing:
        return 'Phishing';
      case ReportType.malware:
        return 'Malware';
      case ReportType.identityTheft:
        return 'Identity Theft';
      case ReportType.onlineFraud:
        return 'Online Fraud';
      case ReportType.dataBreach:
        return 'Data Breach';
      case ReportType.ransomware:
        return 'Ransomware';
      case ReportType.socialEngineering:
        return 'Social Engineering';
      case ReportType.ddos:
        return 'DDoS';
      case ReportType.cyberstalking:
        return 'Cyberstalking';
      case ReportType.hacking:
        return 'Hacking';
      case ReportType.other:
        return 'Other';
    }
  }

  String _getSeverityLabel(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }
}
