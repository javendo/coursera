import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
	dockey = record[0]
	value = record[1]
	words = value.split()
	for word in words:
		mr.emit_intermediate(word, dockey)

def reducer(key, list_of_values):
	result = list(set(list_of_values))
	mr.emit((key, result ))

inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)
