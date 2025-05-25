part of '../cubits/activity_cubit.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<Project> projects;
  final List<Meeting> meetings;
  ActivityLoaded({required this.projects, required this.meetings});
}

class ActivityError extends ActivityState {
  final String error;
  ActivityError(this.error);
}
