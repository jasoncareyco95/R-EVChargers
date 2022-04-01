intersection_points <- function(x, y) {

  x_points <- x %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::select(-L1)

  y_points <- y %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::select(-L1)

  shared_points <- x_points %>%
    dplyr::filter(X %in% y_points$X, Y %in% y_points$Y)

  return(shared_points)

}
