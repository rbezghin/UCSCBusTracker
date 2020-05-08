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

print("Starting...\n")


outer_stops = ["Main_Entrance_ETA",
			 "Lower_Campus_ETA",
			 "Village_Farm_ETA",
			 "East_Remote_ETA",
			 "East_Field_House_ETA",
			 "Bookstore_ETA",
			 "Crown_Merrill_ETA",
			 "Colleges9_10_ETA",
			 "Science_Hill_ETA",
			 "Kresge_ETA",
			 "Porter_RCC_ETA",
			 "Family_Student_Housing_ETA",
			 "Oakes_FSH_ETA",
			 "Arboretum_ETA",
			 "Western_Drive_ETA"]

inner_stops = ["Barn_Theater_ETA",
			   "Western_Drive_ETA",
			   "Arboretum_ETA",
			   "Oakes_RCC_ETA",
			   "Porter_RCC_ETA",
			   "Kerr_Hall_ETA",
			   "Kresge_ETA",
			   "Science_Hill_ETA",
			   "Colleges9_10_ETA",
			   "Cowell_College_Bookstore_ETA",
			   "East_Remote_ETA",
			   "Village_Farm_ETA",
			   "Lower_Campus_ETA"]

for o in outer_stops:
	result = {"bus_stop":o}
	post_resp = req.post("https://ucsc-bts3.soe.ucsc.edu/bus_stops/outer_eta2.php", data=result)
	print(post_resp.text)
	print()

print()
print()

for i in inner_stops:
	result = {"bus_stop":i}
	post_resp = req.post("https://ucsc-bts3.soe.ucsc.edu/bus_stops/inner_eta2.php", data=result)
	print(post_resp.text)
	print()


'''
format: {"rows":[{"bus_id":"72","bus_type":"LOOP","Main_Entrance_ETA":"10"},{"bus_id":"74","bus_type":"LOOP","Main_Entrance_ETA":"10"},{"bus_id":"78","bus_type":"LOOP OUT OF SERVICE AT THE BARN THEATER","Main_Entrance_ETA":"10"},{"bus_id":"81","bus_type":"UPPER CAMPUS","Main_Entrance_ETA":"10"}]}
'''
