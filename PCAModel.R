require("roll")
require("stats")
require("arrow")
require("ggplot2")
require("tidyverse")

df <- read_parquet("prep_data.parquet")

get_pcs <- function(df){

  df_wider <- df %>%
    pivot_wider(names_from = ticker, values_from = value) %>%
    drop_na()

  df_pca_input <- df_wider %>% select(-date)

  pca_model <- prcomp(
    df_pca_input,
    scale = TRUE,
    center = TRUE,
    rank = 3)

  pcs <- pca_model$x %>%
    as_tibble() %>%
    mutate(date = df_wider$date) %>%
    pivot_longer(!date, names_to = "PC", values_to = "value")

  return(pcs)

}

get_pcs_spread <- function(df){
  
  df_tmp <- df %>% 
    pivot_wider(names_from = contract_type, values_from = value) %>% 
    mutate(spread = SOFR - TSY) %>% 
    select(date, spread)
  
  return(df_tmp)
}

get_pcs_corr <- function(df){
  
  df_tmp <- df %>% 
    pivot_wider(names_from = contract_type, values_from = value) %>% 
    mutate(corr = roll_cor(x = SOFR, y = TSY, width = 30)) %>% 
    select(date, corr)
  
  return(df_tmp)
}

# plot some sample curves
df_sample_curves <- df %>% 
  mutate(year = as.numeric(format(date, "%Y"))) %>% 
  select(date, value, contract_type, year, contract_days) %>% 
  group_by(contract_type, year, contract_days) %>% 
  filter(date == min(date)) %>% 
  ungroup() %>%
  mutate(
    Tenor = (contract_days / 365),
    year = as.character(year)) %>% 
  select(-c(date, contract_days))

df_years <- df_sample_curves %>% 
  mutate(year = as.numeric(year)) %>% 
  select(year)

min_date <- min(df_years$year)
max_date <- max(df_years$year)

df_sample_curves %>% 
  ggplot(aes(x = Tenor, y = value, color = year)) +
  facet_wrap(~contract_type, scale = "free_x") +
  geom_point() +
  geom_line() +
  ylab("Yield (%)") +
  labs(title = paste("Yearly Curves from SOFR and TSY from", min_date, "to", max_date))

df %>% 
  filter(date == max(date)) %>% 
  mutate(tenor = (contract_days / 365)) %>% 
  select(value, tenor, contract_type) %>% 
  filter(tenor <= 30) %>% 
  rename("contract" = "contract_type") %>% 
  ggplot(aes(x = tenor, y = value, color = contract)) +
  geom_point() +
  geom_line() +
  ylab("Yield (%)") +
  labs(title = paste("SOFR and TSY Curve as of", max(df$date)))

df_pcs <- df %>% 
  select(date, ticker, value, contract_type) %>% 
  group_by(contract_type) %>% 
  group_modify(~get_pcs(.))

start_date <- min(df_pcs$date)
end_date <- max(df_pcs$date)

df_pcs %>% 
  ggplot(aes(x = date, y = value, color = PC)) +
  facet_wrap(~contract_type, nrow = 2) +
  geom_line() +
  labs(title = paste("Historical PCs from", start_date, "to", end_date))

df_pcs %>% 
  rename("contract" = "contract_type") %>% 
  ggplot(aes(x = date, y = value, color = contract)) +
  facet_wrap(~PC, nrow = 3, scale = "free_y") +
  geom_line() +
  labs(title = paste("Comparison to Historical PCs from", start_date, "to", end_date))

df_pcs_spread <- df_pcs %>% 
  group_by(PC) %>% 
  group_modify(~get_pcs_spread(.))

df_pcs_spread %>% 
  ggplot(aes(x = date, y = spread)) +
  facet_wrap(~PC, scale = "free_y", nrow = 3) +
  geom_line() +
  labs(title = paste("Spread between SOFR and TSY PCs from", start_date, "to", end_date))

df_pcs_spread %>% 
  select(-date) %>% 
  ggplot(aes(x = spread)) +
  facet_wrap(~PC, scale = "free") +
  geom_histogram(bins = 30) +
  labs(title = paste("Distribution of Spread between SOFR and TSY PCs from", start_date, "to", end_date))

df_pcs_corr <- df_pcs %>% 
  group_by(PC) %>% 
  group_modify(~get_pcs_corr(.)) %>% 
  drop_na()

df_pcs_corr %>% 
  ggplot(aes(x = date, y = corr)) +
  facet_wrap(~PC, scale = "free", nrow = 3) +
  geom_line() +
  labs(title = paste("30d Rolling Correlation of SOFR and TSY PCs from", start_date, "to", end_date))

df_pcs_corr %>% 
  mutate(corr = abs(corr)) %>% 
  ggplot(aes(x = date, y = corr)) +
  facet_wrap(~PC, scale = "free", nrow = 3) +
  geom_line() +
  labs(title = paste("30d Rolling Absolute Correlation of SOFR and TSY PCs from", start_date, "to", end_date))

df_pcs_corr %>% 
  mutate(corr = abs(corr)) %>% 
  select(-date) %>% 
  ggplot(aes(x = corr)) +
  facet_wrap(~PC, scale = "free") +
  geom_histogram() +
  labs(title = paste("Distribution of Absolute Correlation of SOFR and TSY PCs from", start_date, "to", end_date))
