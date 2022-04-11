calculate_route <- function(..., round_trip = FALSE) {

  usethis::ui_info("Calculating route between provided positions...")

  points <- c(...) %>%
    sf::st_cast(to = "POINT") %>%
    suppressWarnings()

  ## Create a data frame of my starting and ending positions
  route_endpoints <-
    data.frame(
      geometry = points
    ) %>%
    sf::st_as_sf()

  ## Find an optimal route using the OSRM algorithm
  route_init <-
    osrm::osrmTrip(
      loc = route_endpoints,
      returnclass = "sf",
      overview = "full"
    ) %>%
    purrr::pluck(1, "trip") %>%
    dplyr::mutate(
      distance = distance * 1000
    )

  if (isTRUE(round_trip)) {

    route <-
      route_init %>%
      dplyr::summarise(
        duration = sum(duration),
        distance = sum(distance)
      )

    intersections <-
      seq(nrow(route_init)) %>%
      purrr::map_dfr(
        .f = ~{
          int_df <- data.frame(
            endpoint = .x + 1,
            points = route_init %>%
              dplyr::slice(.x) %>%
              sf::st_coordinates() %>%
              as.data.frame() %>%
              nrow()
          )
        }
      ) %>%
      dplyr::add_row(
        endpoint = 1,
        points = 0
      ) %>%
      dplyr::arrange(endpoint)

    usethis::ui_done("Route generated!")

    return(
      list(
        "route" = route,
        "intersections" = intersections
      )
    )

  } else {

    route <-
      route_init %>%
      dplyr::slice(1:(nrow(route_init) - 1)) %>%
      dplyr::summarise(
        duration = sum(duration),
        distance = sum(distance)
      )

    intersections <-
      seq(nrow(route_init) - 1) %>%
      purrr::map_dfr(
        .f = ~{
          # .x <- 1
          int_df <- data.frame(
            endpoint = .x + 1,
            points = route_init %>%
              dplyr::slice(.x) %>%
              sf::st_coordinates() %>%
              as.data.frame() %>%
              nrow()
          )
        }
      ) %>%
      dplyr::add_row(
        endpoint = 1,
        points = 0
      ) %>%
      dplyr::arrange(endpoint)

    usethis::ui_done("Route generated!")

    return(
      list(
        "route" = route,
        "intersections" = intersections
      )
    )

  }

}
