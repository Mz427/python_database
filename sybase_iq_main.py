#import sqlanydb
#import openpyxl
import psycopg

##Connetc query01.
#query_connect = sqlanydb.connect(dsn="query01")
#query_cursor = query_connect.cursor()
#Connetc postgresql.
postgresql_connect = psycopg.connect(database="mzdb", user="mz", password="058474", \
    host="10.9.7.201" , port="5432")
postgresql_cursor = postgresql_connect.cursor()

query_sql = " \
    select * \
    from addvouch \
    where wrongflag = 'X';"

postgresql_sql = " \
    SELECT * \
    FROM pg_catalog.pg_tables pt;" 
#query_cursor.execute(query_sql)
postgresql_cursor.execute(postgresql_sql)
#print(postgresql_cursor.fetchone())

#query_cursor.close()
#query_connect.close()
postgresql_cursor.close()
postgresql_connect.close()