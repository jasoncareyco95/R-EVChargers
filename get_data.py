## Libraries
import pandas as pd
import numpy as np

def clean_names(df):
    new_df = df.copy()
    new_df.rename(
        columns = {x: x.lower().replace(" ", "_").strip() for x in new_df.columns.values.tolist()},
        inplace = True
    )
    return new_df

def get_ev_data(ev_path = None, fuel_path = None):
    
    ## Data Import
    if ev_path is None:
        ev = pd.read_csv("C:/Users/jason/Downloads/Datasets/co_ev_registrations_public.csv").pipe(clean_names)
    else:
        ev = pd.read_csv(ev_path).pipe(clean_names)
    
    if fuel_path is None:
        chg = pd.read_csv("C:/Users/jason/Downloads/Datasets/alt_fuel_stations.csv").pipe(clean_names)
    else:
        chg = pd.read_csv(fuel_path).pipe(clean_names)

    ## Clean/Organize Data
    ## EVs
    ## Make sure that registrations are active for this year
    ev.registration_expiration_date = pd.to_datetime(ev.registration_expiration_date)
    ev = ev[['zip_code', 'registration_expiration_date', 'vehicle_name', 'technology']][ev.registration_expiration_date > "2021-12-31"]

    ## Fuel Stations
    ## Make sure that charging stations have been verified in the last two years
    chg.date_last_confirmed = pd.to_datetime(chg.date_last_confirmed)
    chg["full_address"] = chg.street_address + ", " + chg.city + ", " + chg.state + " " + chg.zip.map(str)
    chg = chg[['zip', 'status_code', 'latitude', 'longitude', 'ev_network', 'facility_type', 'date_last_confirmed', 'full_address']][chg.date_last_confirmed > "2020-01-01"]
    ## Look at coordinates for charging stations because some 'chargers' may be at the same location
    chg = chg.groupby(chg.full_address).first().reset_index()

    return [ev, chg]