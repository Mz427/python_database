import sqlanydb
import psycopg2
import openpyxl

#Connetc query01.
query_connect = sqlanydb.connect(dsn="query01")
query_cursor = query_connect.cursor()
#Connetc postgresql.
postgresql_connect = psycopg2.connect(database="mzdb", user="mz", password="058474", \
    host="10.199.194.97" , port="5432")
postgresql_cursor = postgresql_connect.cursor()

query_sql = " \
    select cardno, compno, opetime, amount, a.balance, tracode, ctc, ttc, terminalno, wrongflag \
    from addvouch \
    where wrongflag = 'X' and \
        convert(numeric(8, 0), convert(char(8), opetime,112)) = convert(numeric(8, 0), convert(char(8), dateadd(day, -2, getdate()), 112))"
postgresql_sql = " \
    SELECT * \
    FROM pg_catalog.pg_tables pt;" 
query_cursor.execute(query_sql)
postgresql_cursor.execute(postgresql_sql)
#print(postgresql_cursor.fetchone())

query_cursor.close()
query_connect.close()
postgresql_cursor.close()
postgresql_connect.close()