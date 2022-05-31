import sqlanydb
import openpyxl

query_connect = sqlanydb.connect(dsn="query01")
query_cursor = query_connect.cursor()
query_cursor.excute("")

