-- Ninguna fila se pierde en plata: tantas filas como cita distintos llegaron a bronce.
with bronce as (select count(distinct cita) as n from {{ source('bronce', 'parte') }}),
     plata  as (select count(*) as n from {{ ref('stg_parte') }})
select bronce.n as en_bronce, plata.n as en_plata from bronce, plata where bronce.n <> plata.n
