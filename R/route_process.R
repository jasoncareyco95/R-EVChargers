route_process <- function(road_data, evc_data, route_dist, fuel_dist, n_sim = 1) {

  usethis::ui_info("Starting route process...")

  # all_roads <- sf::read_sf("C:/Users/jason/Downloads/Datasets/ev_geospatial/decompressed/all_roads.shp") %>%
  #   dplyr::mutate(
  #     speed = dplyr::case_when(
  #       level == 1 ~ 70,
  #       level == 2 ~ 45,
  #       level == 3 ~ 25
  #     ),
  #     record = dplyr::row_number()
  #   ) %>%
  #   dplyr::select(
  #     record,
  #     level,
  #     speed,
  #     geometry
  #   )
  #
  # route_dist = 402336  # 250 miles approx.
  # fuel_dist = route_dist * .25
  # n_sim = 1

  ## We should keep a log of all suggestions so that we can validate/verify why a simulation attempt failed.

  for (i in seq(n_sim)) {

    usethis::ui_info(glue::glue("Simulated travel attempt: {i}"))

    ## We need to find a starting point
    start_pos <- all_roads %>%
      dplyr::filter(level == 3) %>%
      get_start_point()

    ## We need to find an ending point
    end_pos <- all_roads %>%
      get_end_point(start_pos, route_dist)

    ## We need to calculate the route with the fastest travel time between those two points
    ## TODO I ran into a server timeout error here - maybe wrap within a tryCatch?
    route <- calculate_route(start_pos, end_pos)

    ## Travel the route until you reach the threshold to refuel
    outcome <- simulate_trip(route, route_dist, fuel_dist)

    ## If outcome is not NULL then update
    if (!is.null(outcome)) {

      ## Append outcome to EV chargers data as a suggested charging location


    }

  }

  return(invisible())

}
