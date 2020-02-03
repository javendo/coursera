import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
	recordType = record[0]
	orderId = record[1]
	mr.emit_intermediate(orderId, record)

def reducer(key, list_of_values):
	result = sorted(list_of_values, key = lambda value: value[0], reverse=True)
	for line_item in result[1:] :
		resulting_line = []
		resulting_line.extend(result[0]) 
		resulting_line.extend(line_item) 	
		mr.emit(resulting_line)

inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)
