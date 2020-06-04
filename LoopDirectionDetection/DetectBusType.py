
"""
File: DetectBusType.py
Author: Katelyn Young (Revised/Refactored by: Rizzian Tuazon)
Project: UCSC Bus Tracking System 3 (BTS3)
Description: Functions used to Determine what type of bus a bus is
"""

# Import Python Libraries
import json
import requests

# ------------------------------------------------------------------------------------------------------
# PURPOSE: function that determines the direction the bus is going (inner or outer loop)
# Input Parameters:
#     LiveBusData: Live Bus Data containing real-time location of buses
#     BusTypeData: Bus Type Data containing the previous type(inner or outer) and location of buses
# Returns: JSON object containing all active bus data
# ------------------------------------------------------------------------------------------------------
def DetermineBusType(LiveBusData, BusTypeData):
  
  # Initializes variable used to store new BusTypeData
  result = []
  
  # For Loop that loops through the prev Bus Data
  for prevBusLoc in BusTypeData:
    
    flag = 0
    
    # For Loop that loops through the live Bus Data
    for currBusLoc in LiveBusData:
    
      # Variables used to keep track of current coordinates of the bus
      curr_lat = float(currBusLoc["lat"])
      curr_lon = float(currBusLoc["lon"])
      
      # If statement that ONLY updates the direction of active buses
      if prevBusLoc["bus_id"] == currBusLoc["id"]:
        flag = flag + 1
        prev_lat = float(prevBusLoc["prev_lat"])
        prev_lon = float(prevBusLoc["prev_lon"])
        curr_dir = prevBusLoc["direc"]
        direc = ""
        
        # If a bus already has previously recorded coordinates, find it's direction
        if prevBusLoc['prev_lat'] != 0 and prevBusLoc['prev_lon'] != 0:
          direc = findDirection(curr_dir, curr_lat, curr_lon, prev_lat, prev_lon)
      
        # Updates what the prevoius lon/lat are (for next time direction is calculated)
        previous_lat = curr_lat
        previous_lon = curr_lon
        
        # Adds the bus calculated
        result.append({'bus_id': currBusLoc['id'], 'direc': direc, 'prev_lat': previous_lat, 'prev_lon': previous_lon})
      
      # If bus is flagged as inactive, add it to results anyway
    if flag == 0 and float(prevBusLoc['prev_lat']) != 0 and float(prevBusLoc['prev_lon'] != 0):
      result.append({'bus_id': prevBusLoc['bus_id'], 'direc': '', 'prev_lat': 0, 'prev_lon': 0})
  
  return result
  # Pushes the Data onto the server, ready to be PULLED
  #post_resp = requests.post("https://ucsc-bts3.soe.ucsc.edu/update_direction.php", json=result)
  #print(json.dumps(result, indent=2))

# ------------------------------------------------------------------------------------------------------
# PURPOSE: Helper Function for Determine Bus Type
# Input Parameters:
#     currLat/Lon: current coordinates of bus
#     prevLat/Lon: previous coordinates of bus
# Returns: JSON object containing all active bus data
# ------------------------------------------------------------------------------------------------------
def findDirection(curr_dir, curr_lat, curr_lon, prev_lat, prev_lon):
  
  # Initializes the value to be returned by the function
  direc = ""
  
  # UCSC: BOTTOM HALF
  if curr_lat <= 36.992444:
    # UCSC: BOTTOM HALF --> WEST
    if curr_lon < -122.055831:
      # temp = temp + "Location: Lower West Half\n"
      # temp = temp + "latitude decreasing --> outer      latitude increasing --> inner\n"
      if curr_lat < prev_lat:
        direc = "outer"
        return direc
      elif curr_lat > prev_lat:
        direc = "inner"
        return direc
      else:
        return curr_dir
    # UCSC: BOTTOM HALF --> EAST
    else:
      # temp = temp + "Location: Lower East Half\n"
      # temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
      if curr_lat < prev_lat:
        direc = "inner"
        return direc
      elif curr_lat > prev_lat:
        direc = "outer"
        return direc
      else:
        return curr_dir
  # UCSC: RCC/Porter area
  elif curr_lat >= 36.992444 and curr_lat < 36.993316 and curr_lon > -122.066566 and curr_lon < -122.063935:
    # temp = temp + "RCC/Porter area\n"
    # temp = temp + "longitude decreasing --> outer      longitude increasing --> inner\n"
    if curr_lon < prev_lon:
      direc = "outer"
      return direc
    elif curr_lon > prev_lon:
      direc = "inner"
      return direc
    else:
      return curr_dir
  # UCSC: RCC to Kresge
  elif curr_lat >= 36.993316 and curr_lat < 36.99992333 and curr_lon < -122.062860:
    # temp = temp + "Location: RCC to Kresge\n"
    # temp = temp + "latitude decreasing --> outer      latitude increasing --> inner\n"
    if curr_lat < prev_lat:
      direc = "outer"
      return direc
    elif curr_lat > prev_lat:
      direc = "inner"
      return direc
    else:
      return curr_dir
  # UCSC: Baskin to Crown
  elif curr_lat >= 36.999290 and curr_lon < -122.054543 and curr_lon >= -122.062860:
    # temp = temp + "Location: Baskin to Crown\n"
    # temp = temp + "longitude decreasing --> outer      longitude increasing --> inner\n"
    if curr_lon < prev_lon:
      direc = "outer"
      return direc
    elif curr_lon > prev_lon:
      direc = "inner"
      return direc
    else:
      return curr_dir
  # UCSC: Crown to East Remote
  elif curr_lat >= 36.992444 and curr_lat < 36.999290 and curr_lon >= -122.055831:
    # temp = temp + "Location: Crown to East Remote\n"
    # temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
    if curr_lat < prev_lat:
      direc = "inner"
      return direc
    elif curr_lat > prev_lat:
      direc = "outer"
      return direc
    else:
      return curr_dir
  # UCSC: Bay and High --> West
  elif curr_lat > 36.977219 and curr_lat < 36.9773833 and curr_lon > -122.053795:
    # temp = temp + "Location: Bay and High: West\n"
    # temp = temp + "longitude decreasing --> inner      longitude increasing --> outer\n"
    if curr_lat < prev_lat:
      direc = "inner"
      return direc
    elif curr_lat > prev_lat:
      direc = "outer"
      return direc
    else:
      return curr_dir
  # UCSC: Bay and High --> East
  elif curr_lat >= 36.977119 and curr_lat < 36.9773833 and curr_lon >= -122.053795:
    # temp = temp + "Location: Bay and High: East\n"
    # temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
    if curr_lat < prev_lat:
      direc = "inner"
      return direc
    elif curr_lat > prev_lat:
      direc = "outer"
      return direc
    else:
      return curr_dir
  else:
    print("ERROR")
    print("direction = " + direc + "\ncurrent lat = " + str(curr_lat) + "   previous lat = " + str(prev_lat))
    print("current lon = " + str(curr_lon) + "   previous lat = " + str(prev_lon) + "\n")
    return direc
