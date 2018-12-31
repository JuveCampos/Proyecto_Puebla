**********************************
* CREANDO MAPAS CON STATA        * 
* TUTORIAL                       *
* JORGE JUVENAL CAMPOS FERREIRA  *
* 30 DE DICIEMBRE, 2018          *
*********************************

* Inicializando el Stata
clear all 
set rmsg on
cap log close _all
set more off

* Instalamos paquetes
*ssc install maptile
*ssc install spmap
*ssc install shp2dta

* Fijamos el directorio de trabajo // este varia dependiendo de la computadora
cd "/Users/admin/Desktop/Proyectos/ProyectoPuebla/DatosGeograficos"

* Abrir el archivo *.shp
shp2dta using "Puebla.shp" , database(Puebla_info) coordinates(Puebla_coord) genid(id)

* Para ver los datos de informacion 
use Puebla_info.dta, clear

* Recodificamos la informacion 
generate Ganador = " "
replace Ganador = "Martha Erika Alonso Hidalgo (PAN, PRD, MC, CPP, PSI)" if (GANADOR == "MEAH")
replace Ganador = "Jose Enrique Doger Guerrero (PRI)" if (GANADOR == "JEDG")
replace Ganador = "Luis Miguel Geronimo Barbosa Huerta(PT, MOR, PES)" if (GANADOR == "LMGBH")
replace Ganador = "Miguel Chain Carrillo (PV)" if (GANADOR == "MCC")

save Puebla_info.dta, replace

* Para ver los datos de Coordenadas
use Puebla_coord.dta, clear
rename _ID id

* Hacemos merge de las bases de datos 
* Si no recordamos como usar merge escribir: 
* 	help merge

merge m:1 id using Puebla_info.dta
drop _merge

* Dibujamos el mapa
spmap using Puebla_coord.dta, id(id)










