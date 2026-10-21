-- PLATA · el parte diario limpio: la limpieza que hiciste en la J3, ahora como modelo dbt.
-- Cada entrega del parte es una carpeta fecha_carga=… en bronce: aquí se leen todas juntas.
with bruto as (
    select *, parse_filename(filename) as archivo
    from {{ source('bronce', 'parte') }}
),
sin_dup as (
    -- una fila por cita
    select * from bruto
    qualify row_number() over (partition by cita order by fecha_carga desc) = 1
),
mediana_estilo as (
    select estilo, median(minutos::integer) as minutos_mediana
    from sin_dup
    where minutos::integer between 1 and 600
    group by estilo
)
select
    s.cita,
    s.fecha::date                                              as fecha,
    upper(trim(s.tatuador))                                         as tatuador,
    s.maquina,
    s.estilo,
    case when s.minutos::integer between 1 and 600 then s.minutos::integer
         else round(m.minutos_mediana)::integer end               as minutos,
    not (s.minutos::integer between 1 and 600)                   as minutos_corregido,
    s.ml_tinta::double                                              as ml_tinta,
    s.importe_eur::double                                      as importe_eur,
    s.incidencia,
    s.archivo,
    s.fecha_carga
from sin_dup s
join mediana_estilo m using (estilo)
