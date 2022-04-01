ev_registration_path <- "C:/Users/jason/Downloads/Datasets/co_ev_registrations_public.csv"
ev_chargers_path <- "C:/Users/jason/Downloads/Datasets/alt_fuel_stations.csv"

`%>%` <- getFromNamespace("%>%", "magrittr")

ev_regs <- readr::read_csv(ev_registration_path, show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    year = lubridate::year(lubridate::mdy(registration_valid_date))
  )

ev_chgs <- readr::read_csv(ev_chargers_path, show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    full_address = stringr::str_c(street_address, ", ", city, ", ", state, " ", zip),
    year = lubridate::year(lubridate::mdy(date_last_confirmed))
  ) %>%
  dplyr::select(
    zip,
    status_code,
    latitude,
    longitude,
    ev_network,
    facility_type,
    date_last_confirmed,
    full_address,
    year
  ) %>%
  dplyr::group_by(full_address) %>%
  dplyr::slice(1)

years <- c(ev_regs$year, ev_chgs$year) %>% 
  unique() %>%
  sort()

ev_regs_list <- years %>%
  purrr::map(
    .f = ~{
      ev_regs %>%
        dplyr::filter(year == .x)
    }
  )

ev_chgs_list <- years %>%
  purrr::map(
    .f = ~{
      ev_chgs %>%
        dplyr::filter(year == .x)
    }
  )

# names(ev_regs_list) <- years
# names(ev_chgs_list) <- years

# ev_chgs_no_empty <- ev_chgs_list %>% purrr::keep(function(x) nrow(x) > 0)
# ev_regs_no_empty <- ev_regs_list %>% purrr::keep(function(x) nrow(x) > 0)

chgs_vec <- ev_chgs_list %>% 
  purrr::map_dbl(
    .f = ~{
      nrow(.x)
    }
  )

regs_vec <- ev_regs_list %>%
  purrr::map_dbl(
    .f = ~{
      nrow(.x)
    }
  )

growth <- data.frame(
  year = years,
  chgs = chgs_vec,
  regs = regs_vec
)
