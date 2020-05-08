
"""
File: BusTypeDetection.py
Author: Rizzian Tuazon
Project: UCSC Bus Tracking System 3 (BTS3)
Description: Main file for bus type detection
"""

# Import Python Libraries
import json
import requests

#from DetectBusType import getBusData
from FetchData import getBusData, getBusType, postNewData
from DetectBusType import DetermineBusType

print("\n ---------------------------- ")
print("|  Detecting Bus Directions  |")            # Progress alert
print(" ---------------------------- ")

# Gets the live Bus coordinates/data from the BTS3 Server
liveBusData = getBusData()

print("  =>  Getting Real-Time Bus Locations...")  # Progress alert

# Gets the Bus Direction Data from BTS3 Server
busDirData = getBusType()

print("  =>  Getting Bus Direcotion Data...")      # Progress alert

# Using previously calculated Data, Calculates the direction the bus is going (bus type: inner or outer loop)
newbusDirData = DetermineBusType(liveBusData['rows'], busDirData['rows'])

print("  =>  Calculating Bus Direction...")  # Progress alert

# POSTs the newly calculated bus direciotn data to the server
postNewData(newbusDirData)

print("  =>  Pushing Data To Server...")  # Progress alert

print(" ---------------------------- ")
print("|            DONE            |")            # Progress alert
print(" ----------------------------\n")








