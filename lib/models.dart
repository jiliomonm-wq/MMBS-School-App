import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String id;
  String name;
  String role;
  String className;
  String email;
  String password;
  String avatarUrl;
  int age;
  String location;
  String contact;
  String parentName;
  String parentPhone;
  String gradesTaught;
  String skills;
  String experience;
  int attendanceRate;
  int leaveDays; // ဤနေရာတွင် leaveDays ပြန်ထည့်ပေးထားပါသည်

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.className = '',
    required this.email,
    required this.password,
    this.avatarUrl = '',
    this.age = 15,
    this.location = '',
    this.contact = '',
    this.parentName = '',
    this.parentPhone = '',
    this.gradesTaught = '',
    this.skills = 'Teaching, Communication',
    this.experience = '1 Year',
    this.attendanceRate = 100,
    this.leaveDays = 0,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'className': className,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
        'age': age,
        'location': location,
        'contact': contact,
        'parentName': parentName,
        'parentPhone': parentPhone,
        'gradesTaught': gradesTaught,
        'skills': skills,
        'experience': experience,
        'attendanceRate': attendanceRate,
        'leaveDays': leaveDays,
      };

  factory UserProfile.fromFirestore(Map<String, dynamic> m, String docId) => UserProfile(
        id: docId,
        name: m['name'] ?? '',
        role: m['role'] ?? 'Student',
        className: m['className'] ?? '',
        email: m['email'] ?? '',
        password: m['password'] ?? '',
        avatarUrl: m['avatarUrl'] ?? '',
        age: m['age'] ?? 15,
        location: m['location'] ?? '',
        contact: m['contact'] ?? '',
        parentName: m['parentName'] ?? '',
        parentPhone: m['parentPhone'] ?? '',
        gradesTaught: m['gradesTaught'] ?? '',
        skills: m['skills'] ?? 'General',
        experience: m['experience'] ?? '1 Year',
        attendanceRate: m['attendanceRate'] ?? 100,
        leaveDays: m['leaveDays'] ?? 0,
      );
}

class SchoolTask {
  String id;
  String title;
  String subject;
  String targetGrade;
  String teacherId;
  String teacherName;
  DateTime dueDate;
  String taskImageUrl;
  String status;
  String submission;
  String submittedBy;
  String submissionImageUrl;

  SchoolTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.targetGrade,
    required this.teacherId,
    required this.teacherName,
    required this.dueDate,
    this.taskImageUrl = '',
    this.status = 'pending',
    this.submission = '',
    this.submittedBy = '',
    this.submissionImageUrl = '',
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'subject': subject,
        'targetGrade': targetGrade,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'dueDate': dueDate,
        'taskImageUrl': taskImageUrl,
        'status': status,
        'submission': submission,
        'submittedBy': submittedBy,
        'submissionImageUrl': submissionImageUrl,
      };

  factory SchoolTask.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return SchoolTask(
      id: doc.id,
      title: m['title'] ?? '',
      subject: m['subject'] ?? '',
      targetGrade: m['targetGrade'] ?? '',
      teacherId: m['teacherId'] ?? '',
      teacherName: m['teacherName'] ?? '',
      dueDate: (m['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      taskImageUrl: m['taskImageUrl'] ?? '',
      status: m['status'] ?? 'pending',
      submission: m['submission'] ?? '',
      submittedBy: m['submittedBy'] ?? '',
      submissionImageUrl: m['submissionImageUrl'] ?? '',
    );
  }
}

class Announcement {
  String id;
  String title;
  String content;
  String target;
  DateTime date;
  bool isPinned;

  Announcement({
    this.id = '',
    required this.title,
    required this.content,
    required this.target,
    required this.date,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'target': target,
        'date': date,
        'isPinned': isPinned,
      };

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: m['title'] ?? '',
      content: m['content'] ?? '',
      target: m['target'] ?? 'All',
      date: (m['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: m['isPinned'] ?? false,
    );
  }
}

class Complaint {
  String id;
  String title;
  String desc;
  String fromRole;
  String fromName;
  DateTime createdAt;

  Complaint({
    this.id = '',
    required this.title,
    required this.desc,
    required this.fromRole,
    required this.fromName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'desc': desc,
        'fromRole': fromRole,
        'fromName': fromName,
        'createdAt': createdAt,
      };

  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      title: m['title'] ?? '',
      desc: m['desc'] ?? '',
      fromRole: m['fromRole'] ?? '',
      fromName: m['fromName'] ?? '',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
