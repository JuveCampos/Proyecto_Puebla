# Librerias
library(leaflet)
library(sf)
library(tidyverse)

# Mapas
mapa <- st_read("ResultadosExtraordinaria2019PUE.geojson")
plot(mapa, max.plot = 1)

# Mapa 1. Ganador
paleta <- colorFactor(c("#439e3b", "#001885", "#d02a21"), mapa$Ganador)

leaflet(mapa, options = leafletOptions(zoomControl = FALSE)) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(highlightOptions = highlightOptions(color = "white"),
              color = "#444444", 
              weight = 0.5, 
              smoothFactor = 0.5, 
              opacity = 1, 
              fillOpacity = 0.8, 
              #dashArray = c("3,3"),
              fillColor = paleta(mapa$Ganador)) %>% 
  addScaleBar(position = "bottomright") %>%   
  addLegend(position = "bottomleft", 
            pal = paleta, 
            values = mapa$Ganador, 
            title = "Ganador a nivel Municipal<br>Elección extraordinaria en Puebla (2019)", 
            labFormat = labelFormat(prefix = ""))
  