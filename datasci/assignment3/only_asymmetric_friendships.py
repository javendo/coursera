import MapReduce
import sys

mr = MapReduce.MapReduce()

# Part 2
def mapper(record):
    # Person: Person
    # Friend: document contents

    person = record[0]
    friend = record[1]
    
    record.sort()
    
    # the key for a relation is 2 people if we order we will be able to find 
    # if it repeats, how many me and you relations exists	    
    keyPartA = record[0]
    keyPartB =  record[1]
 
    # sending the original order for in case one person knows another but not the inverse
    # identify the person  	
    mr.emit_intermediate((keyPartA,keyPartB), (person,friend))

# Part 3
def reducer(key, list_of_friends):
    if len(list_of_friends) < 2 :
       mr.emit((list_of_friends[0][0],list_of_friends[0][1]))
       mr.emit((list_of_friends[0][1],list_of_friends[0][0]))

# Part 4
inputdata = open(sys.argv[1])
mr.execute(inputdata, mapper, reducer)
