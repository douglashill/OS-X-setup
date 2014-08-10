#! /usr/bin/python
# Encoding: utf-8

import json
import os
import re
import subprocess
import sys

class TypeMapping:
	def __init__(self, py_types, type_string, value_transformer):
		self.py_types = py_types
		self.type_string = type_string
		self.value_transformer = value_transformer

def map_type(value):
	# Unsupported property list types: data, date, array, array-add, dict, dict-add
	# bool must be checked before int because it is a subtype of int
	mappings = [
		TypeMapping([str, unicode], "string", lambda val: val),
		TypeMapping([bool],         "bool",   lambda val: "TRUE" if val else "FALSE"),
		TypeMapping([int, long],    "int",    lambda val: str(val)),
		TypeMapping([float],        "float",  lambda val: str(val)),
	]
	
	for mapping in mappings:
		for py_type in mapping.py_types:
			if isinstance(value, py_type):
				return mapping.type_string, mapping.value_transformer(value)
			
	return None, None

def write_defaults_item(domain, key, value):
	type, string_value = map_type(value)
	if type is None:
		print "Skipping unsupported pair: " + key + str(value)
		return False
	
	subprocess.call(["defaults", "write", domain, key, "-" + type, string_value])
	return True

def write_defaults(domain, patch_file):
	success_count = 0
	for key, value in json.load(patch_file).iteritems():
		if write_defaults_item(domain, key, value):
			success_count += 1
	print "Wrote " +  str(success_count) + " defaults for " + domain

def setup_defaults(data_directory):
	for file_name in os.listdir(data_directory):
		# Skip hidden files
		if file_name.startswith("."):
			continue
		
		# File name is expected to be the user defaults domain, with an optional .json extension.
		domain = re.sub("\.json$", "", file_name)
		
		with open(os.path.join(data_directory, file_name), "r") as opened_file:
			write_defaults(domain, opened_file)

if __name__ == '__main__':
	if len(sys.argv) < 2:
		sys.exit('Too few arguments. Usage: %s <data directory>' % sys.argv[0])
	
	setup_defaults(sys.argv[1])	
