route_process <- function(road_data, evc_data, route_dist, fuel_dist, n_sim = 1) {

  usethis::ui_info("Starting route process...")

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
    route <- calculate_route(start_pos$start_pos, end_pos$end_pos)

    if (route$route$distance < route_dist - fuel_dist) {

      usethis::ui_info("Route not long enough to require charge...")

      outcome <- NULL

    } else {

      ## Travel the route until you reach the threshold to refuel
      outcome <- simulate_trip(route, start_pos, end_pos, evc_data, route_dist, fuel_dist)

    }

    ## If outcome is not NULL then update
    if (!is.null(outcome)) {

      usethis::ui_info("Route was unsuccessful... Appending suggestion to charger data...")

      ## Append outcome to EV chargers data as a suggested charging location
      evc_data <- evc_data %>%
        dplyr::bind_rows(outcome)

    }

  }

  usethis::ui_done("Route process finished!!")

  return(evc_data)

}
