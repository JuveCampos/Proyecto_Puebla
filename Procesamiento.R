# Librerias
library(tidyverse)
library(readr)
library(readxl)
library(sf)
library(stringr)

# Leemos mapa 
municipios <- st_read("muni_2016gw/muni_2016gw.shp") %>%
  filter(NOM_ENT ==  "Puebla")  %>%
  arrange(NOM_MUN)

plot(municipios)

# Estatal
prep_estatal <- read_csv("DatosPREP/20180702_2000_PREP_GOB_PUE/PUE_GOB_2018.csv",  skip = 5)
levels(as.factor(prep$DISTRITO_LOCAL))

# Municipal
prep_municipal <- read_csv("DatosPREP/20180702_2000_PREP_AYUN_PUE/PUE_AYUN_2018.csv", skip = 5)
levels(as.factor(prep_municipal$MUNICIPIO))

# Es el mismo numero de municipios que de poligonos en el .shp ??
nlevels(as.factor(prep_municipal$MUNICIPIO)) == dim(municipios)[1] # TRUE

#########################
# Match de los nombres: #
########################

# 1. Pasamos los nombres de los municipios a mayusculas
prep_municipal$MUNICIPIO <- toupper(prep_municipal$MUNICIPIO)
municipios$NOM_MUN <- toupper(municipios$NOM_MUN)

# 2. Hacemos un dataframe de los nombres de los municipios
nombres <- cbind(sort(municipios$NOM_MUN), levels(as.factor(prep_municipal$MUNICIPIO)))
# Aqui observamos que los nombres son casi identicos, a excepcion de que el .shp maneja acentos y el otro no.
# Para evitar problemas de compatibilidad, asignamos una variable al shape para tener los mismos nombres en los datos
#   municipales y en el shape.
municipios$MUNICIPIO <- levels(as.factor(prep_municipal$MUNICIPIO))


################################################
# Info de elecion Gobernador a nivel Municipio #
###############################################

# Examinamos que casilla de la eleccion estatal no se encuentra a nivel municipal #
which(prep_estatal$CLAVE_CASILLA %in% prep_municipal$CLAVE_CASILLA == FALSE) # 7548
which(prep_municipal$CLAVE_CASILLA %in% prep_estatal$CLAVE_CASILLA == FALSE) # integer(0)

# De lo anterior podemos ver que la casilla 7548 no se conto a nivel mpal pero si a nivel estatal
tail(prep_estatal)
# De aqui podemos ver que el prep estatal conto solo para elecciones municipales a las casillas 
#   de votos emitidos en Puebla, pero para la estatal los votos emitidos desde el extranjero.

# Guardamos los votos emitidos desde el extranjero
votos_extranjero <- prep_estatal[7548,]

# Eliminamos los votos emitidos desde el extranjero
prep_estatal <- prep_estatal[1:7547,]
which(prep_estatal$CLAVE_CASILLA %in% prep_municipal$CLAVE_CASILLA == FALSE) # integer(0)

# Ahora, generamos un vector de ID y municipio con prep_municipal para mergearlos con 
#   prep_estatal (debido a que no incluyen datos de que mpios emitieron los votos 🙄)

vector_nombres <- prep_municipal %>%
  select(CLAVE_CASILLA, MUNICIPIO)

# Hacemos el merge 
prep_estatal <- merge(vector_nombres, prep_estatal, by = "CLAVE_CASILLA")

# Eliminamos bases innecesarias
rm(prep_municipal, vector_nombres, nombres)

########################################## 
# Hacemos tidy de los datos a nivel mpal #
#########################################

# Para la eleccion a gobernador hubo 4 Candidatos: Martha Erika Alonso Hidalgo (PAN, PRD, MC, CPP, PSI), 
#   Jose Enrique Doger Guerrero (PRI), Luis Miguel Geronimo Barbosa Huerta(PT, MOR, PES) y 
#   Miguel Chain Carrillo (PV). Contabilizaremos los votos en base a la suma de todos los votos emitidos 
#   a todas las Coaliciones.

# Podemos hacer la suma elemento a elemento, pero como somos flojos utilizaremos el paquete rebus
library(rebus)

# Patrones rebus para cada candidato
pat_MEAH  <- or1(c("PAN", "PRD", "MC", "CPP", "PSI"))
pat_JEDG  <- or1(c("PRI"))
pat_LMGBH <- or1(c("PT", "MORENA", "PES"))
pat_MCC   <- or1(c("PV"))

# Variables del prep
vars <- names(prep_estatal)

# Variables en las que aparece cada candidato
MEAH_i  <- which(str_detect(vars, pattern = pat_MEAH))
JEDG_i  <- which(str_detect(vars, pattern = pat_JEDG))
LMGBH_i <- which(str_detect(vars, pattern = pat_LMGBH))[1:7] # Correccion, ya que "PT" captura otra cosa
MCC_i   <- which(str_detect(vars, pattern = pat_MCC))

# TOTALES POR CANDIDATO
prep_estatal$MEAH  <- rowSums(prep_estatal[,MEAH_i])
prep_estatal$JEDG  <- prep_estatal[,JEDG_i]
prep_estatal$LMGBH <- rowSums(prep_estatal[,LMGBH_i]) 
prep_estatal$MCC   <- prep_estatal[,MCC_i]

# Vector de Candidatos
candidatos <- c("MEAH", "JEDG", "LMGBH", "MCC")

# Nos quedamos solo con los totales a nivel municipal
Datos <- prep_estatal %>%
  select(MUNICIPIO, MEAH, JEDG, LMGBH, MCC) %>%
  group_by(MUNICIPIO) %>%
  summarize(MEAH = sum(MEAH, na.rm = TRUE), 
            JEDG = sum(JEDG, na.rm = TRUE), 
            LMGBH = sum(LMGBH, na.rm = TRUE), 
            MCC = sum(MCC, na.rm = TRUE)) 

# Creamos un vector que guarde el nombre del candidato ganador en cada municipio
Ganador <- vector(length = 217)
for (i in 1:217){
    Ganador[i] <- candidatos[which(Datos[i,2:5] == max(Datos[i,2:5]))]
  }

# Añadimos el vector a la base
Datos$GANADOR <- Ganador  

# Hacemos el merge con el shape del estado de Puebla
Puebla <- merge(municipios, Datos, by = "MUNICIPIO") %>%
  select(MUNICIPIO, MEAH, JEDG, LMGBH, MCC, GANADOR)

# Hacemos el plot para comprobar que es un archivo sf valido
plot(Puebla)

# Escribimos un objeto shape y un geojson
st_write(Puebla, "DatosGeograficos/Puebla.shp")
st_write(Puebla, "DatosGeograficos/Puebla.geojson")
