get_start_point <- function(data) {

  usethis::ui_info("Selecting a starting position...")

  ## We need to read in our data and select a random point from our priority 3 roadways
  sample_road_row <- seq(nrow(data)) %>% sample(size = 1)

  ## Filter data down to sample road
  sample_road_data <- data %>%
    dplyr::slice(sample_road_row)

  ## Randomly select a pair of coordinates within the road we've selected as a starting point
  start_pos <- sample_road_data %>%
    sf::st_sample(size = 1) %>%
    suppressMessages()

  usethis::ui_done("Starting position found!")

  return(
    list(
      "road_row_num" = sample_road_data$record,
      "start_pos" = start_pos
    )
  )

}
