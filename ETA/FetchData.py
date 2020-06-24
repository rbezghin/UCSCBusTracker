
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
  response = requests.get(request, verify=False).json()

  # returns the ETA by parsing the JSON response and dividing by 60 (ETA returned by server is in seconds)
  return response
  
  
# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that gets the ETA from point A to point B using latitudes and longs
# Input Parameters:
#     StartLat/StartLong: Latitude and longitude of Point A
#     DestLat/DestLong: Latitude and longitude of point B
#     APIKeyNum: Determines which API key to use (this is to keep each API key at 100,000 requests per month)
# Returns: ETA from point A to point B in minutes
# ------------------------------------------------------------------------------------------------------
def getETA(StartLat, StartLong, DestLat, DestLong, APIKeyNum):

  # Variables used to concatinate with StartLong/Lat and DestLong/Lat to create final request to website
  website = "https://api.mapbox.com/directions/v5/mapbox/driving/"
  CoordinateSeperator = ","
  PointSeperator = ";"
  
  if (APIKeyNum == 0):
    accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b24xIiwiYSI6ImNrYXlmenhhODBia2kyeW8zODd0YzNueGUifQ.7xpt81iOo2xZdQG8XG7Q1g"
  elif (APIKeyNum == 1):
    accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b24yIiwiYSI6ImNrYXlnZzRtODAwMmcyd3FyaDExYzd5MTMifQ.zYO7_gJicVSfbU7PcSn6ew"
  elif (APIKeyNum == 2):
    accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b240IiwiYSI6ImNrYXluMWpxOTBsNXoycW5sZG5heWh4ZnYifQ.PWypXK67LrJCL_cvNtnTSQ"
  elif (APIKeyNum == 3):
    accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b241IiwiYSI6ImNrYXl0a3l5ODA0ZjgycXFybXRwbGtpMjYifQ.JZBWz0Da6kZeKKdP1RT6yw"
  else: #(APIKeyNum == 4)
    accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b243IiwiYSI6ImNrYXl0enIzcDBhYncyenNkazducWZhdGYifQ.Lzu-FfK-jvwhrCE_t2sALA"
  
  print("ETA Calculation API Key Used: " + str(APIKeyNum))
  # Concatinates the Above Strings with the input start/dest longs/lats
  finalRequest = website + str(StartLong) + CoordinateSeperator + str(StartLat) + PointSeperator + str(DestLong) + CoordinateSeperator + str(DestLat) + accessToken
    
  # Puts the GET response into variable then converts it to json formatting
  response = requests.get(finalRequest).json()
  
  # returns the ETA by parsing the JSON response and dividing by 60 (ETA returned by server is in seconds)
  return (response['routes'][0]['duration'])/60
  
  
# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that gets the ETA from point A to point B using latitudes and longs (mainly for bus stop interval times)
#          Uses a seperate API Key in order to stay within the limit of 100,000 Requests to API server pre month
# Input Parameters:
#     StartLat/StartLong: Latitude and longitude of Point A
#     DestLat/DestLong: Latitude and longitude of point B
# Returns: ETA from point A to point B in minutes
# ------------------------------------------------------------------------------------------------------
def getIntervals(StartLat, StartLong, DestLat, DestLong, APIKeyNum):

  # Variables used to concatinate with StartLong/Lat and DestLong/Lat to create final request to website
  website = "https://api.mapbox.com/directions/v5/mapbox/driving/"
  CoordinateSeperator = ","
  PointSeperator = ";"
  
  if(APIKeyNum == 0):
    accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b24zIiwiYSI6ImNrYXlna2Y5djBpdmgyc283bWF1Zm5oczIifQ.XrJlmlJswE75guaiRpNGgg"
  else:
     accessToken = "?access_token=pk.eyJ1IjoicmN0dWF6b242IiwiYSI6ImNrYXl0c3l6NDAyMmsyeW8xYXByaDJqd2sifQ.KfEY8pyVpdRM-2p_jeeg5g"
    
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
  return requests.get("https://ucsc-bts3.soe.ucsc.edu/direction.php", verify=False).json()


# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that gets the prev locations of buses
# Input Parameters: NONE
# Returns: json data containing the previous location of buses and the direction they're traveling
# ------------------------------------------------------------------------------------------------------
def postETAData(inner_ETA, outer_ETA, inner_null_data, outer_null_data):
  # Get request for bus direction data then returns result
  requests.post("https://ucsc-bts3.soe.ucsc.edu/update_innereta.php", json=inner_null_data, verify=False)
  requests.post("https://ucsc-bts3.soe.ucsc.edu/update_outereta.php", json=outer_null_data, verify=False)
  requests.post("https://ucsc-bts3.soe.ucsc.edu/update_innereta.php", json=inner_ETA, verify=False)
  requests.post("https://ucsc-bts3.soe.ucsc.edu/update_outereta.php", json=outer_ETA, verify=False)
