# Proyecto_Puebla
Análisis de los resultados del PREP de las elecciones del 2018 para el estado de Puebla

Se intento hacer mapas para visualizar la informacion geografica en tres lenguajes de programación estad'isticos:

## 0. Procesamiento de la información.
Se descargó informacion relativa a las elecciones de Puebla de 2018, disponibles en el siguiente [archivo](https://preppuebla2018.mx/entregables/85/100/20180702_2000_PREP.zip). Se procesó la base de datos de acuerdo a las instrucciones del archivo `Procesamiento.R` para tener un archivo `geojson` solo con la información relevante. 

Posteriormente se procedió a realizar los mapas para la visualización de la información:

## 1. Intento en Python
https://github.com/JuveCampos/Proyecto_Puebla/blob/master/Mapa%20Puebla.ipynb

**Issues sin resolver: **

* No se como cambiar la paleta de colores preseleccionada. _Intentos:_ Usar `cmap` con un vector [] de colores personalizado no funciono. Usar una columna de colores no funcionó.


## 2. Intento en STATA
https://github.com/JuveCampos/Proyecto_Puebla/blob/master/DatosGeograficos/Mapa_Stata.do

**Issues sin resolver: **

* Una vez que importo el .shp a los .dta, no encuentro como hacer el plot de la variable.
* No entiendo porque no se puede utilizar variables `String` para hacer los mapas (me sale un error relacionado con esto).
* Procedimiento demasiado complicado

