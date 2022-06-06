all_roads <- sf::read_sf("C:/Users/jason/Downloads/Datasets/ev_geospatial/all_roads.shp")

route_dist = 402336  # 250 miles approx.
fuel_dist = route_dist * .25
n_sim = 300

chgs <- sf::read_sf("C:/Users/jason/Downloads/Datasets/ev_geospatial/alt_fuel_stations.shp")

sim_outcomes <- route_process(all_roads, chgs, route_dist, fuel_dist, n_sim)

readr::write_csv(sim_outcomes, "C:/Users/jason/Downloads/Datasets/ev_sim_outcomes.csv")
