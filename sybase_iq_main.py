import sqlanydb
import openpyxl
import psycopg2

#Connetc query01.
query_connect = sqlanydb.connect(dsn="query01")
query_cursor = query_connect.cursor()
#Connetc postgresql.
postgresql_connect = psycopg2.connect(database="mzdb", user="mz", password="058474", \
    host="10.9.7.201" , port="5432")
postgresql_cursor = postgresql_connect.cursor()

query_sql = " \
    select b.nodename as '网点名称', b.nodeno as '网点编码', a.cardno as '卡号', a.compno as '客户编码', \
        a.opetime as '交易时间', a.amount as '金额', a.balance as '余额', a.tracode as '交易代码', a.ctc as CTC, \
        a.ttc as TTC, a.terminalno as '终端号', a.wrongflag as '标识' \
    from addvouch as a, nodeinfor as b  \
    where a.nodeno = b.nodeno and a.wrongflag = 'X' and \
        convert(numeric(8, 0), convert(char(8), a.opetime,112)) = convert(numeric(8, 0), convert(char(8), dateadd(day, -2, getdate()), 112)) \
    go"
postgresql_sql = " \
    select * \
    from mz_test.mz_addvouch as a\
    where exitsts (select * from mz_addvouch where a.wrongflag = '1')"

query_cursor.execute(query_sql)
addvouch_x = query_cursor.fetchall()
postgresql_cursor.execute(postgresql_sql)
print(postgresql_cursor.fetchall())

for i in temp_addvouch :
    query_sql = f" \
        select * \
        from mz_addvouch as a1 \
        where a1.ctc = {a.ctc} and a1.tracode = {a.tracode} and a1.cardno = {a.cardno} and a1.wrongflag = '0' \
        union \
        select * \
        from mz_carddetail as c1 \
        where c1.ctc = {a.ctc} and c1.tracode = {a.tracode} and c1.cardno = {a.cardno} and c1.wrongflag = '0'" 
    query_sql = f" \
        select * \
        from mz_addvouch as a1 \
        where a1.ctc = {a.ctc} + 1 and a1.tracode = {a.tracode} and a1.cardno = {a.cardno} and a1.wrongflag = '0' \
        union \
        select * \
        from mz_carddetail as c1 \
        where c1.ctc = {a.ctc} + 1 and c1.tracode = {a.tracode} and c1.cardno = {a.cardno} and c1.wrongflag = '0'" 
    if :
        query_sql = " \
            select * \
            from mz_oildetail as a3 \
            where a3.cardno = a.cardno and a3.opetime > a.opetime and a3.suctag in ('00', '01', '02') \
            union \
            select * \
            from mz_oilvouch as b3 \
            where b3.cardno = a.cardno and b3.opetime > a.opetime and b3.suctag in ('00', '01', '02') \
            union \
            select * \
            from mz_unlocal_credit_vouch as c3 \
            where c3.cardno = a.cardno and c3.opetime > a.opetime and c3.suctag in ('00', '01', '02')"

            " 
#query_cursor.close()
#query_connect.close()
postgresql_cursor.close()
postgresql_connect.close()