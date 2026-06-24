# Your task:
# Read movie data from the file and store it in a list of dictionaries.
# how to combine file reading with dictionaries
# how to convert a number string into an integer
# how to store structured data in a list

movies = []
with open("movies.txt", "r") as file:
    for line in file:
        movie, rating = line.strip().split(",")

        movie_info = {
            "movie": movie,
            "rating": int(rating)
        }

        movies.append(movie_info)
    
    print(movies)