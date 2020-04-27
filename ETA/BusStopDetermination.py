
"""
File: BusStopDetermination.py
Author: Rizzian Tuazon
Project: UCSC Bus Tracking System 3 (BTS3)
Description: Functions which determines the first bus stop a bus approaches (it's on its way to)
"""

# Import Python Libraries
import requests
import json

# User library/python file imports
from FetchData import getETA


# ------------------------------------------------------------------------------------------------------
# PURPOSE: Function that determines which bus stop the bus is approaching
# Input Parameters:
#     BusLat/BusLon: Coordinates of the bus
# Returns: Array containing the data (name, lat, lon) of the bus stop the bus is approaching
# ------------------------------------------------------------------------------------------------------
def ApproachingBusStop(BusLat, BusLon, Outer_Stops):

  # Variables used to keep track of the one of the bus stops that the bus is in between
  ClosestStop = ""       # Keeps track of the name of ONE OF the bus stop the bus is closest to
  ClosestLat = 0;        # Keeps track of the Lat of ONE OF the bus stops the bus is closest to
  ClosetLon = 0;          # Keeps track of the Lon of ONE OF the bus stops the bus is closest to
  ClosestETA = 999999;   # Keeps track of the ETA between the bus and ONE OF the bus stops the bus is closest to

  # Calculates all ETAs from bus location to bus stop
  for stops in Outer_Stops['BusStops']:

    # Calculates the ETA between the bus and all the bus stops
    eta = getETA(BusLat, BusLon, stops['lat'], stops['lon'])
    #print(str(eta) + " min to " + stops['Stop_Name'])
    
    # If a closer bus stop is found, replace the closest bus stop that was previuosly saved
    if (eta < ClosestETA):
      ClosestStop = stops['Stop_Name']
      ClosestLat = stops['lat']
      ClosestLon = stops['lon']
      ClosestETA = eta
      #print("******SAVING ETA to " + ClosestStop)

  # Returns result of the function that calculates which bus stop a bus is/will approach
  return determineNextStop(BusLat, BusLon, ClosestStop, Outer_Stops)
  
    
# ------------------------------------------------------------------------------------------------------
# PURPOSE: -Helper function for ApproachingBusStop() Funciton
#          -Will determine exactly which bus stop the bus is approaching based on coordinates
# Input Parameters:
#     BusLat/BusLon: Coordinates of the bus
#     StopName: Name of the closest Bus stop
#     Outer_Stops: json object of all bus stop data
# Returns: Name of bus stop that the bus is approaching
# ------------------------------------------------------------------------------------------------------
def determineNextStop(BusLat, BusLon, StopName, Outer_Stops):
  
  # If-else statement that distinguishes which bus stop
  if (StopName == "Main_Entrance_ETA"): #if closest stop is main entrance
    if(BusLat < Outer_Stops['BusStops'][0]['lat']):
      return "Main_Entrance_ETA"
    else:
      return "Lower_Campus_ETA"
  elif(StopName == "Lower_Campus_ETA"):           # if closest stop is Lower Campus
    if(BusLat < Outer_Stops['BusStops'][1]['lat'] or BusLon < Outer_Stops['BusStops'][1]['lon']):
      return "Lower_Campus_ETA"
    else:
      return "Village_Farm_ETA"
  elif(StopName == "Village_Farm_ETA"):           # if closest stop is Village Farm
    if(BusLat < Outer_Stops['BusStops'][2]['lat']):
      return "Village_Farm_ETA"
    else:
      return "East_Remote_ETA"
  elif(StopName == "East_Remote_ETA"):            # if closest stop is Each Remote
    if(BusLat < Outer_Stops['BusStops'][3]['lat']):
      return "East_Remote_ETA"
    else:
      return "East_Field_House_ETA"
  elif(StopName == "East_Field_House_ETA"):    # if closest stop is East Field House
    if(BusLat < Outer_Stops['BusStops'][4]['lat']):
      return "East_Field_House_ETA"
    else:
      return "Bookstore_ETA"
  elif(StopName == "Bookstore_ETA"):              # if closest stop is Bookstore
    if(BusLat < Outer_Stops['BusStops'][5]['lat']):
      return "Bookstore_ETA"
    else:
      return "Crown_Merrill_ETA"
  elif(StopName == "Crown_Merrill_ETA"):          # if closest stop is Crown/Merill
    if(BusLat < Outer_Stops['BusStops'][6]['lat'] or BusLon > Outer_Stops['BusStops'][6]['lon']):
      return "Crown_Merrill_ETA"
    else:
      return "Colleges9_10_ETA"
  elif(StopName == "Colleges9_10_ETA"):           # if closest stop is College 9/10
    if(BusLon > Outer_Stops['BusStops'][7]['lon']):
      return "Colleges9_10_ETA"
    else:
      return "Science_Hill_ETA"
  elif(StopName == "Science_Hill_ETA"):           # if closest stop is Science Hill
    if(BusLon > Outer_Stops['BusStops'][8]['lon']):
      return "Science_Hill_ETA"
    else:
      return "Kresge_ETA"
  elif(StopName == "Kresge_ETA"):                 # if closest stop is Kresge
    if(BusLat > Outer_Stops['BusStops'][9]['lat']):
      return "Kresge_ETA"
    else:
      return "Porter_RCC_ETA"
  elif(StopName == "Porter_RCC_ETA"):             # if closest stop is Porter
    if(BusLat > Outer_Stops['BusStops'][10]['lat']):
      return "Porter_RCC_ETA"
    else:
      return "Family_Student_Housing_ETA"
  elif(StopName == "Family_Student_Housing_ETA"): # if closest stop is Family Student Housing
    if(BusLat > Outer_Stops['BusStops'][11]['lat']):
      return "Family_Student_Housing_ETA"
    else:
      return "Oakes_FSH_ETA"
  elif(StopName == "Oakes_FSH_ETA"):              # if closest stop is Oaks
    if(BusLat > Outer_Stops['BusStops'][12]['lat']):
      return "Oakes_FSH_ETA"
    else:
      return "Arboretum_ETA"
  elif(StopName == "Arboretum_ETA"):           # if closest stop is is arborettum
    if(BusLat > Outer_Stops['BusStops'][13]['lat']):
      return "Arboretum_ETA"
    else:
      return "Western_Drive_ETA"
  else:                                           # if IntervalStop = "Western_Drive_ETA"
    if(BusLat > Outer_Stops['BusStops'][14]['lat']):
      return "Western_Drive_ETA"
    else:
      return "Main_Entrance_ETA"
