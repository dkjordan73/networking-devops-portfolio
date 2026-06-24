# Your task:
# Using the list of dictionaries, 
# print whether each movie is 
# “Highly Rated” or “Needs Review”.
#### What Does This Teach: #####
# how to use dictionary values in conditions
# how to format output
# how to prepare for your student grade project

movies =[{"movie": "Sinners", "rating": 100},
         {"movie": "Bugonia", "rating": 20}
         ]
for item in movies:
    if item["rating"] >= 70:
        status = "Highly Rated"
    else:
        status = "Needs Review"

    print (f"{item['movie']} - {item['rating']} - {status}")
    