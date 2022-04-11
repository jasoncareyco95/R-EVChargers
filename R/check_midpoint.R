check_midpoint <- function(index, route_details, endpoint) {

  ep <- endpoint %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::select(-L1)

  midpoint <- route_details %>%
    sf::st_cast(to = 'MULTIPOINT') %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::select(-L1) %>%
    dplyr::mutate(
      rn = dplyr::row_number()
    ) %>%
    dplyr::filter(
      dplyr::between(X, ep$X[1] - .005, ep$X[1] + .005),
      dplyr::between(Y, ep$Y[1] - .005, ep$Y[1] + .005)
    ) %>%
    dplyr::mutate(
      dplyr::across(
        .cols = X:Y,
        .fns = as.character
      )
    )

  ep <- ep %>%
    dplyr::mutate(
      dplyr::across(
        .fns = as.character
      ),
      X = stringr::str_extract(X, "-[[:digit:]]{1,}.[[:digit:]]{6}"),
      Y = stringr::str_extract(Y, "[[:digit:]]{1,}.[[:digit:]]{6}")
    )

  ep_index <- midpoint %>%
    dplyr::filter(X %in% ep$X[1], Y %in% ep$Y[1])

}
