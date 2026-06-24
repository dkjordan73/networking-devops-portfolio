#Greeting_Multiple_Users
names = []
for i in range(3):
    name = input("Enter a name: ")
    names.append(name)
print("\nGreetings: ")
for name in names:
    print("Hello," , name)