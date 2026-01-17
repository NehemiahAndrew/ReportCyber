import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/create_report_usecase.dart';
import '../../domain/usecases/get_my_reports_usecase.dart';
import '../../domain/usecases/get_report_by_id_usecase.dart';
import '../../domain/usecases/get_reports_usecase.dart';
import '../../domain/usecases/submit_report_usecase.dart';
import '../../domain/usecases/upload_evidence_usecase.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetReportsUseCase getReportsUseCase;
  final GetMyReportsUseCase getMyReportsUseCase;
  final GetReportByIdUseCase getReportByIdUseCase;
  final CreateReportUseCase createReportUseCase;
  final SubmitReportUseCase submitReportUseCase;
  final UploadEvidenceUseCase uploadEvidenceUseCase;
  final ReportRepository reportRepository;

  ReportBloc({
    required this.getReportsUseCase,
    required this.getMyReportsUseCase,
    required this.getReportByIdUseCase,
    required this.createReportUseCase,
    required this.submitReportUseCase,
    required this.uploadEvidenceUseCase,
    required this.reportRepository,
  }) : super(ReportState.initial()) {
    on<LoadReports>(_onLoadReports);
    on<LoadMyReports>(_onLoadMyReports);
    on<LoadReportDetails>(_onLoadReportDetails);
    on<CreateReport>(_onCreateReport);
    on<UpdateReport>(_onUpdateReport);
    on<SubmitReport>(_onSubmitReport);
    on<DeleteReport>(_onDeleteReport);
    on<UploadEvidence>(_onUploadEvidence);
    on<DeleteEvidence>(_onDeleteEvidence);
    on<UpvoteReport>(_onUpvoteReport);
    on<DownvoteReport>(_onDownvoteReport);
    on<SaveDraftLocally>(_onSaveDraftLocally);
    on<LoadLocalDraft>(_onLoadLocalDraft);
    on<ClearReportState>(_onClearReportState);
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportState> emit,
  ) async {
    if (event.page == 1 || event.refresh) {
      emit(state.loading());
    } else {
      emit(state.loadingMore());
    }

    try {
      final result = await getReportsUseCase(
        page: event.page,
        limit: event.limit,
        type: event.type,
        status: event.status,
        severity: event.severity,
        search: event.search,
      );

      emit(
        state.loaded(
          reports: result.reports,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalCount: result.totalCount,
          hasNextPage: result.hasNextPage,
          append: event.page > 1 && !event.refresh,
        ),
      );
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onLoadMyReports(
    LoadMyReports event,
    Emitter<ReportState> emit,
  ) async {
    if (event.page == 1) {
      emit(state.loading());
    } else {
      emit(state.loadingMore());
    }

    try {
      final result = await getMyReportsUseCase(
        page: event.page,
        status: event.status,
      );

      emit(
        state.loaded(
          reports: result.reports,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          totalCount: result.totalCount,
          hasNextPage: result.hasNextPage,
          append: event.page > 1,
        ),
      );
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onLoadReportDetails(
    LoadReportDetails event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.loading());

    try {
      final report = await getReportByIdUseCase(event.reportId);
      if (report != null) {
        emit(state.withSelectedReport(report));
      } else {
        emit(state.error(message: 'Report not found'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onCreateReport(
    CreateReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.creating());

    try {
      final result = await createReportUseCase(event.params);

      if (result.success && result.report != null) {
        emit(state.created(report: result.report!, message: result.message));
      } else {
        emit(state.error(message: result.error ?? 'Failed to create report'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onUpdateReport(
    UpdateReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStateStatus.updating));

    try {
      final result = await reportRepository.updateReport(
        event.reportId,
        event.params,
      );

      if (result.success && result.report != null) {
        emit(
          state.copyWith(
            status: ReportStateStatus.updated,
            selectedReport: result.report,
            successMessage: 'Report updated successfully',
          ),
        );
      } else {
        emit(state.error(message: result.error ?? 'Failed to update report'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onSubmitReport(
    SubmitReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.submitting());

    try {
      final result = await submitReportUseCase(event.reportId);

      if (result.success && result.report != null) {
        emit(state.submitted(report: result.report!, message: result.message));
      } else {
        emit(state.error(message: result.error ?? 'Failed to submit report'));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onDeleteReport(
    DeleteReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStateStatus.deleting));

    try {
      await reportRepository.deleteReport(event.reportId);

      // Remove from local list
      final updatedReports = state.reports
          .where((r) => r.id != event.reportId)
          .toList();

      emit(
        state.copyWith(
          status: ReportStateStatus.deleted,
          reports: updatedReports,
          successMessage: 'Report deleted successfully',
        ),
      );
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onUploadEvidence(
    UploadEvidence event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.uploading());

    try {
      final evidence = await uploadEvidenceUseCase(
        reportId: event.reportId,
        file: event.file,
      );

      // Update selected report with new evidence
      if (state.selectedReport != null) {
        final updatedReport = state.selectedReport!.copyWith(
          evidence: [...state.selectedReport!.evidence, evidence],
        );
        emit(
          state.copyWith(
            status: ReportStateStatus.loaded,
            selectedReport: updatedReport,
            successMessage: 'Evidence uploaded successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ReportStateStatus.loaded,
            successMessage: 'Evidence uploaded successfully',
          ),
        );
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onDeleteEvidence(
    DeleteEvidence event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await reportRepository.deleteEvidence(event.reportId, event.evidenceId);

      // Update selected report
      if (state.selectedReport != null) {
        final updatedEvidence = state.selectedReport!.evidence
            .where((e) => e.id != event.evidenceId)
            .toList();
        final updatedReport = state.selectedReport!.copyWith(
          evidence: updatedEvidence,
        );
        emit(
          state.copyWith(
            selectedReport: updatedReport,
            successMessage: 'Evidence deleted successfully',
          ),
        );
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onUpvoteReport(
    UpvoteReport event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await reportRepository.upvoteReport(event.reportId);

      // Update local state
      if (state.selectedReport?.id == event.reportId) {
        final updatedReport = state.selectedReport!.copyWith(
          upvotes: state.selectedReport!.upvotes + 1,
          hasUpvoted: true,
        );
        emit(state.copyWith(selectedReport: updatedReport));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onDownvoteReport(
    DownvoteReport event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await reportRepository.downvoteReport(event.reportId);

      // Update local state
      if (state.selectedReport?.id == event.reportId) {
        final updatedReport = state.selectedReport!.copyWith(
          downvotes: state.selectedReport!.downvotes + 1,
          hasDownvoted: true,
        );
        emit(state.copyWith(selectedReport: updatedReport));
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onSaveDraftLocally(
    SaveDraftLocally event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await reportRepository.saveDraftLocally(event.report);
      emit(state.withDraft(event.report));
    } catch (e) {
      // Silent fail for local draft save
    }
  }

  Future<void> _onLoadLocalDraft(
    LoadLocalDraft event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final draft = await reportRepository.getLocalDraft();
      if (draft != null) {
        emit(state.withDraft(draft));
      }
    } catch (e) {
      // Silent fail for local draft load
    }
  }

  void _onClearReportState(ClearReportState event, Emitter<ReportState> emit) {
    emit(state.clearMessages());
  }
}
