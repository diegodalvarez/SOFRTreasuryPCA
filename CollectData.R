require("arrow")
require("Rblpapi")
require("lubridate")
require("tidyverse")

get_contract_days <- function(df){
  
  df_period <- tibble(
    period = c("W", "M", "Y"),
    period_days = c(7, 30, 365))
  
  df_tmp <- df %>% 
    select(Tenor, CUSIP) %>% 
    mutate(
      period = substr(Tenor, nchar(Tenor), nchar(Tenor)),
      period_num = as.double(substr(Tenor, nchar(Tenor) - 2, nchar(Tenor) - 1))) %>% 
    left_join(y = df_period, by = "period") %>% 
    mutate(contract_days = period_num * period_days) %>% 
    select(Tenor, CUSIP, contract_days)
  
  return (df_tmp)
  
}

df_sofr <- get_contract_days(read_csv("SOFRTickers.csv"))
df_tsy <- get_contract_days(read_csv("TSYTickers.csv"))
df_combined <- df_sofr %>% 
  mutate(contract_type = "SOFR") %>% 
  bind_rows(
    df_tsy %>% 
      mutate(contract_type = "TSY"))

tickers <- df_combined %>% pull(CUSIP)
end_date <- Sys.Date()
start_date <- end_date - years(50)

con <- blpConnect()
raw_df <- bdh(
  securities = tickers,
  fields = "PX_LAST",
  start.date = start_date,
  end.date = end_date)

out_df <- tibble()

counter = 1
for (i in raw_df){
  
  df_tmp <- i
  name <- str_split(names(raw_df)[counter], " ")[[1]][1]
  counter <- counter + 1
  
  tibble_tmp <- df_tmp %>%
    tibble() %>%
    rename(!!name := PX_LAST) %>%
    pivot_longer(!date, names_to = "ticker", values_to = "value")
  
  out_df <- bind_rows(out_df, tibble_tmp)
}

write_parquet(out_df, "data.parquet")
write_parquet(df_combined, "ticker.parquet")
