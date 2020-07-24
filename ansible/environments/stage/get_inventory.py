#!/bin/python

import requests
import json
import subprocess
import sys

# env variable
env_template = "stage"
folder_template = "infra"

# Get token - yc iam create-token
p = subprocess.Popen('yc iam create-token', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
iam_token = str(p.stdout.readline().rstrip())
# create header
headers = {'Authorization': 'Bearer ' + iam_token,'Content-Type': 'application/json'}

# get cloud id
url = 'https://resource-manager.api.cloud.yandex.net/resource-manager/v1/clouds'
response = requests.get(url, headers=headers)
result = response.json()
cloud_id = 0
if result:
    for cloud in result["clouds"]:
	cloud_id = cloud["id"]
#print(cloud_id)

# get folder id
url = 'https://resource-manager.api.cloud.yandex.net/resource-manager/v1/folders?cloudId='+str(cloud_id)
response = requests.get(url, headers=headers)
result = response.json()
folder_id = 0
if result:
    for folder in result["folders"]:
	if folder_template in folder["name"]:
	    folder_id = folder["id"]
#print(folder_id)

# get inventory
url = 'https://compute.api.cloud.yandex.net/compute/v1/instances?folderId='+str(folder_id)
response = requests.get(url, headers=headers)
result = response.json()
#print(json.dumps(result, indent=4) )
inventory = {"_meta": {"hostvars": {}},}
if result:
    # get hosts with external ip, no any checks
    for instance in result["instances"]:
	# check host match by filter
	if env_template in instance["name"]:
	    # get app
	    if "app" in instance["name"]:
		host = {"app":{"hosts": [instance["networkInterfaces"][0]["primaryV4Address"]["oneToOneNat"]["address"]]}}
		i_host = {"vars":{"internal_ip":instance["networkInterfaces"][0]["primaryV4Address"]["address"]}}
		inventory.update(host)
		inventory["app"].update(i_host)
	    # get db
	    if "db" in instance["name"]:
		host = {"db":{"hosts": [instance["networkInterfaces"][0]["primaryV4Address"]["oneToOneNat"]["address"]]}}
		i_host = {"vars":{"internal_ip":instance["networkInterfaces"][0]["primaryV4Address"]["address"]}}
		inventory.update(host)
		inventory["db"].update(i_host)

if len (sys.argv) > 1:
    input_var = sys.argv[1]
    # print list result
    if "list" in input_var:
	print(json.dumps(inventory, indent=3))
    #if "host" in input_var:
	#host_name = sys.argv[2]
	#host_res = {inventory[host_name]}
	#print(inventory[host_name])
	#print(json.dumps(inventory, indent=3))
