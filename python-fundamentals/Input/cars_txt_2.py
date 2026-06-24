car_list = []

with open("cars.txt", "r") as file:
    for line in file:
        car_list.append(line.strip())

print(car_list)