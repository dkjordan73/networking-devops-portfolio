# Your task: 
# Ask for a movie name and a rating, then save it to a file called
# saving movie and rating to a file
# how to collect user input
# how to save two pieces of data on one line
# how to use commas as seperators
# how to use append mode "a"

movie = input("Enter a movie name: ")
rating = input("Enter the rating: ")

with open("movies.txt", "a") as file:
    file.write(f"{movie}, {rating}\n")