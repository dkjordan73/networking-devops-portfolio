###############################################################################################
# Project Requirements                                                                        #
# Load existing student data from a file (if it exists)                                       #
# Store students in a list of dictionaries                                                    #
# Allow the user to: add new students, view all students                                      #
# Save all student data back to the file before exiting                                       #
###############################################################################################


# open file, read lines, return a list
def load_students():
    students = [] #create the list inside the function
    try:
        with open("students.txt", "r") as file:
            for line in file:
                name, score = line.strip().split(",")

                student = {
                    "name": name,
                    "score": int(score),
                    "result": "Passed" if int(score) >= 70 else "Failed"
                }

                students.append(student)
    except FileNotFoundError:
        print("No existing data found. Starting fresh.")

    return students # send the list back to whoever called the function

#################################################################################################
# You'll need to pass (students) in as a parameter since this function needs access to the list #
# Open the file in "w" mode                                                                     #
# Loop through the list and write each student in the format name,score                         #
#################################################################################################

def save_students(students):
    with open("students.txt", "w") as file:
        for student in students:
            file.write(f"{student['name']},{student['score']}\n")
    

###############################################################################################
# pass (students) in as a parameter                                                           #
# Ask the user for a name and a score                                                         #
# Create a dictionary with the name and score                                                 #
# Append the dictionary to the students list                                                  #
###############################################################################################


def add_student(students):
    while True:
        name = input("Enter student name (or 'done' to stop): ")
        if name.lower() == "done":
            break
        score = int(input(f"Enter score for {name}: "))
        if score >= 70: 
            result = "Passed"
        else:
            result = "Failed"
        print (f" -->{name}: {result}")

        student = {
            "name": name, 
            "score": score, 
            "result": result
            }
        students.append(student)
        # optional line: students.append({"name": name, "score": score, "result": result})
        
    
###############################################################################################
# pass (students) in as a parameter                                                           #
# Loop through the list and print each student                                                #
# Display the name, score, and result for each student                                        #
# calculate and display the class average at the end                                          #
###############################################################################################

def view_students(students):
    # loop through list and print each student
    print("\n--- Results ---")
    for s in students:
        print(f" {s['name']}: {s['score']} - {s['result']}")

    if students:
        average = sum(s["score"] for s in students) / len(students)
        print(f"\nClass average: {average:.1f}")
    else:
        print("\nNo students entered. ")

###############################################################################################
# Use a while True loop to keep the menu running
# Print the menu options inside the loop
# use if/elif/else to handle choices
# call your funcitions when needed
# On exit save_students call save_students() before breaking out of loop
###############################################################################################

def run_menu(students):
    # show menu, get choice, call the right function
    while True:
        print("\nMenu")
        print("1. Add Student")
        print("2. View Students")
        print("3. Exit")
        choice = input ("Enter your choice: ")
        
        if choice == "1":
            add_student(students)
        elif choice == "2":
            view_students(students)
        elif choice == "3":
            save_students(students)
            print("Goodbye!")
            break
        else:
            print ("Invalid choice. Try again.")


###############################################################################################
# call the load student function which will open students.txt and reads all students.         #
# start the menu loop and passes the students into list.                                      #
###############################################################################################


# --- Program starts here ---
students = load_students()
run_menu(students)

