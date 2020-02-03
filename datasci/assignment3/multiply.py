import MapReduce
import sys

mr = MapReduce.MapReduce()
mr2 = MapReduce.MapReduce()

def mapper(record):
    mr.emit_intermediate('a',record)

def reducer(pos, list_of_values):
	A = [[0,0,0,0,0] for i in range(5)]
	B = [[0,0,0,0,0] for i in range(5)]
	C = [[0,0,0,0,0] for i in range(5)]
	for record in list_of_values :
		matrix = record[0]
		row = record[1]
		col = record[2]	
		value = record[3]         	
		if matrix == 'a':
			A[row][col] = value	
		else:
			B[row][col] = value	
    
	result = 1
	for i in range(5):
		for j in range(5):
			for k in range(5):
				C[i][j] += A[i][k]*B[k][j]

	for x  in range(len(C)):
		for y in range(len(C[x])):
			mr.emit((x,y,C[x][y])) 

def mapper2(record):
	row = record[0]
	column = record[1]	
	value = record[2]    
	mr2.emit_intermediate((row,column),record)

def reducer2(pos, list_of_values):
	result = 0 
	for record in list_of_values :
		result += record[2] 
	mr2.emit((pos[0],pos[1],result)) 
   

inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)

