import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
	sq = record[0]
	nctd = record[1]
	mr.emit_intermediate(nctd[0:-10], record)

def reducer(nctd, list_of_record):
	mr.emit(nctd)

inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)
