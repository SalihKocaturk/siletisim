import 'dart:math';
import 'package:bbtproje/domain/cubits/activity_cubit.dart';
import 'package:bbtproje/domain/cubits/auth_cubit.dart';
import 'package:bbtproje/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../models/meeting.dart';
import '../../models/project.dart';
import '../../models/task.dart';
import '../../service/google_calendar_services.dart';
import '../widgets/side_panel.dart';
import '../widgets/top_bar.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List<Project> firebaseProjects = [];

  List<String> possibleNames = []; // Başta boş
  String phName = "";
  String accessToken = "";
  @override
  void initState() {
    super.initState();

    _loadOtherUsers();
    final state = getIt<AuthCubit>().state as AuthLoggedIn;
    phName = state.name;
    accessToken = state.accessToken!;
    getIt<ActivityCubit>().fetchAllDataForUser(state.name);
  }

  void _loadOtherUsers() async {
    if (getIt<AuthCubit>().state is AuthLoggedIn) {
      final currentState = getIt<AuthCubit>().state as AuthLoggedIn;
      final currentUid = currentState.uid;
      final otherUsers = await getIt<ActivityCubit>().fetchUsers(currentUid);

      setState(() {
        possibleNames = otherUsers.map((u) => u.name).toList();
      });
      print(otherUsers.map((u) => u.name).toList());
    } else {
      context.go("/");
    }
  }

  final List<String> projects = ['Ana Proje', 'İK Takibi', 'Kampanya Yönetimi'];
  int selectedIndex = -1;
  final TextEditingController _projectNameController = TextEditingController(
    text: 'Ana Proje',
  );
  final List<Map<String, dynamic>> meetings = []; // kişi + tarih

  final statusColors = {
    'Yapılmakta': Colors.orange,
    'Tamamlandı': Colors.green,
    'Başlanmadı': Colors.red,
  };

  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(200),
      random.nextInt(200),
      random.nextInt(200),
    );
  }

  double _calculateProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.status == 'Tamamlandı').length;
    return completed / tasks.length;
  }

  final Color avatarBg =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];
  void _showMeetingDialog() async {
    String? selectedName;
    DateTime? selectedDate;
    final descriptionController = TextEditingController(); // en başa ekle

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Yeni Görüşme Ekle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedName,
                    hint: const Text('Kişi seçiniz'),
                    items:
                        possibleNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => selectedName = value),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Tarih seçilmedi'
                              : '${selectedDate?.toLocal()}'.split('.')[0],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 1),
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        child: const Text('Tarih Seç'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (isteğe bağlı)',
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedName == null || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kişi ve tarih seçiniz')),
                      );
                      return;
                    }
                    final meeting = Meeting(
                      name: selectedName!,
                      dateTime: selectedDate!,
                      creatorName: phName,
                      description: descriptionController.text.trim(),
                    );

                    await getIt<ActivityCubit>().addMeeting(meeting);
                    Navigator.pop(context);
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void showFullProjectAddDialog() {
  //   final nameController = TextEditingController();
  //   final descController = TextEditingController();
  //   final taskTitleController = TextEditingController();
  //   String? selectedManager;
  //   String? selectedStatus;
  //   DateTime? startDate;
  //   DateTime? endDate;

  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Yeni Proje Ekle'),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: nameController,
  //                     decoration: const InputDecoration(labelText: 'Proje Adı'),
  //                   ),
  //                   TextField(
  //                     controller: descController,
  //                     decoration: const InputDecoration(labelText: 'Açıklama'),
  //                   ),
  //                   DropdownButtonFormField<String>(
  //                     value: selectedManager,
  //                     hint: const Text('Sorumlu Seç'),
  //                     items:
  //                         possibleNames.map((name) {
  //                           return DropdownMenuItem(
  //                             value: name,
  //                             child: Text(name),
  //                           );
  //                         }).toList(),
  //                     onChanged: (val) => setState(() => selectedManager = val),
  //                   ),
  //                   DropdownButtonFormField<String>(
  //                     value: selectedStatus,
  //                     hint: const Text('Durum Seç'),
  //                     items:
  //                         ['Başlamadı', 'Devam Ediyor', 'Tamamlandı']
  //                             .map(
  //                               (status) => DropdownMenuItem(
  //                                 value: status,
  //                                 child: Text(status),
  //                               ),
  //                             )
  //                             .toList(),
  //                     onChanged: (val) => setState(() => selectedStatus = val),
  //                   ),
  //                   const SizedBox(height: 12),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           startDate == null
  //                               ? 'Başlangıç tarihi seçilmedi'
  //                               : 'Başlangıç: ${startDate!.toLocal()}'.split(
  //                                 ' ',
  //                               )[0],
  //                         ),
  //                       ),
  //                       TextButton(
  //                         onPressed: () async {
  //                           final picked = await showDatePicker(
  //                             context: context,
  //                             initialDate: DateTime.now(),
  //                             firstDate: DateTime(2023),
  //                             lastDate: DateTime(2100),
  //                           );
  //                           if (picked != null) {
  //                             setState(() => startDate = picked);
  //                           }
  //                         },
  //                         child: const Text('Seç'),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           endDate == null
  //                               ? 'Bitiş tarihi seçilmedi'
  //                               : 'Bitiş: ${endDate!.toLocal()}'.split(' ')[0],
  //                         ),
  //                       ),
  //                       TextButton(
  //                         onPressed: () async {
  //                           final picked = await showDatePicker(
  //                             context: context,
  //                             initialDate: DateTime.now(),
  //                             firstDate: DateTime(2023),
  //                             lastDate: DateTime(2100),
  //                           );
  //                           if (picked != null) {
  //                             setState(() => endDate = picked);
  //                           }
  //                         },
  //                         child: const Text('Seç'),
  //                       ),
  //                     ],
  //                   ),
  //                   const Divider(height: 32),
  //                   const Text(
  //                     'İlk Görev (opsiyonel)',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                   TextField(
  //                     controller: taskTitleController,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Görev Başlığı',
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text('İptal'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   final name = nameController.text.trim();
  //                   final desc = descController.text.trim();
  //                   final taskTitle = taskTitleController.text.trim();

  //                   if (name.isEmpty ||
  //                       desc.isEmpty ||
  //                       selectedManager == null ||
  //                       selectedStatus == null ||
  //                       startDate == null ||
  //                       endDate == null) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text('Lütfen tüm zorunlu alanları doldurun'),
  //                       ),
  //                     );
  //                     return;
  //                   }

  //                   final project = Project(
  //                     id: '', // Firestore'da otomatik oluşur
  //                     name: name,
  //                     description: desc,
  //                     manager: selectedManager!,
  //                     status: selectedStatus!,
  //                     startDate: startDate!.toIso8601String(),
  //                     endDate: endDate!.toIso8601String(),
  //                     tasks:
  //                         taskTitle.isNotEmpty
  //                             ? [
  //                               Task(
  //                                 title: taskTitle,
  //                                 assignee: selectedManager!,
  //                                 status: 'Yapılmakta',
  //                                 dueDate: startDate!.toIso8601String(),
  //                               ),
  //                             ]
  //                             : [],
  //                   );

  //                   await getIt<ActivityCubit>().addProject(
  //                     project,
  //                   ); // ✅ cubit'e taşı
  //                   Navigator.pop(context);

  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('Proje başarıyla eklendi')),
  //                   );
  //                 },
  //                 child: const Text('Kaydet'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showActivityOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Görüşme Ekle'),
                onTap: () {
                  Navigator.pop(context);
                  _showMeetingDialog();
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.folder_copy),
              //   title: const Text('Proje Ekle'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     showFullProjectAddDialog();
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  void _editTask(String projectId, int taskIndex, Task oldTask) {
    final titleController = TextEditingController(text: oldTask.title);
    final assigneeController = TextEditingController(text: oldTask.assignee);
    final dueDateController = TextEditingController(text: oldTask.dueDate);
    final statusOptions = statusColors.keys.toList();
    String selectedStatus = oldTask.status;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Görev Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Görev'),
              ),
              TextField(
                controller: assigneeController,
                decoration: const InputDecoration(labelText: 'Sorumlu'),
              ),
              DropdownButton<String>(
                value: selectedStatus,
                items:
                    statusOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedStatus = val;
                  }
                },
              ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Son Tarih'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                final updatedTask = Task(
                  title: titleController.text.trim(),
                  assignee: assigneeController.text.trim(),
                  status: selectedStatus,
                  dueDate: dueDateController.text.trim(),
                );

                await getIt<ActivityCubit>().updateTaskInProject(
                  projectId: projectId,
                  oldTask: oldTask,
                  newTask: updatedTask,
                );

                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // void _showAddTaskDialog(String projectId) {
  //   final titleController = TextEditingController();
  //   String? selectedAssignee;
  //   DateTime? dueDate;

  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Yeni Görev Ekle'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: titleController,
  //                   decoration: const InputDecoration(labelText: 'Başlık'),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 DropdownButtonFormField<String>(
  //                   value: selectedAssignee,
  //                   hint: const Text('Sorumlu Seç'),
  //                   items:
  //                       possibleNames.map((name) {
  //                         return DropdownMenuItem(
  //                           value: name,
  //                           child: Text(name),
  //                         );
  //                       }).toList(),
  //                   onChanged: (val) => setState(() => selectedAssignee = val),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         dueDate == null
  //                             ? 'Tarih seçilmedi'
  //                             : '${dueDate?.toLocal()}'.split(' ')[0],
  //                       ),
  //                     ),
  //                     TextButton(
  //                       onPressed: () async {
  //                         final picked = await showDatePicker(
  //                           context: context,
  //                           initialDate: DateTime.now(),
  //                           firstDate: DateTime.now(),
  //                           lastDate: DateTime.now().add(
  //                             const Duration(days: 365),
  //                           ),
  //                         );
  //                         if (picked != null) {
  //                           setState(() => dueDate = picked);
  //                         }
  //                       },
  //                       child: const Text('Tarih Seç'),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text('İptal'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   if (titleController.text.isEmpty ||
  //                       selectedAssignee == null ||
  //                       dueDate == null) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(content: Text('Tüm alanları doldurun')),
  //                     );
  //                     return;
  //                   }

  //                   final task = Task(
  //                     title: titleController.text.trim(),
  //                     assignee: selectedAssignee!,
  //                     status: 'Yapılmakta',
  //                     dueDate: '${dueDate!.toLocal()}'.split(' ')[0],
  //                   );

  //                   await getIt<ActivityCubit>().addTaskToProject(
  //                     projectId,
  //                     task,
  //                   );

  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Ekle'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // void _showAddTaskDialog(String projectId) {
  //   final titleController = TextEditingController();
  //   String? selectedAssignee;
  //   DateTime? dueDate;

  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Yeni Görev Ekle'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: titleController,
  //                   decoration: const InputDecoration(labelText: 'Başlık'),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 DropdownButtonFormField<String>(
  //                   value: selectedAssignee,
  //                   hint: const Text('Sorumlu Seç'),
  //                   items:
  //                       possibleNames.map((name) {
  //                         return DropdownMenuItem(
  //                           value: name,
  //                           child: Text(name),
  //                         );
  //                       }).toList(),
  //                   onChanged: (val) => setState(() => selectedAssignee = val),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         dueDate == null
  //                             ? 'Tarih seçilmedi'
  //                             : '${dueDate?.toLocal()}'.split(' ')[0],
  //                       ),
  //                     ),
  //                     TextButton(
  //                       onPressed: () async {
  //                         final picked = await showDatePicker(
  //                           context: context,
  //                           initialDate: DateTime.now(),
  //                           firstDate: DateTime.now(),
  //                           lastDate: DateTime.now().add(
  //                             const Duration(days: 365),
  //                           ),
  //                         );
  //                         if (picked != null) {
  //                           setState(() => dueDate = picked);
  //                         }
  //                       },
  //                       child: const Text('Tarih Seç'),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text('İptal'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   if (titleController.text.isEmpty ||
  //                       selectedAssignee == null ||
  //                       dueDate == null) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(content: Text('Tüm alanları doldurun')),
  //                     );
  //                     return;
  //                   }

  //                   final task = Task(
  //                     title: titleController.text.trim(),
  //                     assignee: selectedAssignee!,
  //                     status: 'Yapılmakta',
  //                     dueDate: '${dueDate!.toLocal()}'.split(' ')[0],
  //                     // projectId: projectId,
  //                   );

  //                   await FirebaseFirestore.instance
  //                       .collection('tasks')
  //                       .add(task.toMap());

  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Ekle'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Örneğin 3 durum:

    return Scaffold(
      body: BlocBuilder<ActivityCubit, ActivityState>(
        bloc: getIt<ActivityCubit>(),
        builder: (context, state) {
          if (state is ActivityInitial) {
            return SizedBox();
          } else if (state is ActivityLoaded) {
            final projects = state.projects;
            final taskList =
                (selectedIndex >= 0 && selectedIndex < projects.length)
                    ? projects[selectedIndex].tasks
                    : [];

            final meetings = state.meetings;

            return Row(
              children: [
                SidePanel(
                  selectedIndex: selectedIndex,
                  onItemSelected:
                      (index) => setState(() => selectedIndex = index),
                  onHomeTapped: () => setState(() => selectedIndex = -1),
                  projects: projects,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(
                        title:
                            selectedIndex == -1
                                ? 'Dashboard'
                                : projects[selectedIndex].name,

                        avatarBg: avatarBg,
                        actions: [
                          IconButton(
                            icon: Icon(Icons.refresh),
                            tooltip: 'Yenile',
                            onPressed: () {
                              final state =
                                  getIt<AuthCubit>().state as AuthLoggedIn;
                              getIt<ActivityCubit>().fetchAllDataForUser(
                                state.name,
                              );
                            },
                          ),
                        ],
                      ),
                      selectedIndex == -1
                          ? Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Projeleriniz',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                _showActivityOptionsDialog();
                                              },
                                              child: Container(
                                                height: 45,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF0073EA,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    '+ Aktivite Ekle',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children:
                                          projects.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            final proj = entry.value;

                                            return GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () => selectedIndex = index,
                                                );
                                              },
                                              child: SizedBox(
                                                width: 250,
                                                height: 180,
                                                child: Card(
                                                  elevation: 3,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          proj.name,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Yönetici: ${proj.manager}',
                                                        ),
                                                        Text(
                                                          'Durum: ${proj.status}',
                                                        ),
                                                        const Spacer(),
                                                        LinearProgressIndicator(
                                                          value:
                                                              _calculateProgress(
                                                                proj.tasks,
                                                              ),
                                                          color: Colors.blue,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '${(_calculateProgress(proj.tasks) * 100).toStringAsFixed(0)}% tamamlandı',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),

                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Açıklama: ${proj.description}',
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 11,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),

                                    SizedBox(height: 20),
                                    const Text(
                                      'Görüşmeleriniz',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children:
                                          meetings.map((meeting) {
                                            return SizedBox(
                                              width: 250,
                                              height: 180,
                                              child: Card(
                                                elevation: 2,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .person_outline,
                                                            color: Colors.blue,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            phName ==
                                                                    meeting.name
                                                                ? meeting
                                                                    .creatorName
                                                                : meeting.name,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            '${meeting.dateTime.toLocal()}'
                                                                .split('.')[0],
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      if (meeting
                                                          .description
                                                          .isNotEmpty)
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Icon(
                                                              Icons.notes,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 6,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                meeting
                                                                    .description,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ElevatedButton.icon(
                                                        onPressed: () {
                                                          final calendarService =
                                                              GoogleCalendarService();
                                                          calendarService.insertEvent(
                                                            title:
                                                                'Görüşme: ${meeting.name}',
                                                            description:
                                                                'Toplantı ${meeting.name} ile: ${meeting.description}',
                                                            startTime:
                                                                meeting
                                                                    .dateTime,
                                                            endTime: meeting
                                                                .dateTime
                                                                .add(
                                                                  const Duration(
                                                                    hours: 1,
                                                                  ),
                                                                ),
                                                            accessToken:
                                                                accessToken,
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.calendar_month,
                                                        ),
                                                        label: const Text(
                                                          "Takvime Ekle",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : Expanded(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,

                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // SizedBox(
                                      //   width: 100,
                                      //   child: InkWell(
                                      //     onTap: () {
                                      //       _showAddTaskDialog(
                                      //         projects[selectedIndex].id,
                                      //       );
                                      //     },
                                      //     child: Container(
                                      //       height: 45,
                                      //       decoration: BoxDecoration(
                                      //         color: const Color(0xFF0073EA),
                                      //         borderRadius:
                                      //             BorderRadius.circular(4),
                                      //       ),
                                      //       child: const Center(
                                      //         child: Text(
                                      //           '+ Görev Ekle',
                                      //           style: TextStyle(
                                      //             color: Colors.white,
                                      //             fontWeight: FontWeight.w600,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // ElevatedButton(
                                      //   onPressed: _addTask,
                                      //   child: const Text('+ Proje Ekle'),
                                      // ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columnSpacing: 0,
                                            dataRowHeight: 48,
                                            headingRowHeight: 48,
                                            columns: const [
                                              DataColumn(label: Text('Görev')),
                                              DataColumn(
                                                label: Text('Sorumlu'),
                                              ),
                                              DataColumn(label: Text('Durum')),
                                              DataColumn(
                                                label: Text('Son Tarih'),
                                              ),
                                              DataColumn(label: Text('İşlem')),
                                            ],
                                            rows: List.generate(taskList.length, (
                                              index,
                                            ) {
                                              double taskColumnWidth;
                                              double taskColumnHeight;
                                              if (screenWidth <= 800) {
                                                taskColumnWidth = 150;
                                                taskColumnHeight = 148;
                                              } else if (screenWidth <= 1200) {
                                                taskColumnWidth = 250;
                                                taskColumnHeight = 96;
                                              } else {
                                                taskColumnWidth = 450;
                                                taskColumnHeight = 48;
                                              }
                                              final task = taskList[index];
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    SizedBox(
                                                      height: taskColumnHeight,
                                                      width: taskColumnWidth,

                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        decoration:
                                                            const BoxDecoration(
                                                              border: Border(
                                                                right: BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ),
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        child: Text(task.title),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      height: 48,
                                                      child: Container(
                                                        width: 150,

                                                        decoration:
                                                            const BoxDecoration(
                                                              border: Border(
                                                                right: BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          task.assignee,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      height: 48,
                                                      width: 150,

                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              statusColors[task
                                                                  .status],
                                                          border: const Border(
                                                            right: BorderSide(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          task.status,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      height: 48,
                                                      width: 150,

                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        decoration:
                                                            const BoxDecoration(
                                                              border: Border(
                                                                right: BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ),
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        child: Text(
                                                          task.dueDate,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      height: 48,
                                                      child: Container(
                                                        width: 150,
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.edit,
                                                                size: 20,
                                                                color:
                                                                    Colors
                                                                        .yellow,
                                                              ),
                                                              onPressed:
                                                                  () => _editTask(
                                                                    projects[selectedIndex]
                                                                        .id,
                                                                    index,
                                                                    task,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                                size: 20,
                                                              ),
                                                              onPressed: () async {
                                                                final projectId =
                                                                    projects[selectedIndex]
                                                                        .id;
                                                                await getIt<
                                                                      ActivityCubit
                                                                    >()
                                                                    .deleteTaskFromProject(
                                                                      projectId:
                                                                          projectId,
                                                                      task:
                                                                          task,
                                                                    );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
