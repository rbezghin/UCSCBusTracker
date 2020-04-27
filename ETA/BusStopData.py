
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
#     # Stop_Name: Name of the bus stop to get array index of
# Returns: Index of the bus name in the json array
# ------------------------------------------------------------------------------------------------------
def NameToIndex(Stop_Name):
  # If statement that'll return the appropriate index of the given Stop Name
  if(Stop_Name == "Main_Entrance_ETA"):
    return 0
  elif(Stop_Name == "Lower_Campus_ETA"):
    return 1
  elif(Stop_Name == "Village_Farm_ETA"):
    return 2
  elif(Stop_Name == "East_Remote_ETA"):
    return 3
  elif(Stop_Name == "East_Field_House_ETA"):
    return 4
  elif(Stop_Name == "Bookstore_ETA"):
    return 5
  elif(Stop_Name == "Crown_Merrill_ETA"):
    return 6
  elif(Stop_Name == "Colleges9_10_ETA"):
    return 7
  elif(Stop_Name == "Science_Hill_ETA"):
    return 8
  elif(Stop_Name == "Kresge_ETA"):
    return 9
  elif(Stop_Name == "Porter_RCC_ETA"):
    return 10
  elif(Stop_Name == "Family_Student_Housing_ETA"):
    return 11
  elif(Stop_Name == "Oakes_FSH_ETA"):
    return 12
  elif(Stop_Name == "Arboretum_ETA"):
    return 13
  else:     # If Stop name is "Western_Drive_ETA"
    return 14
    
# ------------------------------------------------------------------------------------------------------
# PURPOSE: Function that returns the name of a bus stop based on the index given
# Input Parameters:
#     # index: Index of the array to convert to it's bus name
# Returns: Name of the bus
# ------------------------------------------------------------------------------------------------------
def IndexToName(index):
  # If statement that'll return the appropriate index of the given Stop Name
  if(index == 0):
    return "Main_Entrance_ETA"
  elif(index == 1):
    return "Lower_Campus_ETA"
  elif(index == 2):
    return "Village_Farm_ETA"
  elif(index == 3):
    return "East_Remote_ETA"
  elif(index == 4):
    return "East_Field_House_ETA"
  elif(index == 5):
    return "Bookstore_ETA"
  elif(index == 6):
    return "Crown_Merrill_ETA"
  elif(index == 7):
    return "Colleges9_10_ETA"
  elif(index == 8):
    return "Science_Hill_ETA"
  elif(index == 9):
    return "Kresge_ETA"
  elif(index == 10):
    return "Porter_RCC_ETA"
  elif(index == 11):
    return "Family_Student_Housing_ETA"
  elif(index == 12):
    return "Oakes_FSH_ETA"
  elif(index == 13):
    return "Arboretum_ETA"
  else:     # If Stop name is "Western_Drive_ETA"
    return "Western_Drive_ETA"


