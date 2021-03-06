#' Performs data acquisition from data received from TCP
#'
#' @param port [numeric] (**required**): Number of the port
#' @param timestamp [logical] (**with default**): Is a timestamp available in the data?
#' @param timeout [integer] (**optional**): the timeout (in seconds) to be used for this connection.
#'
#' @examples
#' \dontrun{
#' ##==========================================
#' ## Example 1: read data from TCP connecntion
#' ##==========================================
#'
#' data <- execute_TCP(port = 5555, timestamp = T)
#' ## start HyperIMU app
#'
#' }
#' @md
#' @export

execute_TCP <- function(port,
                        timestamp = FALSE,
                        timeout = 10) {

  ##============================================================================##
  ##ERROR HANDLING
  ##============================================================================##

  if(missing(port))
    stop("[execute_TCP()] Please provide a port", call. = FALSE)

  if(class(port) != "numeric")
    stop("[execute_TCP()] Argument port has to be of type numeric", call. = FALSE)

  if(class(timestamp) != "logical")
    stop("[execute_TCP()] Argument timestamp has to be of type logical",  call. = FALSE)

  ## open TCP connection

  cat("[execute_TCP()] >> Waiting for connection ...")
  con <- socketConnection("localhost", port = port, server = T, timeout = timeout)

  cat(paste0(" \n[execute_TCP()] >> Listening on port ", port))
  line <- readLines(con)
  close(con)
  cat("\n[execute_TCP()] >> Close connection")

  ## check for sensor names

  header_temp <- unlist(strsplit(line[1], ","))

  suppressWarnings( # because as.numeric from character gives warnings

    if(any(is.na(as.numeric(header_temp)))){

      header <- header_temp
      ## remove first line, because this is the sensor list
      temp_data <- line[-1]

    } else {

      header <- NA
      temp_data <- line
    }
  )

  ## transform data
  sensor_data_all <- lapply(temp_data, FUN = function(x){
    as.numeric(unlist(strsplit(x, ",")))
  })

  sensor_data_all <- as.data.frame(do.call(rbind, sensor_data_all))

  colnames(sensor_data_all) <- header


  if(!timestamp && (ncol(sensor_data_all) %% 3 == 1)){
    cat("\n[execute_TCP()]: ")
    cat("Timestamp detected. Used first coloumn as timestamp.\n")
    timestep <- TRUE
    # convert from UNIX time
    sensor_data_all[,1] <- as.POSIXct(sensor_data_all[,1]/1000, origin = "1970-01-01")
  }

  if(timestamp && (ncol(sensor_data_all) %% 3 == 1)){
    # convert from UNIX time
    sensor_data_all[,1] <- as.POSIXct(sensor_data_all[,1]/1000, origin = "1970-01-01")
  }
  if(timestamp && (ncol(sensor_data_all) %% 3 != 1)){
    cat("\n[execute_TCP()]:")
    cat("No timestamp detected, but argument 'timestep = TRUE`. Set to 'FALSE'.\n")
    timestep <-  FALSE
  }

  return(sensor_data_all)
}
