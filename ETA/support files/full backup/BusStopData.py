
"""
File: BusStopData.py
Author: Rizzian Tuazon
Project: UCSC Bus Tracking System 3 (BTS3)
Description: Static Data used for ETA Calculation
"""

import json


# ------------------------------------------------------------------------------------------------------
# PURPOSE: Reads json file containing bus stop data then returns it
# Input Parameters:
#     StopType: Which stops to return (Outer or Inner Loop Stops)
# Returns: json-formatted table of all bus stops and their lats/longs
# ------------------------------------------------------------------------------------------------------
def getStopsLocation(StopType):

  # Loads the Outer Stop locations from json file
  f = open('BusStopLocations.json',)
  Outer_Stops = json.load(f)

  # Returns the outer stops
  if (StopType == "OuterBusStops"):
    return Outer_Stops['OuterBusStops']
  
  # Returns the inner stops
  else:
    return Outer_Stops['InnerBusStops']

  
# ------------------------------------------------------------------------------------------------------
# PURPOSE: Function that returns the array index of the name of the stop
# Input Parameters:
#     BusStops: Bus Stop data containing their cooridnates
#     Stop_Name: Name of the bus stop to get array index of
# Returns: Index of the bus name in the json array
# ------------------------------------------------------------------------------------------------------
def NameToIndex(BusStops, Stop_Name):
  # variable used to keep track of which index to return
  index = 0
  
  # For Loop that goes through Bus Stop data and returns index of given Stop_Name
  for stops in BusStops['BusStops']:
    if(stops['Stop_Name'] == Stop_Name):
      return index
    index += 1
    
# ------------------------------------------------------------------------------------------------------
# PURPOSE: Function that returns the name of a bus stop based on the index given
# Input Parameters:
#     # BusStops: Bus Stop data containing their cooridnates
#     # index: Index of the array to convert to it's bus name
# Returns: Name of the bus
# ------------------------------------------------------------------------------------------------------
def IndexToName(BusStops, index):
  # Returns the Stop_Name at the specified index of the specified BusStops json object
  return BusStops['BusStops'][index]['Stop_Name']


