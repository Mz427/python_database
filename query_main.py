from openpyxl import load_workbook
import sqlanydb
#import psycopg2
import openpyxl
from datetime import date

#Connetc query01.
query_connect = sqlanydb.connect(dsn="query01")
query_cursor = query_connect.cursor()
#Connetc postgresql.
#postgresql_connect = psycopg2.connect(database="mzdb", user="mz", password="058474", \
#    host="10.9.7.201" , port="5432")
#postgresql_cursor = postgresql_connect.cursor()

#Open excel.
file_date_suffix = date.today().strftime("%Y%m%d")
excel_fk = load_workbook("深圳运维工作记录" + file_date_suffix + "/zhang/" + "发卡网点异常流水监控" + file_date_suffix)
sheet_fk = excel_fk.create_sheet(file_date_suffix[3:2])

query_sql = " \
    select b.nodename as '网点名称', b.nodeno as '网点编码', a.cardno as '卡号', a.compno as '客户编码', \
        a.opetime as '交易时间', a.amount as '金额', a.balance as '余额', a.tracode as '交易代码', \
        a.ctc as CTC, \ a.ttc as TTC, a.terminalno as '终端号', a.wrongflag as '标识' \
    from addvouch as a, nodeinfor as b  \
    where a.nodeno = b.nodeno and a.wrongflag = 'X' and \
        convert(numeric(8, 0), convert(char(8), a.opetime,112)) = convert(numeric(8, 0), convert(char(8), dateadd(day, -2, getdate()), 112)) \
    go"
#postgresql_sql = " \
#    select * \
#    from mz_test.mz_addvouch as a\
#    where exitsts (select * from mz_addvouch where a.wrongflag = '1')"

query_cursor.execute(query_sql)
addvouch_x = query_cursor.fetchall()
#postgresql_cursor.execute(postgresql_sql)
#print(postgresql_cursor.fetchall())

for i in addvouch_x :
    #根据后续圈存流水判断是否冲正。
    query_sql = f" \
        select * \
        from mz_addvouch as a1 \
        where a1.ctc = {i[8]} and a1.tracode = {i[7]} and a1.cardno = {i[2]} and a1.wrongflag = '0' \
        union \
        select * \
        from mz_carddetail as c1 \
        where c1.ctc = {i[8]} and c1.tracode = {i[7]} and c1.cardno = {i[2]} and c1.wrongflag = '0'" 
    query_cursor.execute(query_sql)
    temp_result = query_cursor.fetchall()
    if temp_result.count != 0:
        #插入excel处理结果：写卡失败，待冲正。
        print()
        continue
    #根据后续圈存流水判断是否确认。
    query_sql = f" \
    select * \
    from mz_addvouch as a1 \
    where a1.ctc = {i[8]} + 1 and a1.tracode = {i[7]} and a1.cardno = {i[2]} and a1.wrongflag = '0' \
    union \
    select * \
    from mz_carddetail as c1 \
    where c1.ctc = {i[8]} + 1 and c1.tracode = {i[7]} and c1.cardno = {i[2]} and c1.wrongflag = '0'" 
    query_cursor.execute(query_sql)
    temp_result = query_cursor.fetchall()
    if temp_result.count != 0:
        #插入excel处理结果：写卡成功，待确认。
        print()
        continue
    #根据后续加油流水判断是否确认。
    query_sql = f" \
            select a3.ctc, a3.balance \
            from mz_oildetail as a3 \
            where a3.cardno = {i[2]} and a3.opetime > {i[4]} and a3.suctag in ('00', '01', '02') \
            union \
            select b3.ctc, b3.balance \
            from mz_oilvouch as b3 \
            where b3.cardno = {i[2]} and b3.opetime > {i[4]} and b3.suctag in ('00', '01', '02') \
            union \
            select c3.ctc, c3.balance \
            from mz_unlocal_credit_vouch as c3 \
            where c3.cardno = {i[2]} and c3.opetime > {i[4]} and c3.suctag in ('00', '01', '02') \
            order by ctc" 
    query_cursor.execute(query_sql)
    temp_result = query_cursor.fetchall()
    if temp_result.count != 0:
        #确定卡钱包与卡账是否相等。
        query_sql = f" \
            select a.balance \
            from cardaccount a \
            where a.cardno = {i[2]}"
        query_cursor.execute(query_sql)
        temp_result_cardaccount = query_cursor.fetchall()
        if temp_result[-1][1] == temp_result_cardaccount:
            #插入excel处理结果：写卡成功，待确认。
            print()
        elif temp_result[-1][1] == temp_result_cardaccount - i[5]: 
            #插入excel处理结果：写卡失败，待冲正。
            print()
query_cursor.close()
query_connect.close()
#postgresql_cursor.close()
#postgresql_connect.close()