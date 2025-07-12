# TimeWise - Smart Attendance Tracker for students

A Flutter attendance tracking app for DTU students to manage class schedules and monitor attendance percentages.

## Features

- **Timetable Management**: Configure subjects and create visual timetables
- **Calendar-based Attendance**: Track attendance using an intuitive calendar interface
- **Smart Notifications**: Daily reminders at 6 PM (Monday-Friday)
- **Real-time Statistics**: Live attendance percentage calculations
- **75% Monitoring**: Track how many classes you can miss

### Setup
1. Clone and install dependencies:
   ```bash
   git clone 
   cd timewise
   flutter pub get
   ```

2. Add permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Setup**: Configure subjects with credit types and create timetable
2. **Track**: Use calendar to select dates and mark attendance
3. **Monitor**: View real-time attendance percentages and statistics

## Key Dependencies

```yaml
dependencies:
  url_launcher: ^6.2.2
  shared_preferences: ^2.5.3
  provider: ^6.1.5
  uuid: ^4.5.1
  flutter_local_notifications: ^19.3.0
  timezone: ^0.10.1
  permission_handler: ^12.0.1
  table_calendar: ^3.2.0
  flutter_launcher_icons: ^0.14.4
```

## Credit System

- **4-Credit**: 42h theory (±28h practical)
- **2-Credit**: 28h elective OR 14h theory + 28h practical






