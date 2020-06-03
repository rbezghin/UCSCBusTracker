# Python Library Imoprts
import requests
import json
import urllib2
import urllib
import httplib

# User library/python file imports
from BusStopData import getStopsLocation
from FetchData import getETA, getBusData, getBusType
from ETACalc import CalcStopIntervals, CalculateETAs


# ------------------------------------------------------------------------------------------------------
#                                     MAIN FUNCTION
# ------------------------------------------------------------------------------------------------------

print("  =>  Fetching Bus Stop Coordinates...")

# Creates a json object that contains all the bus stop locations and their names
OuterBusStops = getStopsLocation("OuterBusStops")
InnerBusStops = getStopsLocation("InnerBusStops")

print("  =>  Calculating Bus Stop Intervals...")

# Gets the ETA intervals between all outer and inner bus stops
OuterBusStopIntervals = CalcStopIntervals(OuterBusStops, "OuterBusStops")
InnerBusStopIntervals = CalcStopIntervals(InnerBusStops, "InnerBusStops")

print("  =>  Fetching Real-Time Bus Data...")

# Gets the bus data (id, location, type) of all active buses from BTS3 server
busData = getBusData()

print("  =>  Fetching Bus Direction Data...")

# Gets the directional data on which way the bus is traveling
busDirectionData = getBusType()


# Fake Bus locatinons for testing
"""
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
  """


# Calls function that returns bus ETA data

print("  =>  Calculating Outer Loop ETAs...")
outer_bus_data = CalculateETAs(busData, OuterBusStops, OuterBusStopIntervals, "OuterBusStops")

print("  =>  Calculating Inner Loop ETAs...")
inner_bus_data = CalculateETAs(busData, InnerBusStops, InnerBusStopIntervals, "InnerBusStops")

# prints the calculated ETAs
print(json.dumps(inner_bus_data, indent=2))
print("--------------------")
print(json.dumps(outer_bus_data, indent=2))


# To Do:
  # - Push bus_data to server
  # - Put main function in a while(1) loop to have it run forever


# ETA Format
"""
{
  <Bus ID>: [
    {
      "StopName": "Main Entrance",
      "ETAToStop": "14.45"
    },
    {
      "StopName": "Main Entrance",
      "ETAToStop": "14.45"
    },
    ..........
  ]
}
"""

# Formatting Notes
#   -Still needs to be converted so that the bus stops contain the ETA of buses instead of
#     the buses containing the ETAs to the stops
