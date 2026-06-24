#Organized_Program

def get_name():
    return input("Enter your name: " )
def get_goal():
    return input("What do you want to learn? " )
def display_message(name, goal):
    print("Hello, " + name)
    print("It's great that you want to learn, " + goal)
name = get_name()
goal = get_goal()
display_message(name, goal)