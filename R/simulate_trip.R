simulate_trip <- function(route, route_dist, fuel_dist) {

  usethis::ui_info("Simulating trip...")

  ## Simulate traveling over the route ----
  ## First find the distance between points along the route
  route_points <-
    route %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::select(-L1) %>%
    sf::st_as_sf(coords = c("X", "Y")) %>%
    sf::st_set_crs(sf::st_crs(route)) %>%
    dplyr::mutate(
      lead = geometry[dplyr::row_number() + 1],
      distance = sf::st_distance(geometry, lead, by_element = TRUE, which = "Great Circle")
    ) %>%
    dplyr::select(-lead)

  return_trip <-
    route_points %>%
    dplyr::slice(1:(nrow(.) - 1)) %>%
    dplyr::mutate(rn = dplyr::row_number()) %>%
    dplyr::arrange(dplyr::desc(rn)) %>%
    dplyr::select(-rn)

  full_route <- route_points %>%
    dplyr::bind_rows(return_trip) %>%
    dplyr::mutate(distance = as.double(distance))

  range <- route_dist

  full_route$distance[1:100] %>%
    purrr::map_dfr(
      .f = {

        range <<- range - .x

        # if (range <= fuel_dist) {
        #
        #
        #
        # }

      }
    )

}
