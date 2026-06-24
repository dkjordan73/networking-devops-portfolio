#Your Task:
# Read movies.txt and display each movie and rating in a sentence.
# how to break apart file data using .split(",")
# how to assign values to two variables
# how to print clean output from stored data

with open ("movies.txt", "r") as file:
    for line in file:
        movie, rating = line.strip().split(",")
        print(f"{movie} has a rating of {rating}")
        