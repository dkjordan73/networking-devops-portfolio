# Python Student Grade Tracker with Boto3 and S3

A Python CLI application that manages student records locally and syncs them to AWS S3 using Boto3. Built to demonstrate practical Python skills alongside real AWS SDK usage.

---

## What It Does

- Add student records (name and score)
- Display all records with pass/fail status (passing score: 60+)
- Save records to a local text file
- Upload the file to an S3 bucket
- Download the file back from S3
- Reload records from the local file

---

## Prerequisites

- Python 3.x
- Boto3 installed: `pip install boto3`
- AWS CLI configured with valid credentials: `aws configure`
- An existing S3 bucket

---

## Setup

Open `Students_input_Boto3.py` and set your bucket name on line 19:

```python
BUCKET_NAME = "your-bucket-name-here"
```

---

## Run

```bash
python3 Students_input_Boto3.py
```

Menu options:

```
1. Add Student
2. View Students
3. Save Locally
4. Upload File to S3
5. Download File from S3
6. Reload Local File
7. Exit
```

Option 4 saves locally before uploading, so you don't have to run option 3 first.

---

## Stack

Python, Boto3, AWS S3, AWS IAM
