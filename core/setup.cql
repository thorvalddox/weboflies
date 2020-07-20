
MATCH (a) DETACH DELETE a;

UNWIND ['Hall','Lounge','Dining room','Ballroom'] AS i CREATE (room:Room {name: i});
UNWIND ['Alice','Bob','Charlie','Dave','Eve','Faith','Grace','Helen','Ivan','Judy',
'Mallory','Michael','Niaj','Olivia','Peggy'] AS i CREATE (person:Person {name: i, alive:true});
UNWIND ['0200','0300','0400','0500'] AS i CREATE (time:Time {clock: i});

//create eventgroup

MATCH (r:Room), (t:Time)
WITH r,t
CREATE (eg:EventGroup {type:0})
CREATE (eg) -[:clock]-> (t)
CREATE (eg) -[:location]-> (r);

//create friendships
/*
MATCH (p1:Person), (p2:Person)
WITH p1,p2
WHERE rand() < 0.2
CREATE (r:Relation {type: 'friend'})
CREATE (r) -[:ismember]-> (p1)
CREATE (r) -[:ismember]-> (p2);*/

//add special event

//thief
MATCH (eg:EventGroup {type:0})
WITH eg ORDER BY rand() LIMIT 1
SET eg.type = 2;
MATCH (eg:EventGroup {type:2})
WITH eg
MATCH (p1:Person)
WITH eg,p1 ORDER BY rand() LIMIT 1
MERGE (eg) -[:present]-> (p1);

//affair
MATCH (eg:EventGroup {type:0})
WITH eg ORDER BY rand() LIMIT 1
SET eg.type = 3;
MATCH (eg:EventGroup {type:3})
WITH eg
MATCH (p1:Person)
WITH eg,p1 ORDER BY rand() LIMIT 1
MATCH (p2:Person)
WITH eg,p1,p2 ORDER BY rand() LIMIT 1
MERGE (eg) -[:present]-> (p1)
MERGE (eg) -[:present]-> (p2);

//add murder
MATCH (eg:EventGroup {type:0})
WITH eg ORDER BY rand() LIMIT 1
SET eg.type = 1;
MATCH (eg:EventGroup {type:1})
WITH eg
MATCH (p1:Person)
WITH eg,p1 ORDER BY rand() LIMIT 1
MATCH (p2:Person)
WITH eg,p1,p2 ORDER BY rand() LIMIT 1
MERGE (eg) -[:present]-> (p1)
MERGE (eg) -[:present]-> (p2)
SET p2.alive=false;

//add regular events

MATCH (p:Person), (eg:EventGroup {type:0})
MERGE (eg) -[:maybe {c:rand()}]-> (p);

MATCH (p:Person) <-[m:maybe]-(eg:EventGroup {type:0}) --> (t:Time)

WITH p,t,max(m.c) as best
MERGE (p) <-[m:maybe {c:best}]- (t);

MATCH (t:Time) -[m:maybe]-> (p:Person) <-[m2:maybe]-(eg:EventGroup {type:0})
WHERE m.c = m2.c AND NOT (p) <-[:present]- (:EventGroup) --> (t:Time)
CREATE (eg) -[:present]-> (p);

MATCH (t:Time) -[m:maybe]-> (p:Person) <-[m2:maybe]-(eg:EventGroup {type:0})
  WHERE m.c = m2.c
CREATE (eg) -[:claims]-> (p);

MATCH ()<-[m:maybe]-() DELETE m;

//dna

MATCH (p:Person) <-- (:EventGroup) --> (r:Room)
WHERE rand()<0.75
MERGE (p) -[:dna]-> (r);

MATCH (p:Person) -[:dna]-> (r:Room)
return 'dna of ' + p.name + ' was found in the ' + r.name as dna;

MATCH (w:Person {alive:true}) <-[:claims]- (eg:EventGroup {type:0}) -[:present]-> (p:Person) , (r:Room) <-- (eg) --> (t:Time)
  WHERE rand()<0.25 AND w <> p
MERGE (m:Memory) -[:witness]-> (w)
MERGE (m) -[:spotted]-> (p)
MERGE (m) -[:clock]-> (t)
MERGE (m) -[:location]-> (r);

MATCH  (m:Memory) -[:witness]-> (w), (m) -[:spotted]-> (p), (m) -[:clock]-> (t), (m) -[:location]-> (r)
return w.name + ' saw ' + p.name  + ' at ' + t.clock + ' in the ' + r.name as witness_reports;





