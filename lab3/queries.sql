-- 1
select "Н_ЛЮДИ"."ИД", "Н_СЕССИЯ"."УЧГОД"
from "Н_ЛЮДИ"
         right join "Н_СЕССИЯ" on "Н_ЛЮДИ"."ИД" = "Н_СЕССИЯ"."ЧЛВК_ИД"
where "Н_ЛЮДИ"."ИМЯ" = 'Александр'
  and "Н_СЕССИЯ"."ЧЛВК_ИД" > 105948
  and "Н_СЕССИЯ"."ЧЛВК_ИД" = 110136; --100012

-- 2
select distinct "Н_ЛЮДИ"."ОТЧЕСТВО", "Н_ОБУЧЕНИЯ"."ЧЛВК_ИД", "Н_УЧЕНИКИ"."ГРУППА"
from "Н_ЛЮДИ"
         inner join "Н_ОБУЧЕНИЯ" on "Н_ЛЮДИ"."ИД" = "Н_ОБУЧЕНИЯ"."ЧЛВК_ИД"
         inner join "Н_УЧЕНИКИ" on "Н_ОБУЧЕНИЯ"."ВИД_ОБУЧ_ИД" = "Н_УЧЕНИКИ"."ВИД_ОБУЧ_ИД"
where "Н_ЛЮДИ"."ИД" < 142095
  and "Н_ОБУЧЕНИЯ"."ЧЛВК_ИД" < 163276;

-- 3
select "Н_ЛЮДИ"."ФАМИЛИЯ", "Н_ЛЮДИ"."ИМЯ", "Н_ЛЮДИ"."ОТЧЕСТВО"
from "Н_ЛЮДИ"
         join "Н_ОБУЧЕНИЯ" on "Н_ЛЮДИ"."ИД" = "Н_ОБУЧЕНИЯ"."ЧЛВК_ИД"
--          join "Н_УЧЕНИКИ" on "Н_ОБУЧЕНИЯ"."ВИД_ОБУЧ_ИД" = "Н_УЧЕНИКИ"."ВИД_ОБУЧ_ИД"
--          join "Н_ПЛАНЫ" ON "Н_УЧЕНИКИ"."ПЛАН_ИД" = "Н_ПЛАНЫ"."ИД"
--          join "Н_ОТДЕЛЫ" on "Н_ПЛАНЫ"."ОТД_ИД" = "Н_ОТДЕЛЫ"."ИД"
where "Н_ЛЮДИ"."ОТЧЕСТВО" is NULL;
--   and "Н_ОТДЕЛЫ"."КОРОТКОЕ_ИМЯ" = 'КТиУ';

-- 4
select "Н_УЧЕНИКИ"."ГРУППА", count("Н_УЧЕНИКИ"."ГРУППА") as "СЧЕТ"
from "Н_УЧЕНИКИ"
         join "Н_ПЛАНЫ" ON "Н_УЧЕНИКИ"."ПЛАН_ИД" = "Н_ПЛАНЫ"."ИД"
         join "Н_ОТДЕЛЫ" on "Н_ПЛАНЫ"."ОТД_ИД" = "Н_ОТДЕЛЫ"."ИД"
where "Н_ОТДЕЛЫ"."КОРОТКОЕ_ИМЯ" = 'КТиУ' -- ВТ
  and extract(year from "Н_УЧЕНИКИ"."НАЧАЛО") = 2011
group by "Н_УЧЕНИКИ"."ГРУППА";
-- having count(*) <= 5;

-- 5
SELECT "Н_УЧЕНИКИ"."ГРУППА",
       avg(CASE
               WHEN "Н_ЛЮДИ"."ДАТА_СМЕРТИ" > CURRENT_DATE OR "Н_ЛЮДИ"."ДАТА_СМЕРТИ" IS NULL
                   OR "Н_ЛЮДИ"."ДАТА_СМЕРТИ" <= "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ"
                   THEN extract(year from CURRENT_DATE) - extract(year from "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")
               ELSE extract(year from "Н_ЛЮДИ"."ДАТА_СМЕРТИ") - extract(year from "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")
           END
           )
FROM "Н_УЧЕНИКИ"
         JOIN "Н_ЛЮДИ" on "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
GROUP BY "Н_УЧЕНИКИ"."ГРУППА"
HAVING avg(CASE
               WHEN "Н_ЛЮДИ"."ДАТА_СМЕРТИ" > CURRENT_DATE OR "Н_ЛЮДИ"."ДАТА_СМЕРТИ" IS NULL
                   OR "Н_ЛЮДИ"."ДАТА_СМЕРТИ" <= "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ"
                   THEN extract(year from CURRENT_DATE) - extract(year from "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")
               ELSE extract(year from "Н_ЛЮДИ"."ДАТА_СМЕРТИ") - extract(year from "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")
    END
           )
           >
       (SELECT min(extract(year from CURRENT_DATE) - extract(year from "Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ"))
        FROM "Н_УЧЕНИКИ"
                 JOIN "Н_ЛЮДИ" on "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
        WHERE "Н_УЧЕНИКИ"."ГРУППА" = '1100');

SELECT "Н_УЧЕНИКИ"."ГРУППА", avg(date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")))
FROM "Н_ЛЮДИ"
         JOIN "Н_УЧЕНИКИ" ON "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
GROUP BY "Н_УЧЕНИКИ"."ГРУППА"
HAVING avg(date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ"))) <
       (SELECT avg(date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ")))
        FROM "Н_ЛЮДИ"
                 JOIN "Н_УЧЕНИКИ" ON "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
        WHERE "Н_УЧЕНИКИ"."ГРУППА" = '1100');

SELECT date_part('year', age("Н_ЛЮДИ"."ДАТА_РОЖДЕНИЯ"))
FROM "Н_УЧЕНИКИ"
         JOIN "Н_ЛЮДИ" on "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
WHERE "Н_УЧЕНИКИ"."ГРУППА" = '1100';


-- 6
select "Н_УЧЕНИКИ"."ГРУППА",
       "Н_ЛЮДИ"."ФАМИЛИЯ",
       "Н_ЛЮДИ"."ИМЯ",
       "Н_ЛЮДИ"."ОТЧЕСТВО",
       "Н_УЧЕНИКИ"."П_ПРКОК_ИД" AS "ПУНКТ ПРИКАЗА",
       "Н_УЧЕНИКИ"."КОНЕЦ"
from "Н_УЧЕНИКИ"
         join "Н_ЛЮДИ" on "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД"
where "Н_ЛЮДИ"."ИД" = "Н_УЧЕНИКИ"."ЧЛВК_ИД"
  and "Н_УЧЕНИКИ"."ПРИЗНАК" = 'отчисл'
  and exists(select *
             from "Н_ПЛАНЫ"
             where "Н_ПЛАНЫ"."ИД" = "Н_УЧЕНИКИ"."ПЛАН_ИД"
               and exists(select *
                          from "Н_ФОРМЫ_ОБУЧЕНИЯ"
                          where "Н_ПЛАНЫ"."ФО_ИД" = "Н_ФОРМЫ_ОБУЧЕНИЯ"."ИД"
                            and "Н_ФОРМЫ_ОБУЧЕНИЯ"."НАИМЕНОВАНИЕ" = 'Очная')
               and "Н_ПЛАНЫ"."КУРС" = 1);
--   and DATE("Н_УЧЕНИКИ"."КОНЕЦ") = '2012-09-01';

-- 7
select "Н_ЛЮДИ"."ИД", "Н_ЛЮДИ"."ФАМИЛИЯ", "Н_ЛЮДИ"."ИМЯ", "Н_ЛЮДИ"."ОТЧЕСТВО"
from "Н_ЛЮДИ"
where not EXISTS (select *
                  from "Н_УЧЕНИКИ"
                           join "Н_ПЛАНЫ"
                                on "Н_УЧЕНИКИ"."ПЛАН_ИД" = "Н_ПЛАНЫ"."ИД"
                           join "Н_ОТДЕЛЫ"
                                on "Н_ПЛАНЫ"."ОТД_ИД" = "Н_ОТДЕЛЫ"."ИД"
                                    AND "Н_ОТДЕЛЫ"."КОРОТКОЕ_ИМЯ" = 'КТиУ'
                  WHERE "Н_УЧЕНИКИ"."ЧЛВК_ИД" = "Н_ЛЮДИ"."ИД");
