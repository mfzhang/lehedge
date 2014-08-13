createPkMs <- function(d) {
  d$rmin <- rank(d$V1,ties.method="min")
  d$milli <- str_pad(as.integer(row.names(d)) - d$rmin + 1, 3, pad="0") 
  options(digits.secs = 3)
  d$pk <- strptime(paste(d$V1,d$milli,sep="."),"%Y%m%d %H%M%OS")
  d[,c("pk","V2")]
}

createPkStr <- function(d) {
  d$rmin <- rank(d$V1,ties.method="min")
  d$milli <- str_pad(as.integer(row.names(d)) - d$rmin + 1, 3, pad="0") 
  options(digits.secs = 3)
  d$pk <- paste(d$V1,d$milli,sep=".")
  d[,c("pk","V2")]
}
