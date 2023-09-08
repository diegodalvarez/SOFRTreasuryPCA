require("arrow")
require("ggplot2")
require("tidyverse")

df_tickers <- read_parquet("ticker.parquet") %>% 
  mutate(ticker = str_split(CUSIP, " ", simplify = TRUE)[,1]) %>% 
  select(-CUSIP)

df <- read_parquet("data.parquet") %>% 
  left_join(df_tickers, by = "ticker")

start_date <- min(df$date)
end_date <- max(df$date)

df %>% 
  select(date, ticker, value, contract_type) %>% 
  ggplot(aes(x = date, y = value, color = ticker)) +
  facet_wrap(~contract_type, scale = "free_x") +
  geom_line() +
  theme(legend.position = "none") +
  ylab("Yield (%)") +
  labs(title = paste("SOFR rates vs. Treasury Rates Total Data", start_date, "to", end_date))

# need to find which contracts to delete because they lack too much information
good_tickers <- df %>% 
  select(ticker, value) %>% 
  group_by(ticker) %>% 
  summarise(count = n()) %>% 
  left_join(df_tickers, by = "ticker") %>% 
  select(-contract_days) %>% 
  arrange(count) %>% 
  filter(count > 3000) %>% # using 3,000 a threshold
  pull(ticker)

# now we need to find the good dates to pull the data from  
min_date <- df %>%
  filter(ticker %in% good_tickers) %>% 
  select(date, ticker) %>% 
  group_by(ticker) %>% 
  summarise(min_date = min(date)) %>% 
  filter(min_date == max(min_date)) %>% 
  pull(min_date)

df_prep <- df %>% filter(ticker %in% good_tickers & date > min_date)

start_date <- min(df_prep$date)
end_date <- max(df_prep$date)

df_prep %>% 
  select(date, ticker, value, contract_type) %>% 
  ggplot(aes(x = date, y = value, color = ticker)) +
  facet_wrap(~contract_type, nrow = 2) +
  geom_line() +
  theme(legend.position = "none") +
  ylab("Yield (%)") +
  labs(title = paste("SOFR rates vs. Treasury Rates Fitted Data", start_date, "to", end_date))

df_prep %>% write_parquet("prep_data.parquet")
