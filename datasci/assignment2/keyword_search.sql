select
   similarity
from
   (
      select
         b.docid,
         sum(a.count * b.count) similarity
      from
         (select * from frequency union select 'q', 'washington', 1 union select 'q', 'taxes', 1 union select 'q', 'treasury', 1) a inner join
         (select * from frequency union select 'q', 'washington', 1 union select 'q', 'taxes', 1 union select 'q', 'treasury', 1) b on a.term = b.term
      where
         a.docid = 'q'
         and a.docid > b.docid
      group by
         b.docid
      order by
         similarity desc
   )
limit 1
;
