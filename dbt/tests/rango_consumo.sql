-- ml_tinta tiene que estar en un rango creíble para este negocio (1.15 a 41.6).
select cita, ml_tinta from {{ ref('stg_parte') }}
where ml_tinta not between 1.15 and 41.6
