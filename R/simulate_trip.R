simulate_trip <- function(
  route,
  start_pos,
  end_pos,
  evc_data,
  route_dist,
  fuel_dist,
  a = 2
) {

  usethis::ui_info("Simulating trip...")

  ## Simulate traveling over the route ----
  ## First find the distance between points along the route
  route_details <- calculate_route_details(route, add_return_trip = TRUE)

  ## Create a copy for simulating our trip
  sim_route <- route
  sim_route_details <- route_details

  ## Create range object based on route distance threshold
  range <- route_dist
  route_index <- 1
  trip_direction <- 1

  ## For testing
  # refuel_row_num <- sim_route_details %>%
  #   dplyr::filter(
  #     total_dist >= route_dist - fuel_dist
  #   ) %>%
  #   dplyr::pull(index) %>%
  #   dplyr::first() - 1
  # range <- range - sim_route_details %>%
  #   dplyr::slice(refuel_row_num) %>%
  #   dplyr::pull(total_dist)

  while (range > 0 && trip_direction < 3) {

    # route_index <- refuel_row_num

    usethis::ui_info(glue::glue("Driving: {route_index} / {nrow(sim_route_details)}"))

    ## Decrease range
    range <- range - sim_route_details %>%
      dplyr::slice(route_index) %>%
      dplyr::pull(distance)

    ## Signifies that we've reached the threshold to start looking for a charger
    if (range < fuel_dist) {

      usethis::ui_info("Searching for charging station...")

      ## Get the current location when we dip under the threshold
      current_location <- sim_route_details %>%
        dplyr::slice(route_index) %>%
        dplyr::pull(geometry)

      ## Search around that location for whether a charger exists
      nearest_charger <- current_location %>%
        sf::st_nearest_feature(evc_data)

      ## Pull the coordinates for the nearest charger
      nearest_chg_coords <- evc_data %>%
        dplyr::slice(nearest_charger) %>%
        dplyr::pull(geometry)

      usethis::ui_info("Charging station in range...")

      ## Pull the number of chargers at a station
      n_chg <- evc_data %>%
        dplyr::slice(nearest_charger) %>%
        dplyr::pull(num_chargers)

      ## Check for charger availability
      in_use <- stats::rpois(1, a)

      if (in_use >= n_chg) {
        charger_available <- FALSE
      } else {
        charger_available <- TRUE
      }

      if (charger_available) {

        usethis::ui_info("Charging station available! Routing to charger...")

        ## Create route to charging station
        re_route <- calculate_route(current_location, nearest_chg_coords)

        re_route_details <- calculate_route_details(re_route)

        ## Simulate travel to the charger
        for (i in seq(nrow(re_route_details))) {

          # i <- 1

          usethis::ui_info(glue::glue("Driving: {i} / {nrow(re_route_details)}"))

          range <- range - re_route_details %>%
            dplyr::slice(i) %>%
            dplyr::pull(distance)

          if (range <= 0) {

            usethis::ui_warn("Run out of charge!")

            ## If we have 0 range before reaching the charger stop
            outcome <- data.frame(
              full_address = NA_character_,
              num_chargers = 4,
              fail_type = "Chargers out of range",
              geometry = re_route_details %>%
                dplyr::slice(i) %>%
                dplyr::pull(geometry)
            ) %>%
              sf::st_as_sf()

            return(outcome)

          }

        }

        usethis::ui_info("Reached charging station... Recharged!!")

        ## Refuel - We made it to the charger
        range <- route_dist

        ## Re-route to the next point of interest (route start or end point)
        ## This is based on where we stopped along our original route to charge
        if (route_index < sim_route$intersections$points[2] && trip_direction == 1) {

          sim_route <- calculate_route(
            nearest_chg_coords,
            end_pos$end_pos
          )

          ## Generate new details for the trip
          sim_route_details <- calculate_route_details(
            sim_route,
            add_return_trip = FALSE
          )

          usethis::ui_info("Re-routing to ending destination...")

          ## Reset our index
          route_index <- 0

        } else {

          sim_route <- calculate_route(
            nearest_chg_coords,
            start_pos$start_pos
          )

          ## Generate new details for the trip
          sim_route_details <- calculate_route_details(
            sim_route,
            add_return_trip = FALSE
          )

          usethis::ui_info("Re-routing to starting destination...")

          ## Reset our index
          route_index <- 0

        }

      } else {

        if (range <= 0) {

          usethis::ui_warn("Run out of charge!")

          ## If we have 0 range before reaching the charger stop
          outcome <- data.frame(
            full_address = NA_character_,
            num_chargers = 4,
            fail_type = "Chargers unavailable",
            geometry = current_location
          ) %>%
            sf::st_as_sf()

          return(outcome)

        }

      }

    }

    if (route_index == nrow(sim_route_details) && trip_direction == 1) {

      sim_route <- calculate_route(
        nearest_chg_coords,
        start_pos$start_pos
      )

      ## Generate new details for the trip
      sim_route_details <- calculate_route_details(
        sim_route,
        add_return_trip = FALSE
      )

      usethis::ui_info("Re-routing to starting destination...")

      ## Reset our index
      route_index <- 0

      ## Update trip direction
      trip_direction <- 2

    } else if (route_index == nrow(sim_route_details) && trip_direction == 2) {

      usethis::ui_done("Finished trip!!")

      outcome <- NULL

      trip_direction <- 3

    }

    ## Index increment
    route_index <- route_index + 1

  }

}
