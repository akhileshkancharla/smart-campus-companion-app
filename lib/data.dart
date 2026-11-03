import 'package:flutter/material.dart';

const plum = Color(0xFF65435F);
const teal = Color(0xFF187D79);

class Notice {
  final String id, title, category, body, author;
  final bool pinned;
  const Notice(
    this.id,
    this.title,
    this.category,
    this.body,
    this.author, {
    this.pinned = false,
  });
}

const notices = [
  Notice(
    'exam',
    'Mid-semester examination schedule',
    'Academics',
    'The mid-semester examination timetable is now available. Examinations will be conducted in your department examination halls. Please carry your student ID and arrive 30 minutes before the scheduled time. Contact the examination cell for subject-specific timings.\n\nThis is sample campus content; confirm all dates with your institution.',
    'Examination Cell',
    pinned: true,
  ),
  Notice(
    'fest',
    'Your ideas. Our next campus festival.',
    'Events',
    'Join the student council to shape this year’s campus festival. We are looking for volunteers for design, music, technology, and event coordination. Visit the student activity centre during the lunch break to register your interest.',
    'Student Council',
    pinned: true,
  ),
  Notice(
    'library',
    'More time for your next great read',
    'Campus',
    'The central library reading room is open Monday to Saturday, 8:00 AM–8:00 PM. Borrowing services close at 5:00 PM. Bring your student ID to access the reading rooms and digital resources.',
    'Central Library',
  ),
  Notice(
    'workshop',
    'Build something at the Flutter workshop',
    'Events',
    'A beginner-friendly hands-on session covering layouts, navigation, and your first Flutter app. Bring a laptop with Flutter installed. Enquire at the Computer Science department office for registration and the next session date.',
    'Computer Science Department',
  ),
  Notice(
    'scholarship',
    'Scholarship document checklist',
    'Academics',
    'Students applying for scholarships should prepare their enrolment certificate, previous semester marksheet, and relevant eligibility documents. Visit the academic office to verify application deadlines and requirements.',
    'Academic Office',
  ),
  Notice(
    'water',
    'Bring a bottle. Make a difference.',
    'Campus',
    'Refill stations are available near the library, academic blocks, and sports complex. Help reduce single-use plastic on campus by carrying a reusable water bottle.',
    'Campus Services',
  ),
];

class Lesson {
  final int day, hour;
  final String subject, code, room, teacher;
  final bool lab;
  const Lesson(
    this.day,
    this.hour,
    this.subject,
    this.code,
    this.room,
    this.teacher, {
    this.lab = false,
  });
}

final lessons = <Lesson>[
  for (int d = 1; d <= 5; d++) ...[
    Lesson(
      d,
      9,
      d.isEven ? 'Database Management' : 'Data Structures',
      d.isEven ? 'CS302' : 'CS301',
      'Block A · 204',
      d.isEven ? 'Dr. Priya Sharma' : 'Dr. Arjun Rao',
    ),
    Lesson(
      d,
      10,
      'Computer Networks',
      'CS303',
      'Block B · 102',
      'Prof. Meera Iyer',
    ),
    Lesson(
      d,
      11,
      'Engineering Mathematics',
      'MA301',
      'Block A · 204',
      'Dr. Rohan Das',
    ),
    Lesson(
      d,
      14,
      d.isEven ? 'Database Lab' : 'Programming Lab',
      d.isEven ? 'CS312' : 'CS311',
      'Innovation Lab · 03',
      d.isEven ? 'Dr. Priya Sharma' : 'Dr. Arjun Rao',
      lab: true,
    ),
  ],
];

class Faculty {
  final String name, role, department, email, office, hours;
  const Faculty(
    this.name,
    this.role,
    this.department,
    this.email,
    this.office,
    this.hours,
  );
  String get initials => name
      .replaceAll('Dr. ', '')
      .replaceAll('Prof. ', '')
      .split(' ')
      .take(2)
      .map((s) => s[0])
      .join();
}

const faculty = [
  Faculty(
    'Dr. Arjun Rao',
    'Associate Professor',
    'Computer Science',
    'arjun.rao@example.edu',
    'Block A · Room 208',
    'Mon–Fri · 3:00–4:00 PM',
  ),
  Faculty(
    'Dr. Priya Sharma',
    'Head of Department',
    'Computer Science',
    'priya.sharma@example.edu',
    'Block A · Room 201',
    'Mon–Thu · 2:00–3:00 PM',
  ),
  Faculty(
    'Prof. Meera Iyer',
    'Assistant Professor',
    'Computer Science',
    'meera.iyer@example.edu',
    'Block B · Room 106',
    'Tue–Fri · 3:00–4:00 PM',
  ),
  Faculty(
    'Dr. Rohan Das',
    'Professor',
    'Mathematics',
    'rohan.das@example.edu',
    'Block C · Room 302',
    'Mon–Fri · 1:00–2:00 PM',
  ),
  Faculty(
    'Prof. Ananya Sen',
    'Assistant Professor',
    'Humanities',
    'ananya.sen@example.edu',
    'Block C · Room 110',
    'Mon–Wed · 2:00–3:00 PM',
  ),
  Faculty(
    'Dr. Vikram Nair',
    'Associate Professor',
    'Electronics',
    'vikram.nair@example.edu',
    'Block D · Room 205',
    'Wed–Fri · 11:00 AM–12:00 PM',
  ),
];

class Facility {
  final String name, location, hours, description;
  final IconData icon;
  const Facility(
    this.name,
    this.location,
    this.hours,
    this.description,
    this.icon,
  );
}

const facilities = [
  Facility(
    'Central Library',
    'Central Block · Floors 1 & 2',
    'Mon–Sat · 8:00 AM–8:00 PM',
    'Quiet reading rooms, digital journals, book lending, and collaborative study spaces. Bring your student ID for entry.',
    Icons.local_library_outlined,
  ),
  Facility(
    'Student Services',
    'Admin Block · Ground floor',
    'Mon–Fri · 9:00 AM–5:00 PM',
    'Your first stop for ID cards, certificates, enrolment queries, and scholarship guidance.',
    Icons.support_agent_outlined,
  ),
  Facility(
    'Health Centre',
    'Near the main entrance',
    'Mon–Sat · 9:00 AM–6:00 PM',
    'Basic first aid and student health consultations. For urgent medical assistance, contact local emergency services. This demo does not provide emergency support.',
    Icons.local_hospital_outlined,
  ),
  Facility(
    'Campus Cafeteria',
    'Student Activity Centre',
    'Mon–Sat · 7:30 AM–6:30 PM',
    'Breakfast, lunch, snacks, and drinking water. Vegetarian options available. Please use the segregated waste bins.',
    Icons.restaurant_outlined,
  ),
  Facility(
    'Sports Complex',
    'East campus · Sports ground',
    'Mon–Sat · 6:00 AM–7:00 PM',
    'Outdoor courts, running track, and indoor games. Ask the sports office about equipment and team registrations.',
    Icons.sports_basketball_outlined,
  ),
  Facility(
    'Innovation Lab',
    'Block B · Third floor',
    'Mon–Fri · 9:00 AM–5:00 PM',
    'A space for student projects, coding clubs, and hands-on workshops. Lab sessions require faculty supervision.',
    Icons.science_outlined,
  ),
];
