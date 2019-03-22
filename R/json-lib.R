library(R6)
library(jsonlite)


#' Json Paged Scraper class
#' @export
JsonPagedScraper.class <- R6Class("JsonPagedScraper.class",
   public = list(
     #parameters
     max.csv.rows = NA,
     out.filename = NA,
     #state
     row.counter    = NA,
     filenames.counter = 0,
     processed.data = NA,
     saved.filenames = NA,
     initialize = function(max.csv.rows = 10000,
                           out.filename = "~/afip/processed/afip"
     ){
       self$processed.data <- NULL
       self$max.csv.rows    <- max.csv.rows
       self$out.filename    <- out.filename
       self$saved.filenames <- NULL
     },
     initProcessedData = function(){
       self$processed.data <- data.frame(stringsAsFactors = FALSE)
     },
     processPage = function(json, max.rows=0){
       json <<- json

       print(names(json))
       n <- nrow(json)

       time.begin <- Sys.time()
       phase.begin <- Sys.time()
       if (max.rows >0){
         n <- min(n, max.rows)
       }
       tenperc <- max(round(n*.1), 1)

       print(paste("rows",n))
       for (i in seq_len(n)){
         persona <- json[i,]
         #persona <<- persona

         ret.current <- self$processed.data[0,]


         if (i  %% tenperc ==0){
           current.time <- round(difftime(Sys.time(), phase.begin, units = "sec"))
           total.time   <- round(difftime(Sys.time(), time.begin, units = "sec"))
           print(paste("Processed ",round(i/n*100), "% ", i,"/",n," in ", current.time,
                       " secs", ". Total time ", total.time,sep=""))
           phase.begin <- Sys.time()
         }
         stop("debug")

         #ret <- rbind(ret, ret.current)
         self$processed.data[nrow(self$processed.data)+1,] <- ret.current
         if (nrow(self$processed.data) >= self$max.csv.rows){
           current.file <- paste(self$out.filename,"_",self$filenames.counter,".csv", sep = "")
           print(paste("Saving csv", self$filenames.counter, current.file))
           write.csv(self$processed.data,
                     file = current.file,
                     row.names = FALSE)
           self$filenames.counter <- self$filenames.counter + 1
           self$initProcessedData()
         }
       }
       self$processed.data
     }
   ))
