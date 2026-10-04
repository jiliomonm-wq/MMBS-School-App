import 'package:flutter/material.dart';
import 'models.dart';
import 'theme_widgets.dart';

// ============================================================================
// 7. STUDENT DASHBOARD
// ============================================================================
class StudentDashboard extends StatefulWidget {
  final UserProfile user; final String lang; final String Function(String) t;
  final VoidCallback onToggleLang;
  final List<Announcement> announcements; final List<SchoolTask> tasks;
  final VoidCallback onComplain;
  final Function(String, String, String, String) onSubmitTask;
  final Function(String) onUpdateAvatar;
  final VoidCallback onLogout;
  const StudentDashboard({super.key, required this.user, required this.lang, required this.t, required this.onToggleLang, required this.announcements, required this.tasks, required this.onComplain, required this.onSubmitTask, required this.onUpdateAvatar, required this.onLogout});
  @override State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _tasks(), _profile()];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(widget.t('dashboard'), widget.onToggleLang, widget.t('lang'), widget.onLogout, widget.t('logout')),
      body: pages[_i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i, onDestinationSelected: (v) => setState(() => _i = v),
        backgroundColor: Colors.white.withOpacity(0.7),
        indicatorColor: AppColors.primary.withOpacity(0.15),
        surfaceTintColor: Colors.transparent, elevation: 0, height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined, color: AppColors.textSecondary, size: 22), selectedIcon: Icon(Icons.home, color: AppColors.primary, size: 22), label: 'Home'),
          NavigationDestination(icon: const Icon(Icons.assignment_outlined, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.assignment, color: AppColors.primary, size: 22), label: widget.t('tasks')),
          NavigationDestination(icon: const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.person, color: AppColors.primary, size: 22), label: widget.t('profile')),
        ],
      ),
    );
  }

  Widget _home() {
    final anns = widget.announcements.where((a) => a.target == 'all' || a.target == 'student').toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      buildGlassHeader(widget.lang == 'en' ? 'Hello 👋' : 'မင်္ဂလာပါ 👋', widget.user.name, '${widget.user.role} · ${widget.user.className}', widget.user.avatarUrl),
      const SizedBox(height: 16),
      buildSectionTitle(widget.t('performance')),
      Row(children: [
        Expanded(child: buildGlassStat('GPA', '3.8', Icons.star, AppColors.warn)),
        const SizedBox(width: 10),
        Expanded(child: buildGlassStat(widget.t('attendance'), '${(widget.user.attendanceRate * 100).toInt()}%', Icons.check_circle, AppColors.success)),
      ]),
      const SizedBox(height: 16),
      buildSectionTitle(widget.t('news')),
      if (anns.isEmpty) buildEmptyState(widget.t('no_data'))
      else ...anns.map((a) => buildNewsCard(a.title, a.content)).toList(),
      const SizedBox(height: 16),
      buildActionCard(widget.t('complaint'), Icons.report_problem, AppColors.danger, widget.onComplain),
    ]);
  }

  Widget _tasks() {
    final list = widget.tasks.where((t) => t.targetGrade == widget.user.className).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      buildSectionTitle(widget.t('my_grade_tasks') + ' · ${widget.user.className}'),
      if (list.isEmpty) buildEmptyState(widget.t('no_data'))
      else ...list.map((task) => _glassTaskCard(task)).toList(),
    ]);
  }

  Widget _glassTaskCard(SchoolTask task) {
    final submitted = task.status == 'submitted' && task.submittedBy == widget.user.name;
    final overdue = task.dueDate.isBefore(DateTime.now()) && !submitted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: submitted ? AppColors.success.withOpacity(0.15) : (overdue ? AppColors.danger.withOpacity(0.15) : AppColors.warn.withOpacity(0.15)), borderRadius: BorderRadius.circular(8)),
              child: Text(submitted ? widget.t('submitted') : (overdue ? widget.t('overdue') : widget.t('pending')), style: TextStyle(color: submitted ? AppColors.success : (overdue ? AppColors.danger : AppColors.warn), fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 8),
          buildMiniRow(Icons.book, '${widget.t('subject')}: ${task.subject}'),
          buildMiniRow(Icons.person, task.teacherName),
          buildMiniRow(Icons.calendar_today, '${widget.t('due_date')}: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}'),
          if (task.taskImageUrl.isNotEmpty) ...[const SizedBox(height: 10), safeNetworkImage(task.taskImageUrl, height: 100, width: double.infinity)],
          if (submitted && task.submission.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.t('your_answer'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(task.submission, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
                if (task.submissionImageUrl.isNotEmpty) ...[const SizedBox(height: 6), safeNetworkImage(task.submissionImageUrl, height: 60, width: double.infinity)],
              ]),
            ),
          ],
          if (!submitted) ...[const SizedBox(height: 12), SizedBox(width: double.infinity, child: GestureDetector(
            onTap: () => _submitDialog(task.id),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.purple]), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(widget.t('submit_task'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            ),
          ))],
        ]),
      ),
    );
  }

  void _submitDialog(String taskId) {
    final c = TextEditingController(); String? imgUrl;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.t('submit_task'), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 14),
        TextField(controller: c, style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(labelText: widget.t('your_answer'), labelStyle: const TextStyle(color: AppColors.textSecondary), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))), maxLines: 3),
        const SizedBox(height: 12),
        GestureDetector(onTap: () => ss(() => imgUrl = 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?auto=format&fit=crop&w=300&q=80'),
          child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(children: [
              Icon(imgUrl == null ? Icons.camera_alt : Icons.check_circle, color: imgUrl == null ? AppColors.primary : AppColors.success, size: 28),
              const SizedBox(height: 6),
              Text(imgUrl == null ? widget.t('attach_image') : widget.t('uploaded'), style: TextStyle(color: imgUrl == null ? AppColors.primary : AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
              if (imgUrl != null) ...[const SizedBox(height: 6), safeNetworkImage(imgUrl!, height: 50, width: 50)],
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(widget.t('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(width: 8),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () { if (c.text.isNotEmpty || imgUrl != null) { widget.onSubmitTask(taskId, c.text, widget.user.name, imgUrl ?? ''); Navigator.pop(ctx); } }, child: Text(widget.t('submit'))),
        ]),
      ])),
    )));
  }

  Widget _profile() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SizedBox(height: 10),
      Center(child: Column(children: [
        GestureDetector(
          onTap: _showPicDialog,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.purple, AppColors.accent3])),
            child: CircleAvatar(radius: 48, backgroundColor: Colors.white,
              backgroundImage: widget.user.avatarUrl.isNotEmpty ? NetworkImage(widget.user.avatarUrl) : null,
              child: widget.user.avatarUrl.isEmpty ? Text(widget.user.name[0], style: const TextStyle(fontSize: 35, color: AppColors.primary, fontWeight: FontWeight.bold)) : null),
          ),
        ),
        const SizedBox(height: 12),
        Text(widget.user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Text('${widget.user.role} · ${widget.user.className}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))),
      ])),
      const SizedBox(height: 24),
      buildSectionTitle(widget.t('personal_info')),
      buildGlassOpt(Icons.badge, 'ID', widget.user.id),
      buildGlassOpt(Icons.email_outlined, widget.t('email'), widget.user.email),
      buildGlassOpt(Icons.school, widget.t('class'), widget.user.className),
      buildGlassOpt(Icons.cake_outlined, widget.t('age'), '${widget.user.age}'),
      buildGlassOpt(Icons.phone_outlined, widget.t('contact'), widget.user.contact),
      buildGlassOpt(Icons.location_on_outlined, widget.t('location'), widget.user.location),
      buildGlassOpt(Icons.star_outline, widget.t('skills'), widget.user.skills.isEmpty ? '-' : widget.user.skills),
      buildGlassOpt(Icons.event_busy, widget.t('leave_days'), '${widget.user.leaveDays}'),
    ]);
  }

  void _showPicDialog() {
    showDialog(context: context, builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.t('change_pic'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ListTile(leading: const Icon(Icons.camera_alt, color: AppColors.primary, size: 22), title: const Text('Take Photo', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)), onTap: () { widget.onUpdateAvatar('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80'); Navigator.pop(c); }),
        ListTile(leading: const Icon(Icons.photo_library, color: AppColors.primary, size: 22), title: const Text('Gallery', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)), onTap: () { widget.onUpdateAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'); Navigator.pop(c); }),
      ])),
    ));
  }
}
