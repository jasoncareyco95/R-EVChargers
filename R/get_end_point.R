get_end_point <- function(data, start_pos, route_dist) {

  usethis::ui_info("Selecting an ending position...")

  ## I need to find an ending position at LEAST however far my end_dist is away from my start position
  valid_endpoints <- start_pos$start_pos %>%
    sf::st_distance(data[, 1]) %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(
      # dist_mi = as.double(`.` / 1609.344),
      dist = as.double(`.`),
      index = dplyr::row_number()
    ) %>%
    dplyr::filter(
      dist >= route_dist / 2
    ) %>%
    dplyr::select(
      index,
      dist
    )

  sample_road_row <- seq(nrow(valid_endpoints)) %>%
    sample(size = 1)

  end_pos <- data %>%
    dplyr::slice(
      valid_endpoints$index[sample_road_row]
    ) %>%
    sf::st_sample(size = 1) %>%
    suppressMessages()

  usethis::ui_done("Ending position found!")

  return(
    list(
      "road_row_num" = valid_endpoints$index[sample_road_row],
      "end_pos" = end_pos
    )
  )

}
