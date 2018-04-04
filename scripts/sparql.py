from SPARQLWrapper import SPARQLWrapper, JSON
import sys
import json
from time import time

def main(argv):
    queryFileName=argv[1]
    endpoint=argv[2]
    sparql = SPARQLWrapper(endpoint)
    queryFile = open(queryFileName, "r") 
    query = queryFile.read() 
    sparql.setQuery(query)
    sparql.setReturnFormat(JSON)
    t=time()
    results = sparql.query().convert()

    n=0
    for result in results["results"]["bindings"]:
        n=n+1
    tt=(time()-t)*1000
    #print(result["label"]["value"])
    #print(json.loads(results.print_results()))
    #results.print_results()
    #print(json.dumps(results))
    print queryFileName+" "+str(tt)+" "+str(n)
if __name__ == '__main__':
    main(sys.argv)
