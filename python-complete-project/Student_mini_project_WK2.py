##########################################################
# Student_Goal_Tracker                                   #
# Mini_Project_Week_2                                    #
# Ask the Student's name                                 #
# Ask how many learning goals would they like to enter   #
# Use a loop to collect those goals                      #
# Store the goals in a list                              #
# Use functions to organize the code                     # 
# Display a summary showing the student's name and goals #
##########################################################

def greet_student():
    name = input("Enter your name: ")
    return name
    
def get_goal():
    count = input("How many learning goals would you like to enter: " )
    return int(count)

def collect_goals(count):
    goals = []
    for i in range(count):
        goal = input("Enter a goal: ")
        goals.append(goal)
    return goals

def display_summary(name, goals):
    print(f"\nSummary for {name}:")
    for goal in goals:
        print("-", goal)

name = greet_student()
count = get_goal()
goals = collect_goals(count)
display_summary(name, goals)
    


