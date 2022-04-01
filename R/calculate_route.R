calculate_route <- function(start_pos, end_pos) {

  usethis::ui_info("Calculating route between starting and ending positions...")

  ## Create a data frame of my starting and ending positions
  route_endpoints <-
    data.frame(
      geometry = c(
        start_pos$start_pos,
        end_pos$end_pos
      )
    ) %>%
    sf::st_as_sf()

  ## Find an optimal route using the OSRM algorithm
  route <-
    osrm::osrmTrip(
      loc = route_endpoints,
      returnclass = "sf",
      overview = "full"
    ) %>%
    purrr::pluck(1, "trip") %>%
    dplyr::mutate(
      distance = distance * 1000
    #   distance = distance / 1.609344
    ) %>%
    dplyr::slice(which(duration == min(duration)))

  ## Check if the route was reversed
  if (route$start[1] > route$end[1]) {
    route <- sf::st_reverse(route) %>%
      dplyr::select(
        -(start:end)
      )
  } else {
    route <- route %>%
      dplyr::select(
        -(start:end)
      )
  }

  usethis::ui_done("Route generated!")

  return(route)

}
