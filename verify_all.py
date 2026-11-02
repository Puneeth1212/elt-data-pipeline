"""Comprehensive verification script for Titanic ELT pipeline in etl_db."""

from config import get_connection

conn = get_connection()
cursor = conn.cursor(dictionary=True)

print("=" * 70)
print("1. DATABASE TABLES & VIEWS IN etl_db")
print("=" * 70)
cursor.execute("SHOW FULL TABLES IN etl_db;")
tables = cursor.fetchall()
for t in tables:
    name_key = list(t.keys())[0]
    type_key = list(t.keys())[1]
    print(f"  • {t[name_key]:<30} | {t[type_key]}")

print("\n" + "=" * 70)
print("2. ROW COUNTS PER TABLE")
print("=" * 70)
for t in ["raw_titanic", "stg_titanic", "clean_passengers", "dq_results"]:
    cursor.execute(f"SELECT COUNT(*) as cnt FROM {t};")
    cnt = cursor.fetchone()["cnt"]
    print(f"  • {t:<20} : {cnt:>4} rows")

print("\n" + "=" * 70)
print("3. DATA QUALITY CHECK AUDIT (dq_results)")
print("=" * 70)
cursor.execute("SELECT id, check_name, status, checked_at FROM dq_results ORDER BY id ASC;")
dq_rows = cursor.fetchall()
for r in dq_rows:
    print(f"  [#{r['id']} {r['status']}] {r['check_name']} (Recorded: {r['checked_at']})")

print("\n" + "=" * 70)
print("4. SAMPLE RECORDS FROM clean_passengers")
print("=" * 70)
cursor.execute("""
    SELECT passenger_id, passenger_class, sex_label, sex, age, age_group, 
           family_size, is_alone, fare, fare_category, embarked
    FROM clean_passengers 
    ORDER BY passenger_id ASC 
    LIMIT 5;
""")
for r in cursor.fetchall():
    print(f"  ID {r['passenger_id']:>3} | Class {r['passenger_class']} | {r['sex_label']:<6} (code {r['sex']}) | Age {float(r['age']):>4.1f} ({r['age_group']:<6}) | Fam: {r['family_size']} (Alone:{r['is_alone']}) | Fare: ${float(r['fare']):>6.2f} [{r['fare_category']:<7}] | Embarked: {r['embarked']}")

print("\n" + "=" * 70)
print("5. ANALYTICAL VIEW AUDIT: vw_top_3_fares_by_class")
print("=" * 70)
cursor.execute("SELECT passenger_class, fare_rank, passenger_id, sex_label, age, fare, fare_category FROM vw_top_3_fares_by_class;")
for r in cursor.fetchall():
    print(f"  Class {r['passenger_class']} | Rank #{r['fare_rank']} | ID {r['passenger_id']:>3} | {r['sex_label']:<6} | Age {float(r['age']):>4.1f} | Fare: ${float(r['fare']):>7.2f} | {r['fare_category']}")

cursor.close()
conn.close()
print("\n" + "=" * 70)
print("VERIFICATION COMPLETED SUCCESSFULLY!")
print("=" * 70)

