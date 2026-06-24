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

    grade = float(input(f"Enter grade for {name}: "))
    if grade >= 90:
        result = "Pass"
    elif grade >= 80:
        result = "Pass"
    elif grade >= 70:
        result = "Pass"
    else:
        result = "Fail"
    print (f" -->{name}: {result}")

    student_list.append({"name": name, "grade": grade, "result": result})

print("\n--- Results ---")
for s in student_list:
    print(f" {s['name']}: {s['grade']} - {s['result']}")

if student_list:
    average = sum(s["grade"] for s in student_list) / len(student_list)
    print(f"\nClass average: {average: .1f}")

else:
    print("\nNo students entered. ")


