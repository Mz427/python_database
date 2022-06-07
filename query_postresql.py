import sqlanydb
import openpyxl
import psycopg2

#Connetc postgresql.
postgresql_connect = psycopg2.connect(database="mzdb", user="mz", password="058474", \
    host="10.199.194.97" , port="5432")
postgresql_cursor = postgresql_connect.cursor()

postgresql_sql = " \
    select * \
    from mz_test.mz_addvouch as a"

postgresql_cursor.execute(postgresql_sql)
print(postgresql_cursor.fetchall())

postgresql_cursor.close()
postgresql_connect.close()