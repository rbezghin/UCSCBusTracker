# Python Library Imoprts
import requests
import json
import urllib2
import urllib
import httplib

# User library/python file imports
from BusStopData import getStopsLocation
from FetchData import getETA, getBusData, getBusType, postETAData
from ETACalc import CalcStopIntervals, CalculateETAs, NullETAs
from BusStopDetermination import determineLoopDirection


# ------------------------------------------------------------------------------------------------------
#                                     MAIN FUNCTION
# ------------------------------------------------------------------------------------------------------
# Oaks to West Remote Interior
#hahaha = getETA(36.989884, -122.067163, 36.988497, -122.064781)
#print(getETA(36.991293, -122.054782, 36.990735,  -122.052200))

#exit(1)



def main():
  Null_Buses = [75, 78, 79, 80, 84, 85, 90, 92, 93, 95, 96, 97, 98]

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
  print(json.dumps(busData, indent=2))
  # Finds which buses are active
  for BusIDs in Null_Buses:
    for active in busData['rows']:
      if(active['id'] == str(BusIDs)):
        Null_Buses.remove(BusIDs)

  print("  =>  Fetching Bus Direction Data...")

  
  # Gets the directional data on which way the bus is traveling
  busDirectionData = getBusType()

  # Checks which buses are inner loops and which are outer loops
  outerBusData = determineLoopDirection(busData, busDirectionData, "outer")
  innerBusData = determineLoopDirection(busData, busDirectionData, "inner")
  #upperBusData =




  # Calls function that returns bus ETA data
  print("  =>  Calculating Outer Loop ETAs...")
  outer_bus_data = CalculateETAs(outerBusData, OuterBusStops, OuterBusStopIntervals, "OuterBusStops")

  print("  =>  Calculating Inner Loop ETAs...")
  inner_bus_data = CalculateETAs(innerBusData, InnerBusStops, InnerBusStopIntervals, "InnerBusStops")
  
  null_inner_bus_data = NullETAs(Null_Buses, 'InnerBusStops')
  null_outer_bus_data = NullETAs(Null_Buses, 'OuterBusStops')
  
  # prints the calculated ETAs
  #print("INNER LOOP BUS DATA")
  #print(json.dumps(inner_bus_data, indent=2))
  #print("-------------------------------")
  #print("OUTER LOOP BUS DATA")
  #print(json.dumps(outer_bus_data, indent=2))

  print("  => Sending Data to Server...")

  # Posts to server
  postETAData(inner_bus_data, outer_bus_data, null_inner_bus_data, null_outer_bus_data)

while(1):
  main()
