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
			 "West_Remote_Interior_ETA",
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
			   "East_Remote_Interior_ETA",
			   "Village_Farm_ETA",
			   "Lower_Campus_ETA"]

for o in outer_stops:
  result = {"bus_stop":o}
  post_resp = req.post("https://ucsc-bts3.soe.ucsc.edu/bus_stops/outer_eta2.php", data=result)
  print(post_resp.text)
  print()

#exit(1)
# print()
# print()
inner_etas = []
outer_etas = []

for i in range(len(inner_stops)):
	inner_etas.append(300+len(inner_stops)-i)

for o in range(len(outer_stops)):
	outer_etas.append(300+len(outer_stops)-o)

inner_result = []
#inner_result.append({'bus_id': 95, 'bus_type': 'LOOP', 'Barn_Theater_ETA': inner_etas[0], #'Western_Drive_ETA': inner_etas[1], 'Arboretum_ETA': inner_etas[2],
			#										   'Oakes_RCC_ETA': inner_etas[3], 'Porter_RCC_ETA': inner_etas[4], #'Kerr_Hall_ETA': inner_etas[5],
						#							   'Kresge_ETA': inner_etas[6], 'Science_Hill_ETA': inner_etas[7], #'Colleges9_10_ETA': inner_etas[8],
									#				   'Cowell_College_Bookstore_ETA': inner_etas[9], 'East_Remote_ETA': #inner_etas[10],'East_Remote_Interior_ETA': inner_etas[11],
												#	   'Village_Farm_ETA': inner_etas[12],'Lower_Campus_ETA': inner_etas[13]})
                
inner_result.append({'bus_id': 95, 'bus_type': None, 'Barn_Theater_ETA': None, 'Western_Drive_ETA': None, 'Arboretum_ETA': None, 'Oakes_RCC_ETA': None, 'Porter_RCC_ETA': None, 'Kerr_Hall_ETA': None, 'Kresge_ETA': None, 'Science_Hill_ETA': None, 'Colleges9_10_ETA': None, 'Cowell_College_Bookstore_ETA': None, 'East_Remote_ETA': None,'East_Remote_Interior_ETA': None, 'Village_Farm_ETA': None,'Lower_Campus_ETA': None})
                
print(json.dumps(inner_result, indent=2))


outer_result = []
"""
outer_result.append({'bus_id': 95, 'bus_type': 'LOOP OUT OF SERVICE AT THE BARN THEATER', 'Main_Entrance_ETA': outer_etas[0], 'Lower_Campus_ETA': outer_etas[1], 'Village_Farm_ETA': outer_etas[2],
													   'East_Remote_ETA': outer_etas[3], 'East_Field_House_ETA': outer_etas[4], 'Bookstore_ETA': outer_etas[5], 
													   'Crown_Merrill_ETA': outer_etas[6], 'Colleges9_10_ETA': outer_etas[7], 'Science_Hill_ETA': outer_etas[8], 
													   'Kresge_ETA': outer_etas[9], 'Porter_RCC_ETA': outer_etas[10], 'Family_Student_Housing_ETA': outer_etas[11], 
													   'Oakes_FSH_ETA': outer_etas[12],'West_Remote_Interior_ETA': outer_etas[13],
													   'Arboretum_ETA': outer_etas[14],'Western_Drive_ETA': outer_etas[15]})
"""
outer_result.append({'bus_id': 95, 'bus_type': None, 'Main_Entrance_ETA': None, 'Lower_Campus_ETA': None, 'Village_Farm_ETA': None, 'East_Remote_ETA': None, 'East_Field_House_ETA': None, 'Bookstore_ETA': None, 'Crown_Merrill_ETA': None, 'Colleges9_10_ETA': None, 'Science_Hill_ETA': None, 'Kresge_ETA': None, 'Porter_RCC_ETA': None, 'Family_Student_Housing_ETA': None, 'Oakes_FSH_ETA': None,'West_Remote_Interior_ETA': None, 'Arboretum_ETA': None,'Western_Drive_ETA': None})
print(json.dumps(outer_result, indent=2))


# POST request to "update_direction.php"
i_post_resp = req.post("https://ucsc-bts3.soe.ucsc.edu/update_innereta.php", json=inner_result)
#print(i_post_resp.text)

o_post_resp = req.post("https://ucsc-bts3.soe.ucsc.edu/update_outereta.php", json=outer_result)
#print(o_post_resp.text)

