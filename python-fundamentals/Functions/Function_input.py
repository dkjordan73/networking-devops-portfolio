# Function_input
# String concatenation with + will make name a variable and not part of the string
# this is another alternative as well:  print(f"Hello, {name}")

def greet_user():
    name = input("Enter your name:" )
    print("Hello, " + name)
greet_user()