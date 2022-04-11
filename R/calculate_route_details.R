calculate_route_details <- function(route, add_return_trip = FALSE) {

  usethis::ui_info("Calculating route points, distances, totals...")

  route_points <-
    route$route %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::select(-L1) %>%
    sf::st_as_sf(coords = c("X", "Y")) %>%
    sf::st_set_crs(sf::st_crs(route$route)) %>%
    dplyr::mutate(
      lead = geometry[dplyr::row_number() + 1],
      distance = sf::st_distance(geometry, lead, by_element = TRUE, which = "Great Circle")
    ) %>%
    dplyr::select(-lead)

  if (isTRUE(add_return_trip)) {

    return_trip <-
      route_points %>%
      dplyr::slice(1:(nrow(.) - 1)) %>%
      dplyr::mutate(rn = dplyr::row_number()) %>%
      dplyr::arrange(dplyr::desc(rn)) %>%
      dplyr::select(-rn)

    full_route <-
      route_points %>%
      dplyr::bind_rows(return_trip) %>%
      dplyr::mutate(
        index = dplyr::row_number(),
        distance = as.double(distance),
        total_dist = cumsum(distance)
      ) %>%
      tidyr::replace_na(list(distance = 0, total_dist = 0)) %>%
      dplyr::select(index, distance, total_dist)

    usethis::ui_done("Finished!")

    return(full_route)

  } else {

    full_route <-
      route_points %>%
      dplyr::mutate(
        index = dplyr::row_number(),
        distance = as.double(distance),
        total_dist = cumsum(distance)
      ) %>%
      tidyr::replace_na(list(distance = 0, total_dist = 0)) %>%
      dplyr::select(index, distance, total_dist)

    usethis::ui_done("Finished!")

    return(full_route)

  }

}
