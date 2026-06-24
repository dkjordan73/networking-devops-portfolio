########################################################
# Student Grade tracker.                               #
# 1. Creates an empty list to store students           #
# 2. enter information for multiple students           #
# 3. Stores each student as a dictionary               #
# 4. Adds each dictionary to the list                  #
# 5. Displays all student records                      #
# 6. Shows whether each student passed or failed       #
# 7. Optionally calculates the class average           #
########################################################


student_list = []

while True:
    name = input("Enter student name (or 'done' to stop): ")
    if name.lower() == "done":
        break

    grade = input(f"Enter grade for {name}: ")
    student_list.append({"name": name, "grade": float (grade)})

print(f"\nRecorded {len(student_list)} students.")


