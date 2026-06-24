cars = ["Ford", "Chevy", "Dodge"]

with open("cars.txt", "w") as file:
    for car in cars:
        file.write(car +"\n")