# Librerias
library(sf)
library(leaflet)
library(tidyverse)
library(stringr)
library(rebus)

# Funciones
niveles <- function(x) levels(as.factor(x))

### LEEMOS LOS DATOS 
munic <-         read.csv("20190602_2345_PREP_AYUN_PUE/PUE_AYUN_ext_2019.csv", sep = "|", encoding = "latin1", skip = 5)
res_ayun_2018 <- read.csv("PUE_AYUN_2018.csv", skip = 5)
prep <- read.csv("20190603_0915_PREP_PUE/20190603_0915_PREP_GUB_PUE/PUE_GUB_ext_2019.csv", skip = 5, sep = "|", encoding = "latin1")
mapa <- st_read("Puebla.geojson", quiet = T) %>% 
  select(MUNICIPIO)

# Procesamiento
munic$CLAVE_CASILLA <- str_remove_all(munic$CLAVE_CASILLA, pattern = "\\'")
res_ayun_2018$CLAVE_CASILLA <- str_remove_all(res_ayun_2018$CLAVE_CASILLA, pattern = "\\'")
prep$CLAVE_CASILLA <- str_remove_all(prep$CLAVE_CASILLA, pattern = "\\'")

# Extraemos los 5 primeros digitos de la clave casilla para hacer match con los municipios
munic$cd <- str_extract(munic$CLAVE_CASILLA, pattern = "\\d\\d\\d\\d\\d\\d")
res_ayun_2018$cd <- str_extract(res_ayun_2018$CLAVE_CASILLA, pattern = "\\d\\d\\d\\d\\d\\d")
prep$cd <- str_extract(prep$CLAVE_CASILLA, pattern = "\\d\\d\\d\\d\\d\\d")

# Sacamos los municipios con nuestra clave de 5 digitos  
names(res_ayun_2018)
lista_municipios <- res_ayun_2018 %>% 
  select(cd, MUNICIPIO)

# Eliminamos casillas con reporte de 'No identificadas - Fuera del catálogo'
# prep <- prep[(prep$cd %in% res_ayun_2018$cd),]

# Mergeamos bases
prep <- merge(prep, lista_municipios, by = "cd", all.x = T) %>% 
  unique()

#########
# Votos #
#########

# 1. Exploramos la base
names(prep)
lapply(prep[,15:37], class) # TOdas son variables categ'oricas
lapply(prep[,15:37], levels)

# Convertimos a numericos todos los datos 
fn <- function(x) as.numeric(as.character(x))
prep[,15:37] <- lapply(prep[,15:37], fn)
lapply(prep[,15:37], niveles)

# Declaramos datos 
candidatos <- c("Enrique Cárdenas Sánchez", 
                "Alberto Jiménez Merino",
                "Luis Miguel Gerónimo Barbosa Huerta")

iniciales <- c("ECS", "AJM", "LMGBH")

# Totales de Votos
prep$ECS <- rowSums(prep[,c("PAN","PRD","MC", "C_PAN_PRD_MC", 
                            "C_PAN_PRD", "C_PAN_MC", "C_PRD_MC")])
prep$AJM <- prep[,"PRI"]
prep$LMGBH <- rowSums(prep[,c("PVEM", "MORENA", "PT", "C_PT_PVEM_MORENA",
                              "C_PT_PVEM","C_PT_MORENA", "C_PVEM_MORENA")])


# Armamos la base
levels(prep$MUNICIPIO)

datos <- prep %>% 
  select(ECS, AJM, LMGBH, TOTAL_VOTOS, LISTA_NOMINAL, MUNICIPIO, DISTRITO) %>% 
  filter(!is.na(MUNICIPIO)) %>% 
  group_by(MUNICIPIO) %>% 
  summarise(ECS = sum(ECS, na.rm = TRUE), 
            AJM = sum(AJM, na.rm = TRUE), 
            LMGBH = sum(LMGBH, na.rm = TRUE), 
            Total_Votos = sum(TOTAL_VOTOS, na.rm = TRUE),
            ListaNominal = sum(LISTA_NOMINAL, na.rm = TRUE)
            )

Ganador <- c()
for (i in 1:nrow(datos)){
  Ganador[i] <- candidatos[which(datos[i,2:4] == max(datos[i,2:4]))]
}

# Aniadimos columna de ganador
datos$Ganador <- Ganador

# Metemos datos geograficos
datos1 <- merge(datos, mapa, by = "MUNICIPIO")
st_write(datos1, "ResultadosExtraordinaria2019PUE.geojson")
