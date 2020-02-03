import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
	person = record[0]
	friend = record[1]
	record.sort()
	keyPartA = record[0]
	keyPartB = record[1]
	mr.emit_intermediate((keyPartA,keyPartB), (person,friend))

def reducer(key, list_of_friends):
	if len(list_of_friends) < 2 :
		mr.emit((list_of_friends[0][0],list_of_friends[0][1]))
		mr.emit((list_of_friends[0][1],list_of_friends[0][0]))

inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)
