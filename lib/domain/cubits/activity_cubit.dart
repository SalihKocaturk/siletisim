import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bbtproje/models/task.dart';
import 'package:bbtproje/models/meeting.dart';

import '../../locator.dart';
import '../../models/app_user.dart';
import '../../models/project.dart';
import 'auth_cubit.dart';

part '../states/activityy_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit() : super(ActivityInitial());

  final List<Task> _tasks = [];
  final List<Meeting> _meetings = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Meeting> get meetings => List.unmodifiable(_meetings);
  Future<List<AppUser>> fetchUsers(String currentUid) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isNotEqualTo: currentUid)
              .get();

      final users =
          query.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
      return users;
    } catch (e) {
      print('🔥 Hata: $e');
      return []; // hata durumunda boş liste dön
    }
  }

  Future<void> deleteTaskFromProject({
    required String projectId,
    required Task task,
  }) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId);

      await ref.update({
        'tasks': FieldValue.arrayRemove([task.toMap()]),
      });
      final currentAuthState = getIt<AuthCubit>().state;
      if (currentAuthState is AuthLoggedIn) {
        final role = currentAuthState.role;
        final name = currentAuthState.name;

        if (role == 'Yönetici') {
          await fetchProjects(); // yöneticiler için tüm verileri al
        } else {
          await fetchAllDataForUser(name); // kullanıcı için filtreli fetch
        }
      }
      await fetchProjects(); // state'i güncelle
    } catch (e) {
      print('❌ deleteTaskFromProject: $e');
    }
  }

  Future<void> updateTaskInProject({
    required String projectId,
    required Task oldTask,
    required Task newTask,
  }) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId);

      await ref.update({
        'tasks': FieldValue.arrayRemove([oldTask.toMap()]),
      });

      await ref.update({
        'tasks': FieldValue.arrayUnion([newTask.toMap()]),
      });

      final currentAuthState = getIt<AuthCubit>().state;
      if (currentAuthState is AuthLoggedIn) {
        final role = currentAuthState.role;
        final name = currentAuthState.name;

        if (role == 'Yönetici') {
          await fetchAllData(); // yöneticiler için tüm verileri al
        } else {
          await fetchAllDataForUser(name); // kullanıcı için filtreli fetch
        }
      }
    } catch (e) {
      print('❌ updateTaskInProject: $e');
    }
  }

  Future<void> fetchProjects() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('projects').get();
      final projects =
          snapshot.docs
              .map((doc) => Project.fromMap(doc.data(), doc.id))
              .toList();
      if (state is ActivityLoaded) {
        final mystate = state as ActivityLoaded;
        emit(ActivityLoaded(projects: projects, meetings: mystate.meetings));
      }
    } catch (e) {
      print('❌ fetchProjects: $e');
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .add(project.toMap());
      await fetchProjects();
    } catch (e) {
      print('❌ addProject: $e');
    }
  }

  Future<void> addTaskToProject(String projectId, Task task) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId);
      await ref.update({
        'tasks': FieldValue.arrayUnion([task.toMap()]),
      });
      await fetchProjects();
    } catch (e) {
      print('❌ addTaskToProject: $e');
    }
  }

  Future<void> fetchAllData() async {
    try {
      final projectSnapshot =
          await FirebaseFirestore.instance.collection('projects').get();
      final meetingSnapshot =
          await FirebaseFirestore.instance.collection('meetings').get();

      final projects =
          projectSnapshot.docs
              .map((doc) => Project.fromMap(doc.data(), doc.id))
              .toList();

      final meetings =
          meetingSnapshot.docs
              .map((doc) => Meeting.fromMap(doc.data(), doc.id))
              .toList();

      emit(ActivityLoaded(projects: projects, meetings: meetings));
    } catch (e) {
      print('❌ fetchAllData: $e');
    }
  }

  Future<void> addMeeting(Meeting meeting) async {
    try {
      await FirebaseFirestore.instance
          .collection('meetings')
          .add(meeting.toMap());
      await fetchMeetings();
    } catch (e) {
      print('❌ addMeeting: $e');
    }
  }

  Future<void> addMeetingForUser(Meeting meeting) async {
    try {
      await FirebaseFirestore.instance
          .collection('meetings')
          .add(meeting.toMap());
      await fetchAllDataForUser(meeting.creatorName);
    } catch (e) {
      print('❌ addMeeting: $e');
    }
  }

  Future<void> fetchAllDataForUser(String name) async {
    try {
      // 1. Kullanıcının yönettiği projeler
      final projectSnapshot =
          await FirebaseFirestore.instance
              .collection('projects')
              .where('manager', isEqualTo: name)
              .get();

      final userProjects =
          projectSnapshot.docs
              .map((doc) => Project.fromMap(doc.data(), doc.id))
              .toList();

      // 2. name == userName olan görüşmeler
      final nameSnapshot =
          await FirebaseFirestore.instance
              .collection('meetings')
              .where('name', isEqualTo: name)
              .get();

      // 3. creatorName == userName olan görüşmeler
      final creatorSnapshot =
          await FirebaseFirestore.instance
              .collection('meetings')
              .where('creatorName', isEqualTo: name)
              .get();

      // 4. Her iki sonucu birleştir, tekrarları engelle
      final allDocs = [...nameSnapshot.docs, ...creatorSnapshot.docs];
      final seen = <String>{};
      final userMeetings =
          allDocs
              .where((doc) => seen.add(doc.id)) // aynı id varsa eklenmez
              .map((doc) => Meeting.fromMap(doc.data(), doc.id))
              .toList();

      emit(ActivityLoaded(projects: userProjects, meetings: userMeetings));
    } catch (e) {
      print('❌ fetchAllDataForUser: $e');
    }
  }

  Future<void> fetchMeetings() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('meetings').get();
      final meetings =
          snapshot.docs
              .map((doc) => Meeting.fromMap(doc.data(), doc.id))
              .toList();
      final mystate = state as ActivityLoaded;

      emit((ActivityLoaded(projects: mystate.projects, meetings: meetings)));
    } catch (e) {
      print('❌ fetchMeetings: $e');
    }
  }

  // Future<void> fetchMeetings() async {
  //   try {
  //     final snapshot =
  //         await FirebaseFirestore.instance.collection('meetings').get();
  //     final meetings =
  //         snapshot.docs
  //             .map((doc) => Meeting.fromMap(doc.data(), doc.id))
  //             .toList();
  //     emit(state.copyWith(meetings: meetings));
  //   } catch (e) {
  //     print('❌ fetchMeetings: $e');
  //   }
  // }

  // Future<void> addMeeting(Meeting meeting) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('meetings')
  //         .add(meeting.toMap());
  //     await fetchMeetings();
  //   } catch (e) {
  //     print('❌ addMeeting: $e');
  //   }
  // }
}
