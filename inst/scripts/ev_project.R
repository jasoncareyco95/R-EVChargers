all_roads <- sf::read_sf("C:/Users/jason/Downloads/Datasets/ev_geospatial/decompressed/all_roads.shp") %>%
  dplyr::mutate(
    speed = dplyr::case_when(
      level == 1 ~ 70,
      level == 2 ~ 45,
      level == 3 ~ 25
    ),
    record = dplyr::row_number()
  ) %>%
  dplyr::select(
    record,
    level,
    speed,
    geometry
  )

route_dist = 402336  # 250 miles approx.
fuel_dist = route_dist * .25
# a = 1
n_sim = 30

chgs <- readr::read_csv("C:/Users/jason/Downloads/Datasets/alt_fuel_stations.csv", show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  dplyr::select(street_address, city, state, zip, longitude, latitude) %>%
  dplyr::mutate(
    full_address = paste0(street_address, ", ", city, ", ", state, " ", zip)
  ) %>%
  dplyr::group_by(
    full_address
  ) %>%
  dplyr::mutate(
    longitude = dplyr::first(longitude),
    latitude = dplyr::first(latitude)
  ) %>%
  dplyr::select(full_address, longitude, latitude) %>%
  dplyr::arrange(
    full_address
  ) %>%
  dplyr::group_by(
    full_address, longitude, latitude
  ) %>%
  dplyr::summarise(
    num_chargers = dplyr::n()
  ) %>%
  dplyr::ungroup() %>%
  sf::st_as_sf(coords = c("longitude", "latitude")) %>%
  sf::st_set_crs(sf::st_crs(all_roads)) %>%
  dplyr::mutate(
    fail_type = NA_character_
  )

route_process(all_roads, chgs, route_dist, fuel_dist, n_sim)
