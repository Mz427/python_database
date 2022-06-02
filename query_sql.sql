select b.nodename as '网点名称', b.nodeno as '网点编码', a.cardno as '卡号', a.compno as '客户编码',
    a.opetime as '交易时间', a.amount as '金额', a.balance as '余额', a.tracode as '交易代码', a.ctc as CTC,
    a.ttc as TTC, a.terminalno as '终端号', a.wrongflag as '标识',
    case
    when exists
    (
        select *
        from addvouch as a1
        where a1.ctc = a.ctc and a1.tracode = a.tracode and a1.cardno = a.cardno and a1.wrongflag = '0'
        union
        select *
        from carddetail as c1
        where c1.ctc = a.ctc and c1.tracode = a.tracode and c1.cardno = a.cardno and c1.wrongflag = '0'
    )
    then '写卡失败'
    when exists
    (
        select *
        from addvouch as a2
        where a2.ctc = a.ctc + 1 and a2.tracode = a.tracode and a2.cardno = a.cardno and a2.wrongflag = '0'
        union
        select *
        from carddetail as c2
        where c2.ctc = a.ctc + 1 and c2.tracode = a.tracode and c2.cardno = a.cardno and c2.wrongflag = '0'
    )
    then '写卡成功'
    when exists
    (
        select a3.ctc, a3.balance
        from oildetail as a3
        where a3.cardno = a.cardno and a3.opetime > a.opetime and a3.suctag in ('00', '01', '02')
        union
        select b3.ctc, b3.balance
        from oilvouch as b3
        where b3.cardno = a.cardno and b3.opetime > a.opetime and b3.suctag in ('00', '01', '02')
        union
        select c3.ctc, c3.balance
        from unlocal_credit_vouch as c3
        where c3.cardno = a.cardno and c3.opetime > a.opetime and c3.suctag in ('00', '01', '02')
    ) as new_oilvouch
    then
        case
        when exists
        (
            select *
            from new_oilvouch as a4, cardaccount as b4
            where a4.cardno = b4.cardno and a4.balance = b4.balance and a4.ctc =
            (
                select max(a4.ctc)
                from a4
            )
        )
        then '写卡成功'
        when exists
        (
            select *
            from all_oildetail as a5, cardaccount as b5
            where a5.cardno = b5.cardno and b5.balance - a5.balance = a.amount and a5.ctc =
            (
                select max(a5.ctc)
                from a5
            )
        )
        then '写卡失败'
        else null
        end
    else
        '待确认卡钱包'
    end as '原因分析',
    case '原因分析'
        when '写卡成功' then '待确认'
        when '写卡失败' then '待冲正'
        when '待确认卡钱包' then '待跟踪'
        else null
    end as '处理状态',
    b.sinopec_nodeno as '石化编码'
from addvouch as a, nodeinfor as b 
where a.nodeno = b.nodeno and a.wrongflag = 'X' and
    convert(numeric(8, 0), convert(char(8), a.opetime,112)) = convert(numeric(8, 0), convert(char(8), dateadd(day, -2, getdate()), 112))
order by terminalno
go
SELECT *
FROM pg_catalog.pg_tables pt 

CREATE TABLE mz_carddetail
(
	cardno CHAR (19),
	compno CHAR (12),
	opetime timestamp,
	tracode CHAR (2),
	ctc INT,
	ttc INT,
	amount NUMERIC (12, 2),
	balance NUMERIC (12, 2),
	wrongflag CHAR (1)
)

CREATE TABLE mz_cardaccount
(
	cardno CHAR (19),
	compno CHAR (12),
	balance NUMERIC (12, 2),
	prebalance NUMERIC (12, 2)
)

CREATE TABLE mz_oildetail
(
	ttc INT,
	suctag CHAR (2),
	cardno CHAR (19),
	opetime timestamp,
	ctc INT,
	amount NUMERIC (12, 2),
	balance NUMERIC (12, 2),
	wrongflag CHAR (1)
)

CREATE TABLE mz_unlocal_credit_vouch
(
	ttc INT,
	suctag CHAR (2),
	cardno CHAR (19),
	opetime timestamp,
	ctc INT,
	amount NUMERIC (12, 2),
	balance NUMERIC (12, 2),
	wrongflag CHAR (1)
)
