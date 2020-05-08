#!/usr/bin/python3

"""
File: det_direc.py
Author: Katelyn Young
Project: UCSC Bus Tracking System 3 (BTS3)
Date Created: 2/6/2020
Date Updated: 2/7/2020
Description: Calculates the direction of the actively running buses 
			 based on the previous and current GPS coordinates and 
		     updates the "direction" MySQL table in the ucsc_bts3 database.
"""

import json
import urllib.request
import requests as req
import time
import datetime

def main():
	print("Starting...\n")

	# gets the real-time bus location data
	real_time_url = "https://ucsc-bts3.soe.ucsc.edu/bus_table.php"
	# real_time_url = "https://ucsc-bts3.soe.ucsc.edu/mock_data.txt"
	rt_response = urllib.request.urlopen(real_time_url)
	rt_data = rt_response.read()

	rt_encoding = rt_response.info().get_content_charset('utf-8')
	rt_json_data = json.loads(rt_data.decode(rt_encoding))
	rt_json_data = rt_json_data['rows']


	# gets the direction data
	direc_url = "https://ucsc-bts3.soe.ucsc.edu/direction.php"
	direc_resp = urllib.request.urlopen(direc_url)
	direc_data = direc_resp.read()

	direc_encoding = direc_resp.info().get_content_charset('utf-8')
	direc_json_data = json.loads(direc_data.decode(direc_encoding))
	direc_json_data = direc_json_data['rows']


	# data_file = open("data_log.txt", "a")

	# temp = "*********************************\nTime Stamp: " + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S') + "\n"
	# temp = temp + "---------------------------\nReal-Time Data\n"
	# for i in rt_json_data:
	# 	temp = temp + "id = " + i["id"] + ", lat = " + str(i["lat"]) + ", lon = " + str(i["lon"]) + ", type = " + i["type"] + "\n"

	# temp = temp + "\n---------------------------\nDirection Data\n"
	# for d in direc_json_data:
	# 	for r in rt_json_data:
	# 		if r["id"] == d["bus_id"]:
	# 			temp = temp + "bus_id = " + d["bus_id"] + ", direc = " + d["direc"] + ", prev_lat = " + str(d["prev_lat"]) + ", prev_lon = " + str(d["prev_lon"]) + "\n"
	# temp = temp + "\n--------------------------\n"
	# data_file.write(temp)

	result = []

	# checks every tracked bus
	for d in direc_json_data:

		# boolean flag for checking if a bus is active: 1 if active, 0 if inactive
		active = 0

		# checks every ACTIVE bus
		for r in rt_json_data:
			curr_lat = float(r["lat"])						# gets the current latitude
			curr_lon = float(r["lon"])						# gets the current longitude
			
			# if the active bus is in the direction table
			if r["id"] == d["bus_id"]:
				active = active + 1								# set the active active
				prev_lat = float(d["prev_lat"])					# gets the previous latitude
				prev_lon = float(d["prev_lon"])					# gest the previous longitude
				direc = ""

				# if the bus was active previously
				if prev_lat != 0 and prev_lon != 0:
					# temp = "bus_id = " + r["id"] + "\n"

					# UCSC: BOTTOM HALF
					if curr_lat <= 36.992444:
						# UCSC: BOTTOM HALF --> WEST
						if curr_lon < -122.055831:
							# temp = temp + "Location: Lower West Half\n"
							# temp = temp + "latitude decreasing --> outer      latitude increasing --> inner\n"
							if curr_lat < prev_lat:
								direc = "outer"
							elif curr_lat > prev_lat:
								direc = "inner"
							else:
								direc = d["direc"]
						# UCSC: BOTTOM HALF --> EAST
						else:
							# temp = temp + "Location: Lower East Half\n"
							# temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
							if curr_lat < prev_lat:
								direc = "inner"
							elif curr_lat > prev_lat:
								direc = "outer"
							else:
								direc = d["direc"]
					# UCSC: RCC/Porter area
					elif curr_lat >= 36.992444 and curr_lat < 36.993316 and curr_lon > -122.066566 and curr_lon < -122.063935:
						# temp = temp + "RCC/Porter area\n"
						# temp = temp + "longitude decreasing --> outer      longitude increasing --> inner\n"
						if curr_lon < prev_lon:
							direc = "outer"
						elif curr_lon > prev_lon:
							direc = "inner"
						else:
							direc = d["direc"]		# same direction
					# UCSC: RCC to Kresge
					elif curr_lat >= 36.993316 and curr_lat < 36.99992333 and curr_lon < -122.062860:
						# temp = temp + "Location: RCC to Kresge\n"
						# temp = temp + "latitude decreasing --> outer      latitude increasing --> inner\n"
						if curr_lat < prev_lat:
							direc = "outer"
						elif curr_lat > prev_lat:
							direc = "inner"
						else:
							direc = d["direc"]		# same direction
					# UCSC: Baskin to Crown
					elif curr_lat >= 36.999290 and curr_lon < -122.054543 and curr_lon >= -122.062860:
						# temp = temp + "Location: Baskin to Crown\n"
						# temp = temp + "longitude decreasing --> outer      longitude increasing --> inner\n"
						if curr_lon < prev_lon:
							direc = "outer"
						elif curr_lon > prev_lon:
							direc = "inner"
						else:
							direc = d["direc"]		# same direction
					# UCSC: Crown to East Remote
					elif curr_lat >= 36.992444 and curr_lat < 36.999290 and curr_lon >= -122.055831:
						# temp = temp + "Location: Crown to East Remote\n"
						# temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
						if curr_lat < prev_lat:
							direc = "inner"
						elif curr_lat > prev_lat:
							direc = "outer"
						else:
							direc = d["direc"]		# same direction
					# UCSC: Bay and High --> West
					elif curr_lat > 36.977219 and curr_lat < 36.9773833 and curr_lon > -122.053795:
						# temp = temp + "Location: Bay and High: West\n"
						# temp = temp + "longitude decreasing --> inner      longitude increasing --> outer\n"
						if curr_lat < prev_lat:
							direc = "inner"
						elif curr_lat > prev_lat:
							direc = "outer"
						else:
							direc = d["direc"]		# same direction
					# UCSC: Bay and High --> East
					elif curr_lat >= 36.977119 and curr_lat < 36.9773833 and curr_lon >= -122.053795:
						# temp = temp + "Location: Bay and High: East\n"
						# temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
						if curr_lat < prev_lat:
							direc = "inner"
						elif curr_lat > prev_lat:
							direc = "outer"
						else:
							direc = d["direc"]		# same direction
					else:
						print("ERROR")
						print("direction = " + direc + "\ncurrent lat = " + str(curr_lat) + "   previous lat = " + str(prev_lat))
						print("current lon = " + str(curr_lon) + "   previous lat = " + str(prev_lon) + "\n")
				
				# save current latitude and longitude
				previous_lat = curr_lat
				previous_lon = curr_lon

				# temp = temp + "direction = " + direc + "\ncurrent lat = " + str(curr_lat) + "   previous lat = " + str(prev_lat)
				# temp = temp + "\ncurrent lon = " + str(curr_lon) + "   previous lat = " + str(prev_lon) + "\n\n"

				# data_file.write(temp)

				# save result
				result.append({'bus_id': r['id'], 'direc': direc, 'prev_lat': previous_lat, 'prev_lon': previous_lon})
		# if bus becomes inactive --> clear out the MySQL row pertaining to that bus id
		if active == 0 and float(d['prev_lat']) != 0 and float(d['prev_lon'] != 0) :
			result.append({'bus_id': d['bus_id'], 'direc': '', 'prev_lat': 0, 'prev_lon': 0})

	# POST request to "update_direction.php"
	post_resp = req.post("https://ucsc-bts3.soe.ucsc.edu/update_direction.php", json=result)
	# print(post_resp.text)