# fall_festival_guest_roster

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.





########
# In-Class 08 / Fall Festival Roster
Jalen Artis / CSC 4360/6360 / Undergrad:
Flutter / Dart versions; device / OS:
Setup/run commands:

## Storage notes
- Schema and initialization:
- Input policy, IDs, CRUD source locations:
- Memory example / preference example / SQLite example:

## Actual tests
| Test | Action/input | Expected | Observed IDs/ages/count | Pass/fail |
| --- | --- | --- | --- | --- |
| T1 | 0| 0| 0| pass|
| T2 | 2| 25,40| 2| pass|
| T3 |2 |25,40 | 2| pass|
| T4 |2 | 25,40| 2| pass|
| T5 | 1| 40| 1| pass|
| T6 | List every invalid/boundary input : name cant be blank| only numbers as age | only integers from 0-130 | pass
T4 stop/relaunch method:
Evidence: evidence/T4_before.png, evidence/T4_after.png,
          evidence/T6_invalid.png, evidence/analysis_output.txt
Analyzer command/result; known limitations:

## Short reflections
1. Prediction (write BEFORE T4), then actual result/interpretation: it will remain the same
2. My two IDs and update result; why identity matters: Identity is important because it is how you are tracked. mess up an ID and it will be hard to track and or fix in a larger database.
3. My self-walkthrough observation and proposed improvement: could have certain specifcations happen when weird scenarios like name blank or anonmymous. age numbers can be half if the person has reached the half mark on the year.

## Attribution








1 / Before T4, predict what will survive and why. Include your actual IDs, values, count, stop/relaunch method, and before/after evidence references. Trace the path from init() through the first query to the visible list in your own implementation. What observation would disprove your claim that SQLite restored the data?
- 
    Charles 40
    rivera 25
    I think they will stay. 
    They did stay.


2 / Two Rivers, one wrong edit (all students)
Use your T2-T3 IDs, ages, and affected-row result to explain why a name is not a reliable identifier. Point to the update call in your own source. Give one short hypothetical example of how selecting by list position after a sort could target the wrong record. No additional experiment is required.
- there can always be the same name within a database. there needs to be multiple variables to track everyone and uniquely. depending on the sort can arrange certain rows differently. there can also be the same name depending on the sort. Selecting a person with the same name but potentially a different age or identifier can cause the wrong person to be selected.


3 / Your own usability walkthrough (all students)
Perform Add/Edit/Cancel/Delete yourself during T2-T5. Record one specific observation from your screen, then propose one small improvement and its trade-off; implementation is not required. Refer to your T6 feedback and count to explain how you know invalid input did not save. If you found a real bug, briefly note the fix or remaining limitation; a bug is not required.
- The edit one, there can be a small improvement made, maybe like an effect, to show that the edit was made successfully, one trade off it might have is making the app a little slower potentially if the database is huge. Invalid input doesn't allow the record to be saved until the input is valid.