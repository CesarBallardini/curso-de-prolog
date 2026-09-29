# Debugging Tabled Programs
4-port Table Debugger.

The names may not be the best, but they should be clear.

1\.
Call

- Call Untabled
- Call Tabled: New Subgoal
- Call Tabled: Use Incomplete Table
- Call Tabled: Use Completed Table

2\.
Exit

- Exit Untabled
- Check/Insert Answer followed by
  - Redundant Answer - fail
  - Insert Answer - succeed

3\.
Redo

- Retry Program Clause
- Retry Answer Clause

4\.
Fail

- Fail Untabled
- Check Complete followed by
  - Completing tables (table list)
  - Rescheduling Answers for (table list)

How does tabling affect the debugger commands

Old commands :

Abort cleans up uncompleted tables.

Skip , Leap should work.

Break allows tables to be partially visible.

New Commands:

Ancestors. At least for tables.

Various Table examination mechanisms built upon Table builtins.

Show incomplete tabled subgoals.

Show returns for a table.

Show ancestors for each suspension of an incomplete tabled subgoal.

------------------------------------------------------------------------
