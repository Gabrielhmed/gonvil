library(plumber)
library(googlesheets4)
library(dplyr)
library(stringr)

# Autenticación
gs4_auth(path = "tractosgonvil-8684034c86af.json")

# ID de la hoja
sheet_id <- "1J2Hcx7aCpUggbF2SXhixrW7ZIq4xNloO_pOtJJnSWOU"

# Número de Chuy (asegúrate que coincida con el que llega desde Twilio)
numero_chuy <- "+5218118258421"

#* Webhook WhatsApp desde Twilio
#* @post /whatsapp
function(req, res) {
  from <- req$HTTP_FROM
  body <- tolower(req$postBody)
  
  if (!str_detect(from, numero_chuy)) {
    return("❌ Solo Chuy puede autorizar.")
  }
  
  # Extrae comando y unidad
  if (str_detect(body, "aprobar")) {
    unidad <- str_extract(body, "\\d+")
    if (is.na(unidad)) return("❌ Unidad no detectada.")
    
    solicitudes <- read_sheet(sheet_id, sheet = "solicitudes")
    fila <- which(solicitudes$NUMERO_UNIDAD == as.numeric(unidad) &
                    solicitudes$ESTATUS == "Pendiente")
    
    if (length(fila) == 1) {
      solicitudes$ESTATUS[fila] <- "Aprobada"
      sheet_write(solicitudes, ss = sheet_id, sheet = "solicitudes")
      
      nueva_ubicacion <- solicitudes$UBICACION_SOLICITADA[fila]
      nueva_fila <- data.frame(
        FECHA = Sys.Date(),
        NUMERO_UNIDAD = as.numeric(unidad),
        UBICACION = nueva_ubicacion,
        APROBADO_POR = "Chuy"
      )
      
      sheet_append(ss = sheet_id, data = nueva_fila, sheet = "locaciones")
      
      # (Opcional: aquí podrías usar Twilio otra vez para enviar WhatsApp a Jaime)
      
      return(paste0("✅ Unidad ", unidad, " aprobada y registrada en ", nueva_ubicacion))
    } else {
      return("⚠️ No hay solicitud pendiente para esa unidad.")
    }
  }
  
  return("ℹ️ Comando no reconocido. Usa: APROBAR <número unidad>")
}


