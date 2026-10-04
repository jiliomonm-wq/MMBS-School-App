import 'package:flutter/material.dart';
import 'models.dart';
import 'theme_widgets.dart';

// ============================================================================
// 8. TEACHER DASHBOARD
// ============================================================================
class TeacherDashboard extends StatefulWidget {
  final UserProfile user; final String lang; final String Function(String) t;
  final VoidCallback onToggleLang;
  final List<Announcement> announcements; final List<SchoolTask> tasks;
  final VoidCallback onComplain;
  final Function(String, String, String, DateTime, String) onAssignTask;
  final Function(String) onUpdateAvatar;
  final VoidCallback onLogout;
  const TeacherDashboard({super.key, required this.user, required this.lang, required this.t, required this.onToggleLang, required this.announcements, required this.tasks, required this.onComplain, required this.onAssignTask, required this.onUpdateAvatar, required this.onLogout});
  @override State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _assign(), _subs(), _profile()];
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
          NavigationDestination(icon: const Icon(Icons.add_task_outlined, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.add_task, color: AppColors.primary, size: 22), label: widget.t('assign_task')),
          NavigationDestination(icon: const Icon(Icons.fact_check_outlined, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.fact_check, color: AppColors.primary, size: 22), label: widget.t('submissions')),
          NavigationDestination(icon: const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.person, color: AppColors.primary, size: 22), label: widget.t('profile')),
        ],
      ),
    );
  }

  Widget _home() {
    final anns = widget.announcements.where((a) => a.target == 'all' || a.target == 'teacher').toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      buildGlassHeader(widget.lang == 'en' ? 'Good Morning,' : 'မင်္ဂလာမနက်ခင်းပါ၊', widget.user.name, '${widget.user.role} · ${widget.user.className}', widget.user.avatarUrl),
      const SizedBox(height: 16),
      buildSectionTitle(widget.t('news')),
      if (anns.isEmpty) buildEmptyState(widget.t('no_data'))
      else ...anns.map((a) => buildNewsCard(a.title, a.content)).toList(),
      const SizedBox(height: 16),
      buildActionCard(widget.t('complaint'), Icons.report_problem, AppColors.danger, widget.onComplain),
    ]);
  }

  Widget _assign() {
    final tc = TextEditingController(); final sc = TextEditingController();
    String sel = widget.user.gradesTaught;
    DateTime date = DateTime.now().add(const Duration(days: 1)); String? img;
    return StatefulBuilder(builder: (ctx, ss) => ListView(padding: const EdgeInsets.all(16), children: [
      buildSectionTitle(widget.t('assign_task')),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: tc, style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(labelText: widget.t('title'), labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))))),
          const SizedBox(height: 12),
          TextField(controller: sc, style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(labelText: widget.t('subject'), labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.school, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('${widget.t('grade_class')}: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(sel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 12),
          InkWell(onTap: () async { final p = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30))); if (p != null) ss(() => date = p); },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${widget.t('due_date')}: ${date.day}/${date.month}/${date.year}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
              ]))),
          const SizedBox(height: 12),
          GestureDetector(onTap: () => ss(() => img = 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=300&q=80'),
            child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(children: [
                Icon(img == null ? Icons.camera_alt : Icons.check_circle, color: img == null ? AppColors.primary : AppColors.success, size: 28),
                const SizedBox(height: 6),
                Text(img == null ? widget.t('attach_image') : widget.t('uploaded'), style: TextStyle(color: img == null ? AppColors.primary : AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                if (img != null) ...[const SizedBox(height: 6), safeNetworkImage(img!, height: 80, width: double.infinity)],
              ]),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () { if (tc.text.isNotEmpty && sc.text.isNotEmpty) { widget.onAssignTask(tc.text, sc.text, sel, date, img ?? ''); tc.clear(); sc.clear(); } },
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.purple]), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.t('assign_task'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
          ),
        ]),
      ),
    ]));
  }

  Widget _subs() {
    final list = widget.tasks.where((t) => t.teacherId == widget.user.id).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      buildSectionTitle(widget.t('submissions')),
      if (list.isEmpty) buildEmptyState(widget.t('no_data'))
      else ...list.map((task) => _subCard(task)).toList(),
    ]);
  }

  Widget _subCard(SchoolTask task) {
    final sub = task.status == 'submitted';
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: sub ? AppColors.success.withOpacity(0.15) : AppColors.warn.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(sub ? '1 Submitted' : '0 Submitted', style: TextStyle(color: sub ? AppColors.success : AppColors.warn, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 8),
        buildMiniRow(Icons.book, '${widget.t('subject')}: ${task.subject}'),
        buildMiniRow(Icons.school, '${widget.t('grade_class')}: ${task.targetGrade}'),
        if (sub) Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.person, size: 14, color: AppColors.primary), const SizedBox(width: 4), Text(task.submittedBy, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12))]),
            const SizedBox(height: 6),
            Text(task.submission, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 4, overflow: TextOverflow.ellipsis),
            if (task.submissionImageUrl.isNotEmpty) ...[const SizedBox(height: 6), safeNetworkImage(task.submissionImageUrl, height: 100, width: double.infinity)],
          ]),
        ),
      ]),
    ));
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
      buildGlassOpt(Icons.book, widget.t('subject'), widget.user.className),
      buildGlassOpt(Icons.class_outlined, widget.t('grades_taught'), widget.user.gradesTaught),
      buildGlassOpt(Icons.cake_outlined, widget.t('age'), '${widget.user.age}'),
      buildGlassOpt(Icons.phone_outlined, widget.t('contact'), widget.user.contact),
      buildGlassOpt(Icons.location_on_outlined, widget.t('location'), widget.user.location),
      buildGlassOpt(Icons.work_outline, widget.t('experience'), widget.user.experience.isEmpty ? '-' : widget.user.experience),
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
        ListTile(leading: const Icon(Icons.camera_alt, color: AppColors.primary), title: const Text('Take Photo', style: TextStyle(color: AppColors.textPrimary)), onTap: () { widget.onUpdateAvatar('https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&q=80'); Navigator.pop(c); }),
        ListTile(leading: const Icon(Icons.photo_library, color: AppColors.primary), title: const Text('Gallery', style: TextStyle(color: AppColors.textPrimary)), onTap: () { widget.onUpdateAvatar('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80'); Navigator.pop(c); }),
      ])),
    ));
  }
}
