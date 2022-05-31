case 
    when exists
    (
        select *
        from addvouch a
        where a.ctc=b.ctc and a.tracode=b.tracode and a.cardno=b.cardno and b.wrongflag='0'
        union
        select *
        from carddetail a
        where a.ctc=b.ctc and a.tracode=b.tracode and a.cardno=b.cardno and b.wrongflag='0'
    )
    then '写卡失败'
    when exists
    (
        select *
        from addvouch a
        where  a.ctc=b.ctc-1 and a.tracode=b.tracode and a.cardno=b.cardno and b.wrongflag='0' and a.my_m1=null and a.my_m2=null
        union
        select *
        from carddetail
        where  a.ctc=b.ctc-1 and a.tracode=b.tracode and a.cardno=b.cardno and b.wrongflag='0' and a.my_m1=null and a.my_m2=null
    )
    then '写卡成功'
    when exists
    (
        select ctc, balance
        from oildetail
        where cardno = cardno and opetime > opetime and suctag in ('00', '01', '02')
        union
        select ctc, balance
        from oilvouch
        where cardno = cardno and opetime > opetime and suctag in ('00', '01', '02')
        union
        select ctc, balance
        from unlocal_credit_vouch
        where cardno = cardno and opetime > opetime and suctag in ('00', '01', '02')
    ) as all_oildetail
    then
        case
            when exists
            (
                select *
                from all_oildetail, cardaccount
                where a.cardno = b.cardno and a.balance = b.balance and a.ctc =
                (
                    select max(ctc)
                    from all_oildetail
                )
            )
            then '写卡成功'
            when exists
            (
                select *
                from all_oildetail, cardaccount
                where a.cardno = b.cardno and b.balance - a.balance = amount and a.ctc =
                (
                    select max(ctc)
                    from all_oildetail
                )
            )
            then '写卡失败'
        end
    else
        null
end as '原因分析',
