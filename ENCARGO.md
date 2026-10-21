# Caso 06 · Tinta Viva Studio — el encargo

> Negocio y datos **ficticios**, creados para la asignatura. Es tu mismo caso de la J3.

## Qué ha pasado desde la J3

En la J3 limpiaste el parte en un cuaderno y contestaste tres preguntas. Tinta Viva quiere su parte de sesiones automatizado. Y le preocupan dos cosas nuevas: la **agenda** (cree que tiene citas pisadas) y las **cancelaciones de última hora**, que ahora registra la web de reservas.

Ahora conviertes aquel cuaderno en un **lakehouse** de verdad, en tu propio repositorio, y publicas un **portal** que
cuenta lo que has hecho. Cómo preparar el repositorio y el ciclo de trabajo de cada bloque: [README.md](README.md).

## Lo que tienes al empezar

- En bronce, el parte de la J3: `lakehouse/bronce/parte/fecha_carga=2026-03-01/`.
- En `dbt/models/plata/stg_parte.sql`, la limpieza que hiciste en la J3, con unos tests básicos (`_plata.yml`, `dbt/tests/`).
- `dbt build` en verde. La capa oro, vacía: la construyes tú.
- En `paginas/`, las cuatro páginas del portal que escribirás, cada una con un guion de lo que debe contar.

**Bronce no se toca nunca**: todo arreglo va en plata.

---

## Bloque 1 · La remesa nueva · rama `remesa`

1. `python herramientas/sistema_simulado.py remesa`: llega una entrega nueva del parte en `bronce/parte/fecha_carga=2026-03-11/` (unos diez días más de sesiones).
2. `dbt build --project-dir dbt --profiles-dir dbt`. La remesa la ha tecleado a mano alguien nuevo en el estudio. El test de valores aceptados te dirá dónde.
3. Arregla `dbt/models/plata/stg_parte.sql` hasta que `dbt build` quede en verde y el problema esté resuelto (no siempre hay un test que lo grite: a veces tienes que escribirlo tú). Deja un comentario en el SQL: **qué** venía mal y **por qué** lo arreglas así.
4. Escribe `paginas/1-remesa.md`.
5. Pull request en tu repositorio, Actions en verde y lo fusionas.

## Bloque 2 · El oro · rama `oro`

Crea en `dbt/models/oro/` estos modelos, **con estos nombres exactos** (el portal y la jornada de Visualización los leen así):

| Modelo | Qué tiene |
|---|---|
| `dim_tatuador` | una fila por cada valor distinto de `tatuador` |
| `dim_maquina` | una fila por cada valor distinto de `maquina` |
| `dim_estilo` | una fila por cada valor distinto de `estilo` |
| `fact_sesiones` | una sesión por fila: `cita`, `fecha`, `tatuador`, `maquina`, `estilo`, `minutos`, `ml_tinta`, `importe_eur`, `con_incidencia` |
| `pregunta_1` | ¿Qué **estilo** deja menos ingreso por hora? Una fila por `estilo`, con `estilo` en la primera columna y `ingreso_hora` (€/hora), de menor a mayor |
| `pregunta_2` | ¿Qué **tatuador** gasta más tinta por hora? Una fila por `tatuador`, con `tatuador` en la primera columna y `ml_hora` (ml/hora), de mayor a menor |
| `pregunta_3` | ¿Qué **máquina** acumula más incidencias por cada 100 horas de uso? Una fila por `maquina`, con `maquina` en la primera columna y `incidencias_100h` (incidencias por 100 h), de mayor a menor |

En un `_oro.yml`, sus tests: en las dimensiones, `unique` y `not_null`; en el hecho, `unique` en `cita` y `relationships` con cada dimensión.

Escribe `paginas/2-oro.md`: tu estrella y las tres respuestas. Con la remesa nueva (un 25 % más de datos), ¿siguen saliendo las mismas que en la J3? Pull request, verde, fusionas.

## Bloque 3 · Fuentes nuevas · rama `fuentes`

1. `python herramientas/sistema_simulado.py fuentes`: llegan estos ficheros a bronce y quedan declarados en `dbt/models/plata/_fuentes.yml`.

| Fichero | Qué es | Columnas |
|---|---|---|
| `bronce/agenda/agenda.csv` | agenda de las próximas dos semanas: una fila por cita… **y por cada vez que se reprogramó** (`version`, `actualizada`) | cita, tatuador, fecha, hora_inicio, duracion_min, version, actualizada |
| `bronce/eventos/reservas_web_2026-03-13.json` | La web de reservas exporta un registro con un evento por cada `reserva` y por cada `cancelacion`, con la fecha de la cita y el importe estimado. | evento_id, tipo (reserva / cancelacion), ts, reserva_id, tatuador, estilo, fecha_cita, importe_estimado |

2. **El giro.** Una cancelación no es igual de mala siempre: la que llega con menos de **24 h** de antelación ya no se puede recolocar. Compara `ts` (cuándo se cancela) con `fecha_cita`.
3. Modelos de plata: `stg_agenda` y `stg_eventos` (el registro lo lees con `source('bronce', 'eventos')`).
4. **Test protagonista.** **Un tatuador no puede tener dos citas que se solapen.** Escribe un test singular sobre `stg_agenda`. Si lees la agenda tal cual llega, se pone rojo: descubre por qué y arréglalo en plata (no en bronce).
5. **Pregunta 4** (`dbt/models/oro/pregunta_4.sql`): ¿Cuánto dinero se pierde por **cancelaciones de última hora** y qué estilo las concentra?
6. Escribe `paginas/3-fuentes.md`. Pull request, verde, fusionas.

## Bloque 4 · El memo · rama `memo`

Escribe `paginas/memo.md`: el memo para la dirección de Tinta Viva Studio, con las cuatro respuestas citadas con marcas. La comprobación exige que existan `pregunta_1` a `pregunta_4`. Repasa el portal entero antes de fusionar.

---

## Lo que se entrega

- Tu repositorio en tu cuenta, con los cuatro pull requests fusionados y la última ejecución de `main` en verde.
- Tu portal publicado, con sus cuatro páginas escritas, y tu `dbt-docs`.
- La presentación oral (5 minutos): con tu portal en pantalla, el problema de calidad, tu test protagonista, las cuatro respuestas y tu recomendación.
