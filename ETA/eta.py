# Python Library Imoprts
import requests
import json
import urllib2
import urllib
import httplib
import time

# User library/python file imports
from BusStopData import getStopsLocation
from FetchData import getETA, getBusData, getBusType, postETAData
from ETACalc import CalcStopIntervals, CalculateETAs, NullETAs
from BusStopDetermination import determineLoopDirection #, ApproachingBusStop # remove "ApproachingBusStop" after testing

CalculateStopIntervals = False

# ------------------------------------------------------------------------------------------------------
#                                    ETA Calculation Function
# ------------------------------------------------------------------------------------------------------
def CalculateBusETAs(OuterBusStops, InnerBusStops, OuterBusStopIntervals, InnerBusStopIntervals, APIKeyNum):
  Null_Buses = [75, 78, 79, 80, 84, 85, 90, 92, 93, 95, 96, 97, 98]

  print(" ------------------------")
  print("|    ETA Calculation     |")
  print(" ------------------------")


  print("  =>  Fetching Real-Time Bus Data...")

  # Gets the bus data (id, location, type) of all active buses from BTS3 server
  busData = getBusData()
  #busData = {"rows":[{"id":"98","lat":"36.99805833","lon":"-122.06395333","type":"LOOP","basestation":"BASKIN","time_stamp":"2020-02-14 11:50:53"}]}
  
  print(json.dumps(busData, indent=2))
  exit(1)
  
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

  # Calls function that returns bus ETA data
  print("  =>  Calculating Outer Loop ETAs...") # ************CHANGE outer_bus_data parameter from "busData" to outerBusData
  outer_bus_data = CalculateETAs(outerBusData, OuterBusStops, OuterBusStopIntervals, "OuterBusStops", APIKeyNum)
  print(json.dumps(outer_bus_data, indent=2))
  print("  =>  Calculating Inner Loop ETAs...")
  inner_bus_data = CalculateETAs(innerBusData, InnerBusStops, InnerBusStopIntervals, "InnerBusStops", APIKeyNum)
  
  null_inner_bus_data = NullETAs(Null_Buses, 'InnerBusStops')
  null_outer_bus_data = NullETAs(Null_Buses, 'OuterBusStops')
  

  print("  => Sending Data to Server...")

  # Posts to server
  postETAData(inner_bus_data, outer_bus_data, null_inner_bus_data, null_outer_bus_data)
  
  print(" ------------------------")
  print("|         Done           |")
  print(" ------------------------")


# ------------------------------------------------------------------------------------------------------
#                                        Main Function
# ------------------------------------------------------------------------------------------------------
def main():

  # Loops 2 times (1 ETA Interval Table Update every 30 minutes for 1 hour)
  for j in range(2):
    print(" ------------------------")
    print("|     Initializaton      |")
    print(" ------------------------")
    
    print("  =>  Fetching Bus Stop Coordinates...")
    
    # Creates a json object that contains all the bus stop locations and their names
    OuterBusStops = getStopsLocation("OuterBusStops")
    InnerBusStops = getStopsLocation("InnerBusStops")

    print("  =>  Calculating Bus Stop Intervals...")

    # Gets the ETA intervals between all outer and inner bus stops
    OuterBusStopIntervals = CalcStopIntervals(OuterBusStops, "OuterBusStops", j)
    InnerBusStopIntervals = CalcStopIntervals(InnerBusStops, "InnerBusStops", j)
    APIKeyNum = 0;  #when i = 20, switch to 1, when i = 40, switch to 2
    # Loops 60 times (1 ETA update every 30 seconds for 30 minutes)
    for i in range(60):
    
      CalculateBusETAs(OuterBusStops, InnerBusStops, OuterBusStopIntervals, InnerBusStopIntervals, i%5)
      
      print("\n**************************************")
      print("*     Creating 30 Second Delay...    *")
      print("**************************************\n")
      
      time.sleep(30)  # Puts the process to sleep (to avoid 'too many requests' return message)


# ------------------------------------------------------------------------------------------------------
#                                        Runs Main Function
# ------------------------------------------------------------------------------------------------------
# Runs Main
main()
