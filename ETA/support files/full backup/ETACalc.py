
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
    
  # Defines variable used to store all ETA data and return
  BusETAs = {}
  BusETA = []   # array used to store the ETAS of the bus
  
  
  # Sets Max Stop Index based on the type of bus stops
  if(StopType == "OuterBusStops"):
    MaxStopIndex = 15 # Number of stops for Outer Loops
  else:
    MaxStopIndex = 13 # Number of stops for Inner Loops
  
  
  # Preallocates the space for exactly the number of stops for the Bus ETA Array
  PreallocETAIndeces = 0
  while (PreallocETAIndeces < MaxStopIndex):
    BusETA.append(0)
    PreallocETAIndeces += 1
  
  # For loop that gets the ETAs of all buses
  for buses in Bus_Data['rows']:
    # Calculate which stop the bus is approaching
    StopBusIsApproaching = ApproachingBusStop(buses['lat'], buses['lon'], Outer_Stops, StopType)
    
    # Sets up json object variables that keeps track of the buses and their ETAs
    BusETAs[str(buses['id'])] = []                     # Defines what goes into BusETA json object
    PreallocatedIndeces = 0
    
    # Preallocates space for the ETA data table
    asdf = PreallocateETADataSpace(MaxStopIndex)
    print(json.dumps(asdf, indent=2))
    
    exit(1)

    # While Loop that allocates 15 indeces to the json object
    while (PreallocatedIndeces < MaxStopIndex):
      BusETAs[str(buses['id'])].append({'StopName': IndexToName(Outer_Stops, PreallocatedIndeces),'ETAToStop': 0})
      PreallocatedIndeces += 1
    
    
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
        #BusETAs[str(buses['id'])][CurrBusStop]['ETAToStop'] = TotalETA
        BusETA[CurrBusStop] = TotalETA
        
      # Calculates first ETA of bus to the bus stop it's approaching
      else:
        eta = getETA(fakeBusLocaitons['lat'], fakeBusLocaitons['lon'],
          Outer_Stops['BusStops'][CurrBusStop]['lat'], Outer_Stops['BusStops'][CurrBusStop]['lon'])
        #BusETAs[str(fakeBusLocaitons['id'])][CurrBusStop]['ETAToStop'] = eta
        BusETA[CurrBusStop] = eta
        FirstETACalculated = True
        TotalETA += eta
      
      # loop incrementations
      BusStopETAsCalclated += 1
      CurrBusStop += 1
      if (CurrBusStop == MaxStopIndex):
        CurrBusStop = 0
  
  
  
  
  print(BusETA)
  return BusETAs


def PreallocateETADataSpace(size):
  
  BusETAs = []
  
  curr_size = 0
  while(curr_size < size):
    BusETAs.append({'bus_id': 0, 'bus_type': 'LOOP', 'Barn_Theater_ETA': 0, 'Western_Drive_ETA': 0,
      'Arboretum_ETA': 0,'Oakes_RCC_ETA': 0, 'Porter_RCC_ETA': 0, 'Kerr_Hall_ETA': 0,
      'Kresge_ETA': 0, 'Science_Hill_ETA': 0, 'Colleges9_10_ETA': 0,
      'Cowell_College_Bookstore_ETA': 0, 'East_Remote_ETA': 0,'East_Remote_Interior_ETA': 0,
      'Village_Farm_ETA': 0,'Lower_Campus_ETA': 0})
      
    curr_size += 1
    
  return BusETAs



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

