import 'package:flutter/material.dart';
import 'models.dart';
import 'theme_widgets.dart';

// ============================================================================
// 9. OWNER DASHBOARD
// ============================================================================
class OwnerDashboard extends StatefulWidget {
  final UserProfile user; final String lang; final String Function(String) t;
  final VoidCallback onToggleLang;
  final List<Complaint> complaints; final List<Announcement> announcements;
  final List<SchoolTask> tasks;
  final List<UserProfile> allUsers;
  final Function(String, String, String) onAddAnnouncement;
  final Function(String) onUpdateAvatar;
  final Function(UserProfile) onUpdateUser;
  final Function(UserProfile) onAddUser;
  final VoidCallback onLogout;
  const OwnerDashboard({super.key, required this.user, required this.lang, required this.t, required this.onToggleLang, required this.complaints, required this.announcements, required this.tasks, required this.allUsers, required this.onAddAnnouncement, required this.onUpdateAvatar, required this.onUpdateUser, required this.onAddUser, required this.onLogout});
  @override State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _userManagement(), _newsPage(), _profile()];
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
          NavigationDestination(icon: const Icon(Icons.manage_accounts_outlined, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.manage_accounts, color: AppColors.primary, size: 22), label: widget.t('nav_users')),
          NavigationDestination(icon: const Icon(Icons.newspaper_outlined, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.newspaper, color: AppColors.primary, size: 22), label: widget.t('news')),
          NavigationDestination(icon: const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 22), selectedIcon: const Icon(Icons.person, color: AppColors.primary, size: 22), label: widget.t('profile')),
        ],
      ),
    );
  }

  Widget _home() {
    final totalStudents = widget.allUsers.where((u) => u.role == 'Student').length;
    final totalTeachers = widget.allUsers.where((u) => u.role == 'Teacher').length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.t('school_overview'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.warn.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
          child: const Text('2026-2027', style: TextStyle(color: Color(0xFF78350F), fontWeight: FontWeight.bold, fontSize: 10))),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: buildGlassStat(widget.t('total_students'), '$totalStudents', Icons.school, AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: buildGlassStat(widget.t('total_teachers'), '$totalTeachers', Icons.groups, AppColors.purple)),
      ]),
      const SizedBox(height: 16),
      buildSectionTitle(widget.t('complaints')),
      if (widget.complaints.isEmpty) buildEmptyState(widget.t('no_data'))
      else ...widget.complaints.map((c) => _compCard(c)).toList(),
    ]);
  }

  Widget _compCard(Complaint c) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('${widget.t('from')}: ${c.fromName}', style: const TextStyle(color: AppColors.danger, fontSize: 10))),
        ]),
        const SizedBox(height: 6),
        Text(c.desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  Widget _newsPage() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.t('news'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: _addAnnDialog,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.purple]), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [const Icon(Icons.add, size: 14, color: Colors.white), const SizedBox(width: 4), Text(widget.t('create_announcement'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      if (widget.announcements.isEmpty) buildEmptyState(widget.t('no_data'))
      else ...widget.announcements.map((a) => _annCard(a)).toList(),
    ]);
  }

  void _addAnnDialog() {
    final tc = TextEditingController(); final cc = TextEditingController(); String tgt = 'all';
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.t('create_announcement'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        TextField(controller: tc, style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(labelText: widget.t('title'), labelStyle: const TextStyle(color: AppColors.textSecondary), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))))),
        const SizedBox(height: 10),
        TextField(controller: cc, style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(labelText: widget.t('desc'), labelStyle: const TextStyle(color: AppColors.textSecondary), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))), maxLines: 3),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: tgt, dropdownColor: Colors.white, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(labelText: widget.t('target'), labelStyle: const TextStyle(color: AppColors.textSecondary), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))),
          items: [
            DropdownMenuItem(value: 'all', child: Text(widget.t('all'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
            DropdownMenuItem(value: 'student', child: Text(widget.t('student'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
            DropdownMenuItem(value: 'teacher', child: Text(widget.t('teacher'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
          ], onChanged: (v) => ss(() => tgt = v!)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(widget.t('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(width: 8),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), onPressed: () { if (tc.text.isNotEmpty) { widget.onAddAnnouncement(tc.text, cc.text, tgt); Navigator.pop(c); } }, child: Text(widget.t('submit'))),
        ]),
      ])),
    )));
  }

  Widget _annCard(Announcement a) {
    final lbl = a.target == 'all' ? widget.t('all') : (a.target == 'student' ? widget.t('student') : widget.t('teacher'));
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(lbl, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 6),
        Text(a.content, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    ));
  }

  Widget _userManagement() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: Text(widget.t('user_management'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
        GestureDetector(
          onTap: widget.onToggleLang,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.language, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(widget.t('lang'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showUserFormDialog(null),
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: const Icon(Icons.person_add, color: AppColors.primary, size: 18)),
        ),
      ]),
      const SizedBox(height: 6),
      Text(widget.t('manage_by_grade'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 12),
      ...List.generate(12, (index) {
        final gradeName = 'Grade ${index + 1}';
        final gradeStudents = widget.allUsers.where((u) => u.role == 'Student' && u.className == gradeName).toList();
        final gradeTeachers = widget.allUsers.where((u) => u.role == 'Teacher' && u.gradesTaught == gradeName).toList();
        final totalUsers = gradeStudents.length + gradeTeachers.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                iconColor: AppColors.textPrimary,
                collapsedIconColor: AppColors.textSecondary,
                leading: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: index % 2 == 0 ? [AppColors.primary, AppColors.purple] : [AppColors.accent3, AppColors.primary]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                title: Text(gradeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    _badge(Icons.school, '${gradeStudents.length}', AppColors.primary),
                    const SizedBox(width: 6),
                    _badge(Icons.person, '${gradeTeachers.length}', AppColors.purple),
                    const SizedBox(width: 6),
                    Text('$totalUsers ${widget.t('users')}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                ),
                children: [
                  if (gradeStudents.isNotEmpty) ...[
                    Row(children: [const Icon(Icons.school, size: 12, color: AppColors.primary), const SizedBox(width: 4), Text(widget.t('students'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))]),
                    const SizedBox(height: 6),
                    ...gradeStudents.map((u) => _gradeUserTile(u)),
                    const SizedBox(height: 8),
                  ],
                  if (gradeTeachers.isNotEmpty) ...[
                    Row(children: [const Icon(Icons.person, size: 12, color: AppColors.purple), const SizedBox(width: 4), Text(widget.t('teachers'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.purple))]),
                    const SizedBox(height: 6),
                    ...gradeTeachers.map((u) => _gradeUserTile(u)),
                  ],
                  if (gradeStudents.isEmpty && gradeTeachers.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Center(child: Text(widget.t('no_data'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)))),
                ],
              ),
            ),
          ),
        );
      }),
    ]);
  }

  Widget _badge(IconData icon, String count, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: color), const SizedBox(width: 3), Text(count, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))]));
  }

  Widget _gradeUserTile(UserProfile u) {
    return GestureDetector(
      onTap: () => _showUserDetailDialog(u),
      child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage: u.avatarUrl.isNotEmpty ? NetworkImage(u.avatarUrl) : null,
            child: u.avatarUrl.isEmpty ? Text(u.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)) : null),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            Text(u.role == 'Student' ? u.id : u.className, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ])),
          GestureDetector(onTap: () => _showUserFormDialog(u), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.edit, size: 16, color: AppColors.primary))),
        ]),
      ),
    );
  }

  void _showUserDetailDialog(UserProfile u) {
    final color = u.role == 'Teacher' ? AppColors.purple : AppColors.primary;
    showDialog(context: context, builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              CircleAvatar(radius: 38, backgroundColor: Colors.white,
                backgroundImage: u.avatarUrl.isNotEmpty ? NetworkImage(u.avatarUrl) : null,
                child: u.avatarUrl.isEmpty ? Text(u.name[0], style: TextStyle(fontSize: 30, color: color, fontWeight: FontWeight.bold)) : null),
              const SizedBox(height: 10),
              Text(u.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('${u.role} · ${u.className}', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _detailBox(widget.t('attendance_rate'), '${(u.attendanceRate * 100).toInt()}%', Icons.check_circle, AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: _detailBox(widget.t('leave_days'), '${u.leaveDays}', Icons.event_busy, AppColors.danger)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _detailBox(widget.t('experience'), u.experience.isEmpty ? '-' : u.experience, Icons.work, AppColors.warn)),
            const SizedBox(width: 10),
            Expanded(child: _detailBox(widget.t('age'), '${u.age}', Icons.cake, AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          Container(width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.star, size: 14, color: AppColors.warn), const SizedBox(width: 6), Text(widget.t('skills'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
              const SizedBox(height: 6),
              Text(u.skills.isEmpty ? '-' : u.skills, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ),
          if (u.role == 'Student' && u.parentName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.warn.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warn.withOpacity(0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.family_restroom, size: 14, color: Color(0xFF78350F)), const SizedBox(width: 6), Text('Parent Info (Owner Only)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78350F)))]),
                const SizedBox(height: 6),
                Text('${u.parentName} · ${u.parentPhone}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: GestureDetector(
            onTap: () => Navigator.pop(c),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(widget.t('cancel'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ),
          )),
        ]),
      ),
    ));
  }

  Widget _detailBox(String label, String value, IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 12, color: color), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ]),
    );
  }

  void _showUserFormDialog(UserProfile? existingUser) {
    final isEdit = existingUser != null;
    String role = isEdit ? existingUser.role : 'Student';
    String? selectedGrade = isEdit ? (existingUser.role == 'Student' ? existingUser.className : null) : null;
    String? selectedTeacherGrade = isEdit ? (existingUser.role == 'Teacher' ? existingUser.gradesTaught : null) : null;
    final nameCtrl = TextEditingController(text: isEdit ? existingUser.name : '');
    final emailCtrl = TextEditingController(text: isEdit ? existingUser.email : '');
    final passCtrl = TextEditingController(text: isEdit ? existingUser.password : '1234');
    final subjectCtrl = TextEditingController(text: isEdit && isEdit ? existingUser.className : '');
    final ageCtrl = TextEditingController(text: isEdit ? existingUser.age.toString() : '15');
    final locCtrl = TextEditingController(text: isEdit ? existingUser.location : '');
    final contactCtrl = TextEditingController(text: isEdit ? existingUser.contact : '');
    final pNameCtrl = TextEditingController(text: isEdit ? existingUser.parentName : '');
    final pPhoneCtrl = TextEditingController(text: isEdit ? existingUser.parentPhone : '');
    final skillsCtrl = TextEditingController(text: isEdit ? existingUser.skills : '');
    final expCtrl = TextEditingController(text: isEdit ? existingUser.experience : '');
    final leaveCtrl = TextEditingController(text: isEdit ? existingUser.leaveDays.toString() : '0');
    final grades = List.generate(12, (i) => 'Grade ${i + 1}');

    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, ss) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(isEdit ? Icons.edit : Icons.add_circle, color: AppColors.primary, size: 20), const SizedBox(width: 6), Text(isEdit ? widget.t('edit_user') : widget.t('add_user'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary))]),
              const SizedBox(height: 14),
              if (!isEdit) ...[
                Text(widget.t('select_role'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(children: ['Student', 'Teacher'].map((r) {
                  final sel = role == r;
                  return Expanded(child: Padding(padding: EdgeInsets.only(right: r == 'Teacher' ? 0 : 6), child: GestureDetector(onTap: () => ss(() => role = r),
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: sel ? const LinearGradient(colors: [AppColors.primary, AppColors.purple]) : null,
                        color: sel ? null : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? Colors.transparent : const Color(0xFFE2E8F0))),
                      child: Center(child: Text(widget.t(r.toLowerCase()), style: TextStyle(color: sel ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)))))));
                }).toList()),
                const SizedBox(height: 12),
              ],
              _sectionHeader(widget.t('login_info'), Icons.lock_outline),
              _editField(widget.t('email'), emailCtrl, Icons.email),
              _editField(widget.t('password'), passCtrl, Icons.password),
              const SizedBox(height: 8),
              _sectionHeader(widget.t('basic_info'), Icons.person_outline),
              _editField(widget.t('name'), nameCtrl, Icons.person),
              Row(children: [
                Expanded(child: _editField(widget.t('age'), ageCtrl, Icons.cake, isNum: true)),
                const SizedBox(width: 8),
                Expanded(child: _editField(widget.t('contact'), contactCtrl, Icons.phone, isNum: true)),
              ]),
              _editField(widget.t('location'), locCtrl, Icons.location_on),
              const SizedBox(height: 8),
              _sectionHeader(widget.t('role_info'), Icons.school_outlined),
              if (role == 'Student') ...[
                DropdownButtonFormField<String>(
                  value: grades.contains(selectedGrade) ? selectedGrade : null,
                  dropdownColor: Colors.white, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(labelText: widget.t('select_grade'), labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), isDense: true),
                  items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)))).toList(),
                  onChanged: (v) => ss(() => selectedGrade = v!),
                ),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.warn.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warn.withOpacity(0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [const Icon(Icons.info_outline, size: 14, color: Color(0xFF78350F)), const SizedBox(width: 6), Text('Parent Info (Owner Only)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78350F)))]),
                    const SizedBox(height: 8),
                    _editField(widget.t('parent_name'), pNameCtrl, Icons.person_outline),
                    const SizedBox(height: 6),
                    _editField(widget.t('parent_phone'), pPhoneCtrl, Icons.phone_outlined, isNum: true),
                  ]),
                ),
              ] else ...[
                _editField(widget.t('subject'), subjectCtrl, Icons.book),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: grades.contains(selectedTeacherGrade) ? selectedTeacherGrade : null,
                  dropdownColor: Colors.white, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(labelText: widget.t('grades_taught'), labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12), filled: true, fillColor: Colors.white.withOpacity(0.6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), isDense: true),
                  items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)))).toList(),
                  onChanged: (v) => ss(() => selectedTeacherGrade = v!),
                ),
                const SizedBox(height: 8),
                _editField(widget.t('experience'), expCtrl, Icons.work),
              ],
              const SizedBox(height: 8),
              _editField(widget.t('skills'), skillsCtrl, Icons.star),
              const SizedBox(height: 8),
              _editField(widget.t('leave_days'), leaveCtrl, Icons.event_busy, isNum: true),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(c), child: Text(widget.t('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                    if (role == 'Student' && selectedGrade == null) return;
                    if (role == 'Teacher' && (subjectCtrl.text.isEmpty || selectedTeacherGrade == null)) return;
                    final newUser = UserProfile(
                      name: nameCtrl.text, id: isEdit ? existingUser.id : '${role.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      role: role,
                      className: role == 'Student' ? selectedGrade! : (role == 'Teacher' ? subjectCtrl.text : ''),
                      email: emailCtrl.text, password: passCtrl.text,
                      avatarUrl: isEdit ? existingUser.avatarUrl : (role == 'Student' ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80' : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80'),
                      age: int.tryParse(ageCtrl.text) ?? 15, location: locCtrl.text, contact: contactCtrl.text,
                      parentName: role == 'Student' ? pNameCtrl.text : '', parentPhone: role == 'Student' ? pPhoneCtrl.text : '',
                      gradesTaught: role == 'Teacher' ? selectedTeacherGrade! : '',
                      skills: skillsCtrl.text, experience: role == 'Teacher' ? expCtrl.text : '',
                      attendanceRate: isEdit ? existingUser.attendanceRate : 0.95,
                      leaveDays: int.tryParse(leaveCtrl.text) ?? 0,
                    );
                    if (isEdit) { widget.onUpdateUser(newUser); } else { widget.onAddUser(newUser); }
                    Navigator.pop(c);
                  },
                  child: Text(widget.t('save')),
                ),
              ]),
            ]),
          ),
        ),
      ),
    )));
  }

  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 6),
    child: Row(children: [Icon(icon, size: 16, color: AppColors.primary), const SizedBox(width: 6), Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
  );

  Widget _editField(String label, TextEditingController ctrl, IconData icon, {bool isNum = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(controller: ctrl, keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, size: 16, color: AppColors.textSecondary),
        filled: true, fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
  );

  Widget _profile() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SizedBox(height: 10),
      Center(child: Column(children: [
        GestureDetector(
          onTap: _showPicDialog,
          child: Container(padding: const EdgeInsets.all(3),
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
          child: Text(widget.user.role, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))),
      ])),
      const SizedBox(height: 24),
      buildGlassOpt(Icons.badge, 'ID', widget.user.id),
      buildGlassOpt(Icons.email_outlined, widget.t('email'), widget.user.email),
      buildGlassOpt(Icons.language, widget.t('change_lang'), widget.lang == 'en' ? 'English' : 'မြန်မာ'),
    ]);
  }

  void _showPicDialog() {
    showDialog(context: context, builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.t('change_pic'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ListTile(leading: const Icon(Icons.camera_alt, color: AppColors.primary), title: const Text('Take Photo', style: TextStyle(color: AppColors.textPrimary)), onTap: () { widget.onUpdateAvatar('https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=100&q=80'); Navigator.pop(c); }),
        ListTile(leading: const Icon(Icons.photo_library, color: AppColors.primary), title: const Text('Gallery', style: TextStyle(color: AppColors.textPrimary)), onTap: () { widget.onUpdateAvatar('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=100&q=80'); Navigator.pop(c); }),
      ])),
    ));
  }
}