import json
import urllib2
import urllib
import httplib
import requests

def main():
  print("Starting...\n")
  rt_resp = urllib2.urlopen('https://ucsc-bts3.soe.ucsc.edu/bus_table.php')
  #rt_resp = urllib2.urlopen('https://ucsc-bts3.soe.ucsc.edu/mock_data.txt')
  rt_json_data = json.load(rt_resp)
  rt_json_data = rt_json_data['rows']
  
  #print(json.dumps(rt_json_data,indent=2))
  #rt_json_data = [{"id":"78","lat":"36.99942333","lon":"-122.06424","type":"LOOP OUT OF SERVICE AT BARN THEATER","basestation":"BASKIN","time_stamp":"2020-02-07 16:19:06"}]

  direc_resp = urllib2.urlopen('https://ucsc-bts3.soe.ucsc.edu/direction.php')
  direc_json_data = json.load(direc_resp)
  direc_json_data = direc_json_data['rows']

  result = []
  for d in direc_json_data:
    flag = 0
    print(json.dumps(d, indent=2))
    for r in rt_json_data:
      curr_lat = float(r["lat"])
      curr_lon = float(r["lon"])
      if r["id"] == d["bus_id"]:
        flag = flag + 1
      prev_lat = float(d["prev_lat"])
      prev_lon = float(d["prev_lon"])
      direc = ""
      if prev_lat != 0 and prev_lon != 0:
        # temp = "bus_id = " + r["id"] + "\n"
        if curr_lat <= 36.992444:
          if curr_lon < -122.055831:
            # temp = temp + "Location: Lower West Half\n"
            # temp = temp + "latitude decreasing --> outer      latitude increasing --> inner\n"
            if curr_lat < prev_lat:
                    direc = "outer"
            elif curr_lat > prev_lat:
                    direc = "inner"
            else:
                    direc = d["direc"]
          else:
            # temp = temp + "Location: Lower East Half\n"
            # temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
            if curr_lat < prev_lat:
                    direc = "inner"
            elif curr_lat > prev_lat:
                    direc = "outer"
            else:
                    direc = d["direc"]
        elif curr_lat >= 36.992444 and curr_lat < 36.993316 and curr_lon > -122.066566 and curr_lon < -122.063935:
          # temp = temp + "RCC area\n"
          # temp = temp + "longitude decreasing --> outer      longitude increasing --> inner\n"
          if curr_lon < prev_lon:
                  direc = "outer"
          elif curr_lon > prev_lon:
                  direc = "inner"
          else:
                  direc = d["direc"]
        elif curr_lat >= 36.993316 and curr_lat < 36.99992333 and curr_lon < -122.062860:
          # temp = temp + "Location: RCC to Kresge\n"
          # temp = temp + "latitude decreasing --> outer      latitude increasing --> inner\n"
          if curr_lat < prev_lat:
                  direc = "outer"
          elif curr_lat > prev_lat:
                  direc = "inner"
          else:
                  direc = d["direc"]
        elif curr_lat >= 36.999290 and curr_lon < -122.054543 and curr_lon >= -122.062860:
          # temp = temp + "Location: Baskin to Crown\n"
          # temp = temp + "longitude decreasing --> outer      longitude increasing --> inner\n"
          if curr_lon < prev_lon:
                  direc = "outer"
          elif curr_lon > prev_lon:
                  direc = "inner"
          else:
                  direc = d["direc"]
        elif curr_lat >= 36.992444 and curr_lat < 36.999290 and curr_lon >= -122.055831:
          # temp = temp + "Location: Crown to East Remote\n"
          # temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
          if curr_lat < prev_lat:
                  direc = "inner"
          elif curr_lat > prev_lat:
                  direc = "outer"
          else:
                  direc = d["direc"]
        elif curr_lat > 36.977219 and curr_lat < 36.9773833 and curr_lon > -122.053795:
          # temp = temp + "Location: Bay and High: West\n"
          # temp = temp + "longitude decreasing --> inner      longitude increasing --> outer\n"
          if curr_lat < prev_lat:
                  direc = "inner"
          elif curr_lat > prev_lat:
                  direc = "outer"
          else:
                  direc = d["direc"]
        elif curr_lat >= 36.977119 and curr_lat < 36.9773833 and curr_lon >= -122.053795:
          # temp = temp + "Location: Bay and High: East\n"
          # temp = temp + "latitude decreasing --> inner      latitude increasing --> outer\n"
          if curr_lat < prev_lat:                                                 # print("inner")
                  direc = "inner"
          elif curr_lat > prev_lat:
                  direc = "outer"
          else:
                  direc = d["direc"]
        else:
          print("ERROR")
          print("direction = " + direc + "\ncurrent lat = " + str(curr_lat) + "   previous lat = " + str(prev_lat))
          print("current lon = " + str(curr_lon) + "   previous lat = " + str(prev_lon) + "\n")
      previous_lat = curr_lat
      previous_lon = curr_lon

      # temp = temp + "direction = " + direc + "\ncurrent lat = " + str(curr_lat) + "   previous lat = " + str(prev_lat)
      # temp = temp + "\ncurrent lon = " + str(curr_lon) + "   previous lat = " + str(prev_lon) + "\n\n"

      # data_file.write(temp)

      result.append({'bus_id': r['id'], 'direc': direc, 'prev_lat': previous_lat, 'prev_lon': previous_lon})
    if flag == 0 and float(d['prev_lat']) != 0 and float(d['prev_lon'] != 0) :
      result.append({'bus_id': d['bus_id'], 'direc': '', 'prev_lat': 0, 'prev_lon': 0})
    
    #print(json.dumps(result,indent=2))
    post_resp = requests.post("https://ucsc-bts3.soe.ucsc.edu/update_direction.php", json=result)
    #output = {'temp': result}
    #params = urllib.urlencode(output)
    #connection = httplib.HTTPSConnection('ucsc-bts3.soe.ucsc.edu')
    #headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
    #connection.request("POST", "/update_direction.php", params, headers)
  #print(json.dumps(result,indent=2))

main()
