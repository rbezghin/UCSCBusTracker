
"""
File: FetchData.py
Author: Rizzian Tuazon
Project: UCSC Bus Tracking System 3 (BTS3)
Description: Functions used to fetch data from TAPS/BTS3 & MapBox Servers
"""

# Import Python Libraries
import json
import requests

# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that gets the data of the buses currently running throughout campus
# Input Parameters: NONE
# Returns: JSON object containing all active bus data
# ------------------------------------------------------------------------------------------------------
def getBusData():

  # Variables used to concatinate with StartLong/Lat and DestLong/Lat to create final request to website
  request = "https://ucsc-bts3.soe.ucsc.edu/bus_table.php";
  
  # Puts the GET response into variable then converts it to json formatting
  response = requests.get(request).json()
  
  # returns the ETA by parsing the JSON response and dividing by 60 (ETA returned by server is in seconds)
  return response
  
  
# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that gets the ETA from point A to point B using latitudes and longs
# Input Parameters:
#     StartLat/StartLong: Latitude and longitude of Point A
#     DestLat/DestLong: Latitude and longitude of point B
# Returns: ETA from point A to point B in minutes
# ------------------------------------------------------------------------------------------------------
def getETA(StartLat, StartLong, DestLat, DestLong):

  # Variables used to concatinate with StartLong/Lat and DestLong/Lat to create final request to website
  website = "https://api.mapbox.com/directions/v5/mapbox/driving/"
  CoordinateSeperator = ","
  PointSeperator = ";"
  accessToken = "?access_token=pk.eyJ1IjoicnR1YXpvbiIsImEiOiJjazYyamFiZ3kwZHQwM2ttbWo0Mm5tdmhkIn0.Oom-AlR-Ko14OvhO2U3_fw"
  
  # Concatinates the Above Strings with the input start/dest longs/lats
  finalRequest = website + str(StartLong) + CoordinateSeperator + str(StartLat) + PointSeperator + str(DestLong) + CoordinateSeperator + str(DestLat) + accessToken
    
  # Puts the GET response into variable then converts it to json formatting
  response = requests.get(finalRequest).json()
  
  # returns the ETA by parsing the JSON response and dividing by 60 (ETA returned by server is in seconds)
  return (response['routes'][0]['duration'])/60


# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that gets the prev locations of buses
# Input Parameters: NONE
# Returns: json data containing the previous location of buses and the direction they're traveling
# ------------------------------------------------------------------------------------------------------
def getBusType():
  # Get request for bus direction data then returns result
  return requests.get("https://ucsc-bts3.soe.ucsc.edu/direction.php").json()
