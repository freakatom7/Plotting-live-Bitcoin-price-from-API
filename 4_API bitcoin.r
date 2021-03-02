library('httr')
library('xts')

# set GMT timezone. See documentation
Sys.setenv(TZ='GMT')
# API base url. See documentation
baseurl <- 'https://api.kucoin.com'
# API endpoint. See documentation: Market data-> history-> get Klines
endpoint <- '/api/v1/market/candles'
# today and yesterday in seconds
today <- as.integer(as.numeric(Sys.time()))
yesterday <- today - 24*60*60
# API parameters. See documentation
param <- c(symbol = 'BTC-USDT', type = '1min', startAt = yesterday, endAt = today)

# build full url. See documentation
url <- paste0(baseurl, endpoint, '?', paste(names(param), param, sep = '=', collapse = '&'))
url
## [1] "https://api.kucoin.com/api/v1/market/candles?symbol=BTC-USDT&type=1min&startAt=1613463696&endAt=
# retrieve url
x <- GET(url)
# extract data
x <- content(x)
data <- x$data
# formatting
data <- sapply(1:length(data), function(i) {
  # extract single candle
  candle <- as.numeric(data[[i]])
  # formatting. See documentation
  return( c(time = candle[1], open = candle[2], close = candle[3], high = candle[4], low = candle[5]) )
})
# convert to xts
datetime <- as.POSIXct(data[1,], origin = '1970-01-01')
data <- xts(t(data[-1,]), order.by = datetime)
# plot closing values
plot(data$close, main = 'Bitcoin price in dollars')
