
"""
File: ETACalc.py
Author: Rizzian Tuazon
Project: UCSC Bus Tracking System 3 (BTS3)
Description: Functions used to calculate various datas such as ETA to get around campus, ETA from a Bus
             to all bus stops, etc.
"""

# Import python libraries
import requests
import json

# User library/python file imports
from FetchData import getETA
from BusStopDetermination import ApproachingBusStop
from BusStopData import IndexToName, NameToIndex


# ------------------------------------------------------------------------------------------------------
# PURPOSE: Calculates every bus's ETAs to every bus stops
# Input Parameters:
#     Bus_Data: json object that contains bus data (location, id, type, etc.)
#     Outer_Stops: json object containing location of stops
#     BusStopIntervals: json object cantaining intervals between all adjacent bus stops
#     StopType: Type of bus stop (inner or outer)
# Returns: json object containing every buses' ETA to all bus stops
# ------------------------------------------------------------------------------------------------------
def CalculateETAs(Bus_Data, Outer_Stops, BusStopIntervals, StopType):
      
  # Defines variable/array used to store all ETA data
  ETAs = []         # Array used to strictly store ETAs
  BusETAData = []   # json Array usd to store all bus ETA data (bus ID, ETA to each stop, etc.)
  
  # Sets Max Stop Index based on the type of bus stops
  if(StopType == "OuterBusStops"):
    MaxStopIndex = 16 # Number of stops for Outer Loops
  else:
    MaxStopIndex = 14 # Number of stops for Inner Loops
  
  # Preallocates the space for exactly the number of stops for the Bus ETA Array
  PreallocETAIndeces = 0
  while (PreallocETAIndeces < MaxStopIndex):
    ETAs.append(0)
    PreallocETAIndeces += 1
  
  # For Loop that goes through all buses and calculates its ETAs to all bus stops
  for buses in Bus_Data['rows']:
    # Calculate which stop the bus is approaching
    StopBusIsApproaching = ApproachingBusStop(buses['lat'], buses['lon'], Outer_Stops, StopType)
    
    # Sets up variables used to calculate bus's ETA to every bus stop (for correct Bus Stop order for bus ETAs)
    BusStopETAsCalclated = 0                                      # Keeks track of the number of Bus Stop ETAs calculated
    FirstETACalculated = False                                    # Flag used to determine if it's the first ETA calculated or not
    CurrBusStop = NameToIndex(Outer_Stops, StopBusIsApproaching)  # Keeps track of which bus stop in the json array to calculate
    TotalETA = 0                                                  # Keeps track of the total time it takes to get from a bus to each bus stop
    
    # While Loop that calculates the ETA from a bus to all bus stops
    while BusStopETAsCalclated < MaxStopIndex:
    
      # Calculates ETA to all bus stops based on pre-calulated intervals betwen adjacent stops
      if (FirstETACalculated == False):
        #Calculates ETA then stores it in the apropriate index of the pre-allocated json object
        TotalETA = TotalETA + BusStopIntervals['Intervals'][CurrBusStop]['ETA']
        ETAs[CurrBusStop] = TotalETA
        
      # Calculates first ETA of bus to the bus stop it's approaching
      else:
        eta = getETA(fakeBusLocaitons['lat'], fakeBusLocaitons['lon'],
          Outer_Stops['BusStops'][CurrBusStop]['lat'], Outer_Stops['BusStops'][CurrBusStop]['lon'])
        ETAs[CurrBusStop] = eta
        FirstETACalculated = True
        TotalETA += eta
      
      # loop incrementations
      BusStopETAsCalclated += 1
      CurrBusStop += 1
      if (CurrBusStop == MaxStopIndex):
        CurrBusStop = 0
        
        
    # Once all ETAs from 1 bus to all bus stops are calculated, format it correctly
    if (StopType == "OuterBusStops"):
      BusETAData.append({'bus_id': buses['id'], 'bus_type': 'LOOP OUT OF SERVICE AT THE BARN THEATER', 'Main_Entrance_ETA': ETAs[0], 'Lower_Campus_ETA': ETAs[1], 'Village_Farm_ETA': ETAs[2], 'East_Remote_Interior_ETA': ETAs[3], 'East_Remote_ETA': ETAs[4], 'East_Field_House_ETA': ETAs[5], 'Bookstore_ETA': ETAs[6], 'Crown_Merrill_ETA': ETAs[7], 'Colleges9_10_ETA': ETAs[8], 'Science_Hill_ETA': ETAs[9], 'Kresge_ETA': ETAs[10], 'Porter_RCC_ETA': ETAs[11], 'Family_Student_Housing_ETA': ETAs[12], 'Oakes_FSH_ETA': ETAs[13], 'Arboretum_ETA': ETAs[14],'Western_Drive_ETA': ETAs[15]})
    
    else:
      BusETAData.append({'bus_id': buses['id'], 'bus_type': 'LOOP', 'Barn_Theater_ETA': ETAs[0], 'Western_Drive_ETA': ETAs[1], 'Arboretum_ETA': ETAs[2], 'West_Remote_Interior_ETA': ETAs[3], 'Oakes_RCC_ETA': ETAs[4], 'Porter_RCC_ETA': ETAs[5], 'Kerr_Hall_ETA': ETAs[6], 'Kresge_ETA': ETAs[7], 'Science_Hill_ETA': ETAs[8], 'Colleges9_10_ETA': ETAs[9], 'Cowell_College_Bookstore_ETA': ETAs[10], 'East_Remote_ETA': ETAs[11], 'Village_Farm_ETA': ETAs[12],'Lower_Campus_ETA': ETAs[13]})
  
  
  return BusETAData


# ------------------------------------------------------------------------------------------------------
# PURPOSE: Gives inactive buses NULL data
# Input Parameters:
#     Bus_Data: json object that contains bus data (location, id, type, etc.)
#     Outer_Stops: json object containing location of stops
#     BusStopIntervals: json object cantaining intervals between all adjacent bus stops
#     StopType: Type of bus stop (inner or outer)
# Returns: json object containing every buses' ETA to all bus stops
# ------------------------------------------------------------------------------------------------------
def NullETAs(Inactive_Buses, StopType):
      
  # Defines variable/array used to store all ETA data
  BusETAData = []   # json Array usd to store all bus ETA data (bus ID, ETA to each stop, etc.)
  
  for busIDs in Inactive_Buses:
    # Once all ETAs from 1 bus to all bus stops are calculated, format it correctly
    if (StopType == "OuterBusStops"):
      BusETAData.append({'bus_id': busIDs, 'bus_type': None, 'Main_Entrance_ETA': None, 'Lower_Campus_ETA': None, 'Village_Farm_ETA': None, 'East_Remote_Interior_ETA': None, 'East_Remote_ETA': None, 'East_Field_House_ETA': None, 'Bookstore_ETA': None, 'Crown_Merrill_ETA': None, 'Colleges9_10_ETA': None, 'Science_Hill_ETA': None, 'Kresge_ETA': None, 'Porter_RCC_ETA': None, 'Family_Student_Housing_ETA': None, 'Oakes_FSH_ETA': None, 'Arboretum_ETA': None,'Western_Drive_ETA': None})
    
    else:
      BusETAData.append({'bus_id': busIDs, 'bus_type': None, 'Barn_Theater_ETA': None, 'Western_Drive_ETA': None, 'Arboretum_ETA': None, 'West_Remote_Interior_ETA': None, 'Oakes_RCC_ETA': None, 'Porter_RCC_ETA': None, 'Kerr_Hall_ETA': None, 'Kresge_ETA': None, 'Science_Hill_ETA': None, 'Colleges9_10_ETA': None, 'Cowell_College_Bookstore_ETA': None, 'East_Remote_ETA': None, 'Village_Farm_ETA': None,'Lower_Campus_ETA': None})
  
  
  return BusETAData


# ------------------------------------------------------------------------------------------------------
# PURPOSE: Calculates ETAs of adjacent bus stops
#          For The purpose of having consistent ETAs for all ETAs
# Input Parameters:
#     Stops: Bus Stop locations that match with the StopType
#     StopType: If Bus is either Outer or Inner Loop
# Returns: ETA from point A to point B in minutes
# ------------------------------------------------------------------------------------------------------
def CalcStopIntervals(Stops, StopType):
  
  
  # variable to keep track of the ETAs between all bus stops
  BusStopIntervals = {}
  BusStopIntervals['Intervals'] = []
  TotalETA = 0
  
  # Checks whether to calculate inner or outer bus stop intervals
  if (StopType == "OuterBusStops"):   # Variable set up for Outer Bus Stops
    prevStop = "Western_Drive_ETA"      # Tracks name of the previous Bus stop (starts @ Western)
    prevLat = 36.978685                 # Tracks previous latitude (starts @ Western)
    prevLon = -122.057785               # Tracks previous longitude (starts @ Western)
  else:                               # Variable set up for Inner Bus Stops
    prevStop = "Lower_Campus_ETA"
    prevLat = 36.981474
    prevLon = -122.052015
  
  
  for stops in Stops['BusStops']:
  
    # Calculates the eta from the prevStop to Current Stop
    eta = getETA(prevLat, prevLon, stops['lat'], stops['lon']) +.75  # + 0.75 to account for loading times
    
    # Adds the new Data onto the interval JSON table
    BusStopIntervals['Intervals'].append({
        'Start': prevStop,
        'Destination': stops['Stop_Name'],
        'ETA': eta
    })
    
    # Updates the prevStop/Lat/Lon variables
    prevStop = stops['Stop_Name']
    prevLat = stops['lat']
    prevLon = stops['lon']
    TotalETA += (eta)
  
  # Returns the json object that contains the ETA invertals between each bus stop
  return BusStopIntervals

