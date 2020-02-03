import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
	personA = record[0]
	mr.emit_intermediate(personA, 1)

def reducer(personA, list_of_friends):
	mr.emit((personA, len(list_of_friends)))

inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)
