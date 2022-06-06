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
        select *
        from oildetail as a3
        where a3.cardno = a.cardno and a3.opetime > a.opetime and a3.suctag in ('00', '01', '02')
        union
        select *
        from oilvouch as b3
        where b3.cardno = a.cardno and b3.opetime > a.opetime and b3.suctag in ('00', '01', '02')
        union
        select *
        from unlocal_credit_vouch as c3
        where c3.cardno = a.cardno and c3.opetime > a.opetime and c3.suctag in ('00', '01', '02')
    ) 
    then
        case
        when exists
        (
            select *
            from cardaccount as b4, 
            (
            	select * 
        		from oildetail as a4
        		where a4.cardno = a.cardno and a4.opetime > a.opetime and a4.suctag in ('00', '01', '02')
        		union
        		select *
        		from oilvouch as b4
        		where b4.cardno = a.cardno and b4.opetime > a.opetime and b4.suctag in ('00', '01', '02')
        		union
        		select *
        		from unlocal_credit_vouch as c4
        		where c4.cardno = a.cardno and c4.opetime > a.opetime and c4.suctag in ('00', '01', '02')
            ) AS a5
            where a5.cardno = b4.cardno and a5.balance = b4.balance and a5.ctc =
            (
                select max(a7.ctc)
                from             
                (
            	    select * 
        		    from oildetail as a6
        		    where a6.cardno = a.cardno and a6.opetime > a.opetime and a6.suctag in ('00', '01', '02')
        		    union
        		    select *
        		    from oilvouch as b6
        		    where b6.cardno = a.cardno and b6.opetime > a.opetime and b6.suctag in ('00', '01', '02')
        		    union
        		    select *
        		    from unlocal_credit_vouch as c6
        		    where c6.cardno = a.cardno and c6.opetime > a.opetime and c6.suctag in ('00', '01', '02')
            	) AS a7
            )
        )
        then '写卡成功'
        when exists
        (
            select *
            from cardaccount as b5,
            (
            	select * 
        		from oildetail as a8
        		where a8.cardno = a.cardno and a8.opetime > a.opetime and a8.suctag in ('00', '01', '02')
        		union
        		select *
        		from oilvouch as b8
        		where b8.cardno = a.cardno and b8.opetime > a.opetime and b8.suctag in ('00', '01', '02')
        		union
        		select *
        		from unlocal_credit_vouch as c8
        		where c8.cardno = a.cardno and c8.opetime > a.opetime and c8.suctag in ('00', '01', '02')
            ) as a9
            where a9.cardno = b5.cardno and b5.balance - a9.balance = a.amount and a9.ctc =
            (
                select max(a10.ctc)
                from            
                (
            		select * 
        			from oildetail as a11
        			where a11.cardno = a.cardno and a11.opetime > a.opetime and a11.suctag in ('00', '01', '02')
        			union
        			select *
        			from oilvouch as b11
        			where b11.cardno = a.cardno and b11.opetime > a.opetime and b11.suctag in ('00', '01', '02')
        			union
        			select *
        			from unlocal_credit_vouch as c11
        			where c11.cardno = a.cardno and c11.opetime > a.opetime and c11.suctag in ('00', '01', '02')
            	) AS a10
            )
        )
        then '写卡失败'
        else null 
        END
    ELSE NULL
    END as '处理状态',
    b.sinopec_nodeno as '石化编码'
from addvouch as a, nodeinfor as b 
where a.nodeno = b.nodeno and a.wrongflag = 'X' and
    convert(numeric(8, 0), convert(char(8), a.opetime,112)) = convert(numeric(8, 0), convert(char(8), dateadd(day, -2, getdate()), 112))
go
-------------------------------------------------------------------------------------------------------------------------
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
SELECT *
FROM pg_catalog.pg_tables pt 

CREATE TABLE mz_addvouch
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
);
INSERT INTO mz_addvouch VALUES
('1000119000000123451', '900000000001', '20220101 01:00:00', '31', 1, 1234, 1000, 1000, 'X'),
('1000119000000123452', '900000000002', '20220102 02:00:00', '31', 2, 1234, 2000, 1000, 'X'),
('1000119000000123453', '900000000003', '20220103 03:00:00', '31', 3, 1234, 3000, 1000, 'X'),
('1000119000000123454', '900000000004', '20220104 04:00:00', '31', 4, 1234, 4000, 1000, 'X'),
('1000119000000123455', '900000000005', '20220105 05:00:00', '31', 5, 1234, 5000, 1000, 'X'),
('1000119000000123456', '900000000006', '20220106 06:00:00', '31', 6, 1234, 6000, 1000, 'X');

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
);
INSERT INTO mz_carddetail VALUES
('1000119000000123451', '900000000001', '20220101 01:00:00', '31', 1, 1234, 1000, 1000, '0'),
('1000119000000123452', '900000000002', '20220102 02:00:00', '31', 3, 1234, 2000, 1000, '0'),
('1000119000000123453', '900000000003', '20220103 03:00:00', '31', 0, 1234, 3000, 1000, 'X'),
('1000119000000123454', '900000000004', '20220104 04:00:00', '31', 0, 1234, 4000, 1000, 'X'),
('1000119000000123455', '900000000005', '20220105 05:00:00', '31', 0, 1234, 5000, 1000, 'X'),
('1000119000000123456', '900000000006', '20220106 06:00:00', '31', 0, 1234, 6000, 1000, 'X');

CREATE TABLE mz_cardaccount
(
	cardno CHAR (19),
	compno CHAR (12),
	balance NUMERIC (12, 2),
	prebalance NUMERIC (12, 2)
);
INSERT INTO mz_cardaccount VALUES
('1000119000000123451', '900000000001', 1000, 1000),
('1000119000000123452', '900000000002', 2000, 1000),
('1000119000000123453', '900000000003', 1500, 1000),
('1000119000000123454', '900000000004', 4000, 1000),
('1000119000000123455', '900000000005', 5000, 1000),
('1000119000000123456', '900000000006', 3000, 1000);

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
);
INSERT INTO mz_oildetail VALUES
(1234, '01', '1000119000000123451', '20220101 01:00:00', 1, 1000, 0, '0'),
(1234, '01', '1000119000000123452', '20220102 02:00:00', 2, 2000, 0, '0'),
(1234, '01', '1000119000000123453', '20220107 03:00:00', 3, 1500, 1500, '0'),
(1234, '01', '1000119000000123454', '20220108 04:00:00', 4, 1100, 0, '0'),
(1234, '01', '1000119000000123455', '20210105 05:00:00', 5, 5000, 1000, '0'),
(1234, '01', '1000119000000123456', '20210106 06:00:00', 6, 6000, 1000, '0');

CREATE TABLE mz_oilvouch
(
	ttc INT,
	suctag CHAR (2),
	cardno CHAR (19),
	opetime timestamp,
	ctc INT,
	amount NUMERIC (12, 2),
	balance NUMERIC (12, 2),
	wrongflag CHAR (1)
);

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
);
INSERT INTO mz_unlocal_credit_vouch  VALUES
(1234, '01', '1000119000000123455', '20210205 05:00:00', 6, 5000, 0, '0'),
(1234, '01', '1000119000000123456', '20210206 06:00:00', 7, 6000, 3000, '0');


