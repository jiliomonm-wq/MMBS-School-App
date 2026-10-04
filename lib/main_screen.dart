import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'models.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'owner_dashboard.dart';
import 'theme_widgets.dart';

class MainScreen extends StatefulWidget {
  final UserProfile user;
  final String lang;
  final String Function(String) t;
  final VoidCallback onToggleLang, onLogout;

  const MainScreen({
    super.key,
    required this.user,
    required this.lang,
    required this.t,
    required this.onToggleLang,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String t(String k) => widget.t(k);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.role != 'Owner') {
        _checkAndShowAttendanceDialog();
      }
    });
  }

  // ကျောင်းတက်ရောက်မှု Pop-up စစ်ဆေးပြီး ပြသခြင်း
  Future<void> _checkAndShowAttendanceDialog() async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final query = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: widget.user.id)
        .where('date', isEqualTo: todayStr)
        .get();

    if (query.docs.isEmpty && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 48),
                const SizedBox(height: 12),
                Text(
                  widget.lang == 'mm' ? 'နေ့စဉ် ကျောင်းတက်ရောက်မှု' : 'Daily Attendance',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.lang == 'mm'
                      ? 'ဒီကနေ့ ကျောင်းရောက်ရှိကြောင်း အတည်ပြုရန် နှိပ်ပေးပါ'
                      : 'Confirm your attendance for today.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await _firestore.collection('attendance').add({
                      'userId': widget.user.id,
                      'userName': widget.user.name,
                      'role': widget.user.role,
                      'date': todayStr,
                      'timestamp': FieldValue.serverTimestamp(),
                      'status': 'present',
                    });
                    Navigator.pop(c);
                    _snack(widget.lang == 'mm' ? 'တက်ရောက်မှု အတည်ပြုပြီးပါပြီ' : 'Attendance Confirmed ✓', isSuccess: true);
                  },
                  child: Text(widget.lang == 'mm' ? 'တက်ရောက်သည် (Confirm)' : 'Confirm Present'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<String?> pickImageFromStorage() async {
    try {
      final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (img != null) {
        final bytes = await img.readAsBytes();
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
    } catch (e) {
      _snack('Image picker error: $e');
    }
    return null;
  }

  Future<void> assignTask(String title, String subject, String targetGrade, DateTime dueDate, String imageUrl) async {
    try {
      final docRef = _firestore.collection('tasks').doc();
      final newTask = SchoolTask(
        id: docRef.id,
        title: title,
        subject: subject,
        targetGrade: targetGrade,
        teacherId: widget.user.id,
        teacherName: widget.user.name,
        dueDate: dueDate,
        taskImageUrl: imageUrl,
      );
      await docRef.set(newTask.toMap());
      _snack('${t('assign_task')} ✓', isSuccess: true);
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> submitTask(String taskId, String answer, String studentName, String imageUrl) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'submitted',
        'submission': answer,
        'submittedBy': studentName,
        'submissionImageUrl': imageUrl,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      _snack('${t('submit_task')} ✓', isSuccess: true);
    } catch (e) {
      _snack('Error: $e');
    }
  }

  Future<void> addComplaint(String title, String desc, String role, String name) async {
    try {
      final comp = Complaint(title: title, desc: desc, fromRole: role, fromName: name, createdAt: DateTime.now());
      await _firestore.collection('complaints').add(comp.toMap());
      _snack('${t('submit')} ✓', isSuccess: true);
    } catch (e) {
      _snack('Error: $e');
    }
  }

  // Owner Announcement အသစ်တင်ခြင်း (Pin Post & Auto Expire Support)
  Future<void> addAnnouncement(String title, String content, String target, {bool isPinned = false}) async {
    try {
      final ann = Announcement(
        title: title,
        content: content,
        target: target,
        date: DateTime.now(),
        isPinned: isPinned,
      );
      await _firestore.collection('announcements').add(ann.toMap());
      _snack('${t('create_announcement')} ✓', isSuccess: true);
    } catch (e) {
      _snack('Error: $e');
    }
  }

  void _snack(String m, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tasks').snapshots(),
      builder: (context, taskSnapshot) {
        final tasks = taskSnapshot.hasData
            ? taskSnapshot.data!.docs.map((d) => SchoolTask.fromFirestore(d)).toList()
            : <SchoolTask>[];

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('announcements').snapshots(),
          builder: (context, annSnapshot) {
            // ၁ ရက် (၂၄ နာရီ) ကျော်ပါက Auto ပျောက်ပြီး Pin ထောက်ထားပါက အမြဲထိပ်ဆုံးတွင် ကပ်နေစေခြင်း
            final now = DateTime.now();
            final rawAnnouncements = annSnapshot.hasData
                ? annSnapshot.data!.docs.map((d) => Announcement.fromFirestore(d)).toList()
                : <Announcement>[];

            final filteredAnnouncements = rawAnnouncements.where((a) {
              if (widget.user.role == 'Owner') return true; // Owner သည် အားလုံး မြင်နိုင်သည်
              if (a.isPinned) return true; // Pin ထောက်ထားပါက အမြဲမြင်ရမည်
              return now.difference(a.date).inHours < 24; // Pin မထောက်ထားပါက ၂၄ နာရီအတွင်းသာ ပြမည်
            }).toList();

            // Pin ထောက်ထားသော သတင်းများကို ထိပ်ဆုံးသို့ တင်ခြင်း
            filteredAnnouncements.sort((a, b) {
              if (a.isPinned && !b.isPinned) return -1;
              if (!a.isPinned && b.isPinned) return 1;
              return b.date.compareTo(a.date);
            });

            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('complaints').snapshots(),
              builder: (context, compSnapshot) {
                final complaints = compSnapshot.hasData
                    ? compSnapshot.data!.docs.map((d) => Complaint.fromFirestore(d)).toList()
                    : <Complaint>[];

                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, userSnapshot) {
                    final allUsers = userSnapshot.hasData
                        ? userSnapshot.data!.docs.map((d) => UserProfile.fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList()
                        : <UserProfile>[];

                    Widget page;
                    final role = widget.user.role;

                    if (role == 'Student') {
                      page = StudentDashboard(
                        user: widget.user,
                        lang: widget.lang,
                        t: t,
                        onToggleLang: widget.onToggleLang,
                        announcements: filteredAnnouncements,
                        tasks: tasks,
                        onComplain: () => _showComplaint('Student'),
                        onSubmitTask: (taskId, ans, name, _) async {
                          final img = await pickImageFromStorage();
                          submitTask(taskId, ans, name, img ?? '');
                        },
                        onUpdateAvatar: (url) {},
                        onLogout: widget.onLogout,
                      );
                    } else if (role == 'Teacher') {
                      page = TeacherDashboard(
                        user: widget.user,
                        lang: widget.lang,
                        t: t,
                        onToggleLang: widget.onToggleLang,
                        announcements: filteredAnnouncements,
                        tasks: tasks,
                        onComplain: () => _showComplaint('Teacher'),
                        onAssignTask: (title, sub, grade, date, _) async {
                          final img = await pickImageFromStorage();
                          assignTask(title, sub, grade, date, img ?? '');
                        },
                        onUpdateAvatar: (url) {},
                        onLogout: widget.onLogout,
                      );
                    } else {
                      page = OwnerDashboard(
                        user: widget.user,
                        lang: widget.lang,
                        t: t,
                        onToggleLang: widget.onToggleLang,
                        complaints: complaints,
                        announcements: rawAnnouncements,
                        tasks: tasks,
                        allUsers: allUsers,
                        onAddAnnouncement: (title, desc, target) {
                          _showOwnerAnnouncementDialog();
                        },
                        onUpdateAvatar: (url) {},
                        onUpdateUser: (u) async {
                          await _firestore.collection('users').doc(u.id).update(u.toMap());
                        },
                        onAddUser: (u) {},
                        onLogout: widget.onLogout,
                      );
                    }

                    return LightBackground(child: page);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Owner သတင်းတင် Dialog (Pin Post ပါဝင်သည်)
  void _showOwnerAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String target = 'All';
    bool isPinned = false;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('create_announcement'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: t('title'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 3, decoration: InputDecoration(labelText: t('desc'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: target,
                  items: ['All', 'Student', 'Teacher'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setDialogState(() => target = v ?? 'All'),
                  decoration: InputDecoration(labelText: t('target'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: Text(widget.lang == 'mm' ? 'သတင်းကို Pin ထောက်ထားမည် (မပျောက်စေရန်)' : 'Pin this announcement'),
                  value: isPinned,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setDialogState(() => isPinned = v ?? false),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(c), child: Text(t('cancel'))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty) {
                          addAnnouncement(titleCtrl.text, descCtrl.text, target, isPinned: isPinned);
                          Navigator.pop(c);
                        }
                      },
                      child: Text(t('submit')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComplaint(String role) {
    final tc = TextEditingController();
    final dc = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(t('complaint'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            TextField(controller: tc, decoration: InputDecoration(labelText: t('title'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 10),
            TextField(controller: dc, maxLines: 3, decoration: InputDecoration(labelText: t('desc'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(c), child: Text(t('cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  if (tc.text.isNotEmpty) {
                    addComplaint(tc.text, dc.text, role, widget.user.name);
                    Navigator.pop(c);
                  }
                },
                child: Text(t('submit')),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
