
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
# PURPOSE: function that gets the prev locations of buses
# Input Parameters: NONE
# Returns: json data containing the previous location of buses
# ------------------------------------------------------------------------------------------------------
def getBusType():
  # Get request for bus direction data then returns result
  return requests.get("https://ucsc-bts3.soe.ucsc.edu/direction.php").json()


# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that pushes/posts the new bus direction data to the server
# Input Parameters:
#         -Data: newly calculated bus direction data
# Returns: NOTHING
# ------------------------------------------------------------------------------------------------------
def postNewData(data):
  ret_status = requests.post("https://ucsc-bts3.soe.ucsc.edu/update_direction.php", json=data)
