# Python Library Imoprts
import requests
import json

# User library/python file imports
from BusStopData import getStopsLocation
from FetchData import getETA, getBusData
from ETACalc import CalcStopIntervals, CalculateETAs


# ------------------------------------------------------------------------------------------------------
#                                     MAIN FUNCTION
# ------------------------------------------------------------------------------------------------------

# Creates a json object that contains all the bus stop locations and their names
OuterBusStops = getStopsLocation("OuterBusStops")
InnerBusStops = getStopsLocation("InnerBusStops")

# Gets the ETA intervals between all outer and inner bus stops
OuterBusStopIntervals = CalcStopIntervals(OuterBusStops, "OuterBusStops")
InnerBusStopIntervals = CalcStopIntervals(InnerBusStops, "InnerBusStops")

# Gets the bus data (id, location, type) of all active buses from BTS3 server
busData = getBusData()

######## CREATE FUNCTION HERE THAT DETERMINES IF A BUS IS INNER OR OUTER (if it's not given) #######

# Fake Bus locatinons for testing
fakeBusLocaitons = {
  'rows': [
    {
      'id': 1,            # at base of campus (before Western Bus Stop)
      'lat': 36.978783,
      'lon': -122.057917
    },
    {
      'id': 2,            # at c9/10
      'lat': 36.999955,
      'lon': -122.057780
    }
  ]
}

# Calls function that returns bus ETA data
outer_bus_data = CalculateETAs(fakeBusLocaitons, OuterBusStops, OuterBusStopIntervals, "OuterBusStops")
inner_bus_data = CalculateETAs(fakeBusLocaitons, InnerBusStops, InnerBusStopIntervals, "InnerBusStops")

# prints the calculated ETAs
print(json.dumps(inner_bus_data, indent=2))
print("--------------------")
print(json.dumps(outer_bus_data, indent=2))


# To Do:
  # - Push bus_data to server
  # - Put main function in a while(1) loop to have it run forever

