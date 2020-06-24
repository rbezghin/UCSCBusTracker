
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
#     Outer_Stops: json file containing data for all bus stops
#     StopType: whether the bus is an inner or outer loop
# Returns: Array containing the data (name, lat, lon) of the bus stop the bus is approaching
# ------------------------------------------------------------------------------------------------------
def ApproachingBusStop(BusLat, BusLon, Bus_Stops, StopType):
  # Variables used to keep track of the one of the bus stops that the bus is in between
  ClosestStop = ""       # Keeps track of the name of ONE OF the bus stop the bus is closest to
  ShortestLatDifference = 999;
  ShortestLonDifference = 999;

  # Gets the Bus stops in the general area that the bus is at
  Area = DetermineBusArea(BusLat, BusLon, StopType);
  
  # Finds the closest Bus Stop
  for BusStopIndex in Area:
    LatDifference = abs(Bus_Stops['BusStops'][BusStopIndex]['lat'] - float(BusLat))
    LonDifference = abs(Bus_Stops['BusStops'][BusStopIndex]['lon'] - float(BusLon))
    if(float(LatDifference) < float(ShortestLatDifference) and float(LonDifference) < float(ShortestLonDifference)):
      ShortestLonDifference = abs(LonDifference)
      ShortestLatDifference = abs(LatDifference)
      ClosestStop = Bus_Stops['BusStops'][BusStopIndex]['Stop_Name']
  
  # Determines if Bus is approaching or going away from the closest bus stop
  if(StopType == "OuterBusStops"):
    return (determineNextOuterStop(BusLat, BusLon, ClosestStop, Bus_Stops))
  else:
    return (determineNextInnerStop(BusLat, BusLon, ClosestStop, Bus_Stops))
    
  
  
# ------------------------------------------------------------------------------------------------------
# PURPOSE: Function that determines which area the bus is currently at
# Input Parameters:
#     BusLat/BusLon: Coordinates of the bus
#     Outer_Stops: json file containing data for all bus stops
#     StopType: whether the bus is an inner or outer loop
# Returns: integer coresponding to the area | Bus Stop Indeces to check corresponding the area the bus is at
#           ->0 = East Entrance to Main Entrance Area
#           ->1 = Main Entrance to Crown/Merrill Area
#           ->2 = Crown/Merrill to Kresge Area
#           ->3 = Kresge to West Entrance Area
#           ->4 = West Entrance to East Entrance Area
# ------------------------------------------------------------------------------------------------------
def DetermineBusArea(BusLat, BusLon, BusType):
  # (East Entrance to Main Entrance Area) == (36.977212, -122.053670) to (36.982082, -122.051005)
  if(float(BusLat) < 36.977212 and float(BusLat) > 36.982082 and float(BusLon) > -122.053670 and float(BusLon) < -122.051005):
    print("Bus is at East Entrance to Main Entrance Area")
    if(BusType == "OuterBusStops"):
      return {0, 1}
    else:
      return {12, 13}
    #return 0

  # (Main Entrance to Crown/Merrill Area) == (36.982082, -122.051005) to (36.998797, -122.054963)
  elif(float(BusLat) > 36.982082 and float(BusLat) < 36.998797 and float(BusLon) < -122.051005 and float(BusLon) > -122.055772):
    print("Bus is at Main Entrance to Crown/Merill Area")
    if(BusType == "OuterBusStops"):
      return {2, 3, 4, 5, 6, 7}
    else:
      return {10, 11, 12, 13}

  # (Crown Merrill to Kresge area) == (36.998797, -122.054963) to (37.000228, -122.064207)
  elif(float(BusLat) > 36.998797 and float(BusLat) < 37.000228 and float(BusLon) < -122.054963 and float(BusLon) > -122.064207):
    print("Bus is at Crown/Merill to Kresge Area")
    if(BusType == "OuterBusStops"):
      return {7, 8, 9, 10}
    else:
      return {7, 8, 9, 10}

  # (Kresge to West Entrance area) == (36.998797, -122.053163) to (36.987844, -122.068713) -122.063251
  elif(float(BusLat) < 36.999412 and float(BusLat) > 36.987844 and float(BusLon) < -122.063251 and float(BusLon) > -122.068713):
    print("Bus is at Kresge to West Entrance Area")
    if(BusType == "OuterBusStops"):
      return {10, 11, 12, 13}
    else:
      return {3, 4, 5, 6, 7}

  # (West Entrance to  East Entrance area) == (36.987844, -122.068713) to (36.977212, -122.053670)
  else:
    print("Bus is at West Entrance to East Entrance Area")
    if(BusType == "OuterBusStops"):
      return {13, 14, 15}
    else:
      return {0, 1, 2, 3}
    
  
    
# ------------------------------------------------------------------------------------------------------
# PURPOSE: -Helper function for ApproachingBusStop() Funciton
#          -Will determine exactly which bus stop the bus is approaching based on coordinates
# Input Parameters:
#     BusLat/BusLon: Coordinates of the bus
#     StopName: Name of the closest Bus stop
#     Outer_Stops: json object of all bus stop data
# Returns: Name of bus stop that the bus is approaching
# ------------------------------------------------------------------------------------------------------
def determineNextOuterStop(BusLat, BusLon, StopName, Outer_Stops):
  
  # If-else statement that distinguishes which bus stop
  if (StopName == "Main_Entrance_ETA"): #if closest stop is main entrance
    if(float(BusLat) < float(Outer_Stops['BusStops'][0]['lat'])):
      return "Main_Entrance_ETA"
    else:
      return "Lower_Campus_ETA"
  elif(StopName == "Lower_Campus_ETA"):           # if closest stop is Lower Campus
    if(float(BusLat) < float(Outer_Stops['BusStops'][1]['lat']) or float(BusLon) < float(Outer_Stops['BusStops'][1]['lon'])):
      return "Lower_Campus_ETA"
    else:
      return "Village_Farm_ETA"
  elif(StopName == "Village_Farm_ETA"):           # if closest stop is Village Farm
    if(float(BusLat) < float(Outer_Stops['BusStops'][2]['lat'])):
      return "Village_Farm_ETA"
    else:
      return "East_Remote_ETA"
  elif(StopName == "East_Remote_ETA"):            # if closest stop is Each Remote
    if(float(BusLat) < float(Outer_Stops['BusStops'][3]['lat'])):
      return "East_Remote_ETA"
    else:
      return "East_Remote_Interior_ETA"
      
  #***********************************************
  elif(StopName == "East_Remote_Interior_ETA"):            # if closest stop is Each Remote
    if(float(BusLat) < float(Outer_Stops['BusStops'][4]['lat'])):
      return "East_Remote_Interior_ETA"
    else:
      return "East_Field_House_ETA"
  #***********************************************
  
      
  elif(StopName == "East_Field_House_ETA"):    # if closest stop is East Field House
    if(float(BusLat) < float(Outer_Stops['BusStops'][5]['lat'])):
      return "East_Field_House_ETA"
    else:
      return "Bookstore_ETA"
  elif(StopName == "Bookstore_ETA"):              # if closest stop is Bookstore
    if(float(BusLat) < float(Outer_Stops['BusStops'][6]['lat'])):
      return "Bookstore_ETA"
    else:
      return "Crown_Merrill_ETA"
  elif(StopName == "Crown_Merrill_ETA"):          # if closest stop is Crown/Merill
    if(float(BusLat) < float(Outer_Stops['BusStops'][7]['lat']) or float(BusLon) > float(Outer_Stops['BusStops'][7]['lon'])):
      return "Crown_Merrill_ETA"
    else:
      return "Colleges9_10_ETA"
  elif(StopName == "Colleges9_10_ETA"):           # if closest stop is College 9/10
    if(float(BusLon) > float(Outer_Stops['BusStops'][8]['lon'])):
      return "Colleges9_10_ETA"
    else:
      return "Science_Hill_ETA"
  elif(StopName == "Science_Hill_ETA"):           # if closest stop is Science Hill
    if(float(BusLon) > float(Outer_Stops['BusStops'][9]['lon'])):
      return "Science_Hill_ETA"
    else:
      return "Kresge_ETA"
  elif(StopName == "Kresge_ETA"):                 # if closest stop is Kresge
    if(float(BusLat) > float(Outer_Stops['BusStops'][10]['lat'])):
      return "Kresge_ETA"
    else:
      return "Porter_RCC_ETA"
  elif(StopName == "Porter_RCC_ETA"):             # if closest stop is Porter
    if(float(BusLat) > float(Outer_Stops['BusStops'][11]['lat'])):
      return "Porter_RCC_ETA"
    else:
      return "Family_Student_Housing_ETA"
  elif(StopName == "Family_Student_Housing_ETA"): # if closest stop is Family Student Housing
    if(float(BusLat) > float(Outer_Stops['BusStops'][12]['lat'])):
      return "Family_Student_Housing_ETA"
    else:
      return "Oakes_FSH_ETA"
  elif(StopName == "Oakes_FSH_ETA"):              # if closest stop is Oaks
    if(float(BusLat) > float(Outer_Stops['BusStops'][13]['lat'])):
      return "Oakes_FSH_ETA"
    else:
      return "Arboretum_ETA"
  elif(StopName == "Arboretum_ETA"):           # if closest stop is is arborettum
    if(float(BusLat) > float(Outer_Stops['BusStops'][14]['lat'])):
      return "Arboretum_ETA"
    else:
      return "Western_Drive_ETA"
  else:                                           # if IntervalStop = "Western_Drive_ETA"
    if(float(BusLat) > float(Outer_Stops['BusStops'][15]['lat'])):
      return "Western_Drive_ETA"
    else:
      return "Main_Entrance_ETA"



# ------------------------------------------------------------------------------------------------------
# PURPOSE: -Helper function for ApproachingBusStop() Funciton
#          -Will determine exactly which bus stop the bus is approaching based on coordinates
# Input Parameters:
#     BusLat/BusLon: Coordinates of the bus
#     StopName: Name of the closest Bus stop
#     Outer_Stops: json object of all bus stop data
# Returns: Name of bus stop that the bus is approaching
# ------------------------------------------------------------------------------------------------------
def determineNextInnerStop(BusLat, BusLon, StopName, Inner_Stops):
  
  # If-else statement that distinguishes which bus stop
  if (StopName == "Barn_Theater_ETA"): #if closest stop is main entrance
    if(float(BusLat) > float(Inner_Stops['BusStops'][0]['lat'])):
      return "Barn_Theater_ETA"
    else:
      return "Western_Drive_ETA"
  elif(StopName == "Western_Drive_ETA"):           # if closest stop is Lower Campus
    if(float(BusLat) > float(Inner_Stops['BusStops'][1]['lat']) or float(BusLon) > float(Inner_Stops['BusStops'][1]['lon'])):
      return "Western_Drive_ETA"
    else:
      return "Arboretum_ETA"
  elif(StopName == "Arboretum_ETA"):           # if closest stop is Village Farm
    if(float(BusLat) > float(Inner_Stops['BusStops'][2]['lat'])):
      return "Arboretum_ETA"
    else:
      return "West_Remote_Interior_ETA"
      
  #***********************************************
  elif(StopName == "West_Remote_Interior_ETA"):           # if closest stop is West Remote Interior
     if(float(BusLat) > float(Inner_Stops['BusStops'][3]['lat'])):
       return "West_Remote_Interior_ETA"
     else:
       return "Oakes_RCC_ETA"
  #***********************************************
      
  elif(StopName == "Oakes_RCC_ETA"):            # if closest stop is Each Remote
    if(float(BusLat) > float(Inner_Stops['BusStops'][4]['lat'])):
      return "Oakes_RCC_ETA"
    else:
      return "Porter_RCC_ETA"
  elif(StopName == "Porter_RCC_ETA"):    # if closest stop is East Field House
    if(float(BusLat) > float(Inner_Stops['BusStops'][5]['lat'])):
      return "Porter_RCC_ETA"
    else:
      return "Kerr_Hall_ETA"
  elif(StopName == "Kerr_Hall_ETA"):              # if closest stop is Bookstore
    if(float(BusLat) > float(Inner_Stops['BusStops'][6]['lat'])):
      return "Kerr_Hall_ETA"
    else:
      return "Kresge_ETA"
  elif(StopName == "Kresge_ETA"):          # if closest stop is Crown/Merill
    if(float(BusLat) > float(Inner_Stops['BusStops'][7]['lat']) or float(BusLon) > float(Inner_Stops['BusStops'][7]['lon'])):
      return "Kresge_ETA"
    else:
      return "Science_Hill_ETA"
  elif(StopName == "Science_Hill_ETA"):           # if closest stop is College 9/10
    if(float(BusLon) < float(Inner_Stops['BusStops'][8]['lon'])):
      return "Science_Hill_ETA"
    else:
      return "Colleges9_10_ETA"
  elif(StopName == "Colleges9_10_ETA"):           # if closest stop is Science Hill
    if(float(BusLon) < float(Inner_Stops['BusStops'][9]['lon'])):
      return "Colleges9_10_ETA"
    else:
      return "Cowell_College_Bookstore_ETA"
  elif(StopName == "Cowell_College_Bookstore_ETA"):                 # if closest stop is Kresge
    if(float(BusLat) < float(Inner_Stops['BusStops'][10]['lat'])):
      return "Cowell_College_Bookstore_ETA"
    else:
      return "East_Remote_ETA"
  elif(StopName == "East_Remote_ETA"):             # if closest stop is Porter
    if(float(BusLat) < float(Inner_Stops['BusStops'][11]['lat'])):
      return "East_Remote_ETA"
    else:
      return "Village_Farm_ETA"
  elif(StopName == "Village_Farm_ETA"): # if closest stop is Family Student Housing
    if(float(BusLat) < float(Inner_Stops['BusStops'][12]['lat'])):
      return "Village_Farm_ETA"
    else:
      return "Lower_Campus_ETA"
  else:                                           # if IntervalStop = "Lower_Campus_ETA"
    if(float(BusLat) < float(Inner_Stops['BusStops'][13]['lat'])):
      return "Lower_Campus_ETA"
    else:
      return "Barn_Theater_ETA"


# ------------------------------------------------------------------------------------------------------
# PURPOSE: Function that returns a json object of buses (outer loop or inner loop)
# Input Parameters:
#     # Bus_Data: Bus Stop data containing their cooridnates
#     # findType: Index of the array to convert to it's bus name
# Returns: Name of the bus
# ------------------------------------------------------------------------------------------------------
def determineLoopDirection(BusData, BusDirData, findType):

  #Variables used to create a json object of inner/outer loops
  LoopData = {}
  LoopData['rows'] = []
  
  # For Loop that goes through bus Directions
  for busDir in BusDirData['rows']:
    
    # If it's the bus direction we're trying to loop for
    if(busDir['direc'] == findType):
      # Loops through real-time bus data
      for buses in BusData['rows']:
        if(buses['id'] == busDir['bus_id']):
          LoopData['rows'].append(buses)

  return LoopData
  
