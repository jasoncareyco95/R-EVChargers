## Collect points contained within intersection and starting road
# connections <- intersection_points(start, intersection_records)

# start_filtered <- start %>%
#   sf::st_coordinates() %>%
#   as.data.frame() %>%
#   dplyr::filter(dplyr::between(X, start_pos$start_pos[1]))
#
# intersection_filtered <- intersection_records %>%
#   sf::st_coordinates() %>%
#   as.data.frame() %>%
#   dplyr::filter(dplyr::between(X, connections$X))
#   dplyr::slice(1:which(X == connections$X)) %>%
#   as.matrix() %>%
#   sf::st_multipoint(dim = "XYM") %>%
#   sf::st_zm()

# test1 <- intersection_records %>%
#   sf::st_intersects(data$geometry) %>%


# addition_rn <- intersection_records %>%
#   sf::st_intersects(data$geometry) %>%
#   purrr::pluck(1) %>%
#   .[. != intersection_row_nums]
#
# addition_records <- data %>%
#   dplyr::slice(additions) %>%
#   dplyr::bind_rows(route)
#
# more_additions <- addition_records %>%
#   dplyr::filter(!record %in% route$record) %>%
#   sf::st_intersects(data$geometry) %>%
#   purrr::pluck(1) %>%
#   .[. != addition_rn]
#
# test2 <- data %>%
#   dplyr::slice(additions) %>%
#   sf::st_intersects(data$geometry) %>%
#   purrr::pluck(1) %>%
#   .[. != additions]

# ## Calculate the maximum distance we would need to travel in a given direction
# xy_movement <- data.frame(
#   "X" = abs(start_pos$start_pos[[1]][1]) - abs(end_pos$end_pos[[1]][1]),
#   "Y" = -start_pos$start_pos[[1]][2] + end_pos$end_pos[[1]][2]
# )

## I want to find routes that will take the least amount of time to close the distance between my starting and ending coordinates.

## Initial Route Setup ----
## Start with the road where the starting point is located, filter to coordinates heading in the direction of the next nearest road with preference on roads heading in the direction of the end position
# For testing
# data <- all_roads

## Start with the road containing our starting coordinates
# start <- data %>%
#   dplyr::slice(start_pos$road_row_num)
#
# ## Create route based on starting point
# route <- start
#
# ## LOOP HERE
# # for (i in 1:3) {
#
# ## Check for intersections along route
# intersection_row_nums <- route %>%
#   dplyr::slice(nrow(route)) %>%
#   dplyr::pull(geometry) %>%
#   sf::st_intersects(data$geometry) %>%
#   purrr::pluck(1) %>%
#   .[. != route$record]
#
# ## Pull intersection linestrings
# intersection_records <- data %>%
#   dplyr::slice(intersection_row_nums)
#
# ## Create initial route
# route <- intersection_records %>%
#   dplyr::bind_rows(route)
#
# # }
#
# ## Find the point where my roads connect
# connections <- intersection_points(start, intersection_records)
