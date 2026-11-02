"""Utility script to create the Titanic ELT database if it does not exist."""

import argparse
import getpass
import os
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

parser = argparse.ArgumentParser(description="Create MySQL Database for Titanic ELT Pipeline")
parser.add_argument("--host", default=os.getenv("MYSQL_HOST", "localhost"), help="MySQL Host")
parser.add_argument("--port", type=int, default=int(os.getenv("MYSQL_PORT", 3306)), help="MySQL Port")
parser.add_argument("--user", default=os.getenv("MYSQL_USER", "root"), help="MySQL Username")
parser.add_argument("--password", "-p", default=None, help="MySQL Password")
parser.add_argument("--database", "-d", default=os.getenv("MYSQL_DATABASE", "etl_db"), help="Database Name")
args = parser.parse_args()

host = args.host
port = args.port
user = args.user
target_db = args.database

# Check candidates for password
passwords_to_try = []
if args.password is not None:
    passwords_to_try.append(args.password)
env_pwd = os.getenv("MYSQL_PASSWORD", "")
if env_pwd:
    passwords_to_try.append(env_pwd)
passwords_to_try.extend(["", "root", "admin"])

# Deduplicate
seen = set()
unique_passwords = [p for p in passwords_to_try if not (p in seen or seen.add(p))]

conn = None
working_password = None

print(f"Connecting to MySQL at {host}:{port} as user '{user}'...")

for pwd in unique_passwords:
    try:
        conn = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=pwd,
        )
        working_password = pwd
        print(f"Successfully connected to MySQL with user '{user}'!")
        break
    except mysql.connector.Error as err:
        pass

# If still not connected and running in interactive shell, prompt for password
if not conn:
    print(f"\n[AUTH] Could not authenticate with default credentials.")
    try:
        prompted_pwd = getpass.getpass(f"Enter MySQL password for user '{user}': ")
        conn = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=prompted_pwd,
        )
        working_password = prompted_pwd
        print(f"Successfully connected with provided password!")
    except Exception as e:
        print(f"Authentication failed: {e}")
        exit(1)

try:
    cursor = conn.cursor()
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{target_db}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    print(f"\n[SUCCESS] Database `{target_db}` created or already exists!")

    cursor.execute("SHOW DATABASES;")
    databases = [row[0] for row in cursor.fetchall()]
    print(f"[Databases List] Currently available databases: {databases}")

    cursor.close()
    conn.close()

    # Update .env file with the working credentials
    env_content = f"""# MySQL Database Configuration
MYSQL_HOST={host}
MYSQL_PORT={port}
MYSQL_USER={user}
MYSQL_PASSWORD={working_password}
MYSQL_DATABASE={target_db}
"""
    with open(".env", "w") as f:
        f.write(env_content)
    print(f"[Config Saved] Updated .env with database='{target_db}' and your credentials.")

except Exception as e:
    print(f"Error creating database: {e}")
    exit(1)

