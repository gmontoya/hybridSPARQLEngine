#!/bin/bash

java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/TP 48 /home/roott/simpleQueryGenerator/queries 0 100 query_TP_0_100_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/TP 48 /home/roott/simpleQueryGenerator/queries 100 1000 query_TP_100_1000_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/TP 48 /home/roott/simpleQueryGenerator/queries 1000 10000 query_TP_1000_10000_

java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/2STAR 48 /home/roott/simpleQueryGenerator/queries 0 100 query_2STAR_0_100_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/2STAR 48 /home/roott/simpleQueryGenerator/queries 100 1000 query_2STAR_100_1000_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/2STAR 48 /home/roott/simpleQueryGenerator/queries 1000 10000 query_2STAR_1000_10000_

java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/4STAR 48 /home/roott/simpleQueryGenerator/queries 0 100 query_4STAR_0_100_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/4STAR 48 /home/roott/simpleQueryGenerator/queries 100 1000 query_4STAR_100_1000_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/4STAR 48 /home/roott/simpleQueryGenerator/queries 1000 10000 query_4STAR_1000_10000_

java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/2PATH 48 /home/roott/simpleQueryGenerator/queries 0 100 query_2PATH_0_100_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/2PATH 48 /home/roott/simpleQueryGenerator/queries 100 1000 query_2PATH_100_1000_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/2PATH 48 /home/roott/simpleQueryGenerator/queries 1000 10000 query_2PATH_1000_10000_

java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/4PATH 48 /home/roott/simpleQueryGenerator/queries 0 100 query_4PATH_0_100_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/4PATH 48 /home/roott/simpleQueryGenerator/queries 100 1000 query_4PATH_100_1000_
java -cp .:/home/roott/apache-jena-2.13.0/lib/* generateQueries http://172.19.2.100:8893/sparql /home/roott/simpleQueryGenerator/templates/4PATH 48 /home/roott/simpleQueryGenerator/queries 1000 10000 query_4PATH_1000_10000_

