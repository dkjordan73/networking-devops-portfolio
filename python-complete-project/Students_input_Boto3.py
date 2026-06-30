##########################################################
# !!!!!Requirements!!!!
# store student records in a list of dictionaries
# save student records to a local text file
# upload the text file to an S3 bucket using Boto3
# download the text file from S3 when requested
# load student records from the downloaded file
# display the student records in a readable format
##########################################################

import boto3
import os
from botocore.exceptions import ClientError, NoCredentialsError, BotoCoreError

######################################################
# Update BUCKET_NAME before running
######################################################
FILE_NAME   = "students.txt"
BUCKET_NAME = ""   # <-- replace with your actual S3 bucket name
S3_KEY      = "student_tracker/students.txt"

# In memory list of student records (each record is a dictionary)
students = []


#######################################################
# Load Info from Students.txt File 
#######################################################

def load_students_from_file():
    """Read students.txt and populate the students list."""
    students.clear()

    if not os.path.exists(FILE_NAME):
        print("No local file found.")
        return

    with open(FILE_NAME, "r") as file:
        for line in file:
            line = line.strip()
            if not line:
                continue                         # skip blank lines

            parts = line.split(",")
            if len(parts) != 2:
                print(f"Skipping invalid line: {line}")
                continue

            name, score = parts
            try:
                student = {
                    "name": name,
                    "score": int(score)
                }
                students.append(student)
            except ValueError:
                print(f"Skipping line with invalid score: {line}")


def save_students_to_file():
    """Write every student in the list to students.txt (name,score per line)."""
    with open(FILE_NAME, "w") as file:
        for student in students:
            file.write(f"{student['name']},{student['score']}\n")
    print("Data saved locally.")


#######################################################
# Boto3 Loading file to S3 bucket
#######################################################

def upload_file_to_s3():
    """Upload students.txt to the configured S3 bucket."""
    s3 = boto3.client("s3")       # create a low level S3 client
    try:
        s3.upload_file(FILE_NAME, BUCKET_NAME, S3_KEY)
        print("File uploaded to S3 successfully.")
    except FileNotFoundError:
        print("Local file not found. Save data locally first before uploading.")
    except NoCredentialsError:
        print("AWS credentials not configured. Run 'aws configure' and try again.")
    except (ClientError, BotoCoreError) as e:
        print(f"Upload failed: {e}")


def download_file_from_s3():
    """Download students.txt from S3 and overwrite the local copy."""
    s3 = boto3.client("s3")
    try:
        s3.download_file(BUCKET_NAME, S3_KEY, FILE_NAME)
        print("File downloaded from S3 successfully.")
    except NoCredentialsError:
        print("AWS credentials not configured. Run 'aws configure' and try again.")
    except (ClientError, BotoCoreError) as e:
        print(f"Download failed: {e}")


#######################################################
# Input student name and Score
#######################################################

def add_student():
    """Prompt the user for a name and score, then add the student to the list."""
    name = input("Enter student name: ").strip()
    if not name:
        print("Name cannot be empty.")
        return

    try:
        score = int(input("Enter student score (0–100): ").strip())
    except ValueError:
        print("Invalid score. Please enter a whole number.")
        return

    students.append({"name": name, "score": score})
    print(f"Student '{name}' added.")


def view_students():
    """Display all student records with a pass/fail status."""
    if not students:
        print("No student records available.")
        return

    print("\nStudent Records")
    print("---------------")
    for student in students:
        status = "Passed" if student["score"] >= 60 else "Failed"
        print(f"{student['name']} - {student['score']} - {status}")


#######################################################
# Main Menu
#######################################################

def main():
    # Load any existing local data when the program starts
    load_students_from_file()

    while True:
        print("\nMenu")
        print("1. Add Student")
        print("2. View Students")
        print("3. Save Locally")
        print("4. Upload File to S3")
        print("5. Download File from S3")
        print("6. Reload Local File")
        print("7. Exit")

        choice = input("Enter your choice: ").strip()

        if choice == "1":
            add_student()
        elif choice == "2":
            view_students()
        elif choice == "3":
            save_students_to_file()
        elif choice == "4":
            save_students_to_file()     # always save before uploading
            upload_file_to_s3()
        elif choice == "5":
            download_file_from_s3()
        elif choice == "6":
            load_students_from_file()
            print("Local file reloaded.")
        elif choice == "7":
            print("Goodbye!")
            break
        else:
            print("Invalid choice. Please enter a number from 1 to 7.")


if __name__ == "__main__":
    main()