-- Looking for a murder that occurd sometime on January 15, 2018, 2018-01-15. I am working with the following tables: 
-- crime_scene_report
-- drivers_license
-- facebook_event_checkin
-- interview
-- get_fit_now_member
-- get_fit_now_check_in
-- solution
-- income
-- person
-------------------------------------------
SELECT sql 
  FROM sqlite_master
 where name = 'crime_scene_report'

 CREATE TABLE crime_scene_report ( date integer, type text, description text, city text )


--------------------------------------------------
SELECT sql 
  FROM sqlite_master
 where name = 'drivers_license'

 CREATE TABLE drivers_license ( id integer PRIMARY KEY, age integer, height integer, eye_color text, hair_color text, gender text, plate_number text, car_make text, car_model text )

 --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'facebook_event_checkin'

CREATE TABLE facebook_event_checkin ( person_id integer, event_id integer, event_name text, date integer, FOREIGN KEY (person_id) REFERENCES person(id) )


 --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'interview'

CREATE TABLE interview ( person_id integer, transcript text, FOREIGN KEY (person_id) REFERENCES person(id) )


 --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'get_fit_now_member'

CREATE TABLE get_fit_now_member ( id text PRIMARY KEY, person_id integer, name text, membership_start_date integer, membership_status text, FOREIGN KEY (person_id) REFERENCES person(id) )


 --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'get_fit_now_check_in'

CREATE TABLE get_fit_now_check_in ( membership_id text, check_in_date integer, check_in_time integer, check_out_time integer, FOREIGN KEY (membership_id) REFERENCES get_fit_now_member(id) )


 --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'solution'

 CREATE TABLE solution ( user integer, value text )

  --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'income'

CREATE TABLE income (ssn CHAR PRIMARY KEY, annual_income integer)



 --------------------------------------------------
 SELECT sql 
  FROM sqlite_master
 where name = 'person
'

CREATE TABLE person (id integer PRIMARY KEY, name text, license_id integer, address_number integer, address_street_name text, ssn CHAR REFERENCES income (ssn), FOREIGN KEY (license_id) REFERENCES drivers_license (id))
--------------------------------------------------

-- so now I will look at the crime_scene_report table to see if I can find any information about which crimes were a murder from the given date

--first I run the following to see the structure of the date column
SELECT * FROM crime_scene_report

--Now I want to filter out only the crime scene reports for a murder on 20180115 (January 15, 2018). Given I do not want to look through the entire database to see if it has different types of murders listed I will use the wildcard % before and after murder in the query to ensure, it returns any crime with the word murder in it.

SELECT * 
FROM crime_scene_report 
WHERE date = 20180115
AND type LIKE '%murder%'
AND city = 'SQL City';

--Important datat from the above queery about the crime
-- date: January 15, 2018
--type: murder
--description: Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".
    --Keys
        --2 witnesses
            --#1: lives @ LAST house on NORTHWESTERN DR
            --#2: NAME = ANNABEL, lives on FRANKLIN AVE
--city: SQL City

--Now that I have  this information, I want to see if there are any interviews from either of these witnesses. I am going to want to use some wildcards and also use a left join, Individuals with a transcript and on the appropriate streets. 

-- SELECT p.id, p.name, p.address_number, p.address_street_name, i.transcript
-- FROM person as p
-- JOIN interview as i 
-- ON p.id = i.person_id
-- WHERE (address_street_name LIKE '%Northwestern%' OR address_street_name LIKE '%Franklin%')
-- AND (transcript IS NOT NULL AND TRIM(transcript) != '');

SELECT p.id, p.name, p.address_number, p.address_street_name, i.transcript
FROM person as p
JOIN interview as i 
ON p.id = i.person_id
WHERE address_street_name LIKE '%Northwestern%' 
AND (transcript IS NOT NULL AND TRIM(transcript) != '')
ORDER BY p.address_number DESC
LIMIT 1;


--The above query returns the following information:
    --House on Northwestern Dr WITH HIGHEST STREET NUMBER
    --Witness 1: ID: 14887, Name: Morty Schapiro, Address: 4919, Northwestern Dr, --Transcript: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".

--FACTS FROM ABOVE QUERY
    --Heard Gunshots
    --Man running from building
    --with "Get Fit Now" bag
    --Member # on bag "48Z%"
      --possibly gold member, based on bag type
    --Man left in car with plates "%H42W%"


SELECT p.id, p.name, p.address_number, p.address_street_name, i.transcript
FROM person as p
JOIN interview as i 
ON p.id = i.person_id
WHERE  address_street_name LIKE '%Franklin%'
AND (transcript IS NOT NULL AND TRIM(transcript) != '')
ORDER BY p.name ASC;

--The above query returns the following information:
    --Witness 2: ID: 16371, Name: Annabel Miller, Address: 103, Franklin Ave, --Transcript: I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

--FACTS FROM ABOVE QUERY
    --SAW MURDER HAPPEN
    --Previously recognized killer from Gym on "20180109"


-- Now I want to find any of the members that check in on 20180109, has a gold membership and a memberID that includes '48Z%'

-- SELECT * m
-- FROM get_fit_now_member as m
-- JOIN get_fit_now_check_in as i 
-- ON m.id = i.membership_id
-- WHERE  i.check_in_date = 20180109
-- ORDER BY membership_status ASC

SELECT m.id, m.person_id, m.name
FROM get_fit_now_member as m
JOIN get_fit_now_check_in as i 
ON m.id = i.membership_id
WHERE  i.check_in_date = 20180109
AND m.membership_status= 'gold'
AND m.id LIKE '48Z%'

--The above query returns the following information:
    --48z7A, 28819, Joe Germuska
    --48z55, 67318, Jeremy Bowers

--FACTS FROM THE ABOVE QUERY
    --BOTH JOE GERMUSKA AND JEREMY BOWERS WERE AT THE CLUD ON THE DAY THE EYE WITNESS HAD PREVIOUSLY SEE THE SUSPECT


--Now I want to do a cross check to see if there happen to be any facebook checkin events on either of those days that may be relevant.

SELECT * 
FROM facebook_event_checkin
WHERE date ='20180108' or '20180115'

--The above query returned
    -- 1 FACEBOOK CHECKIN FOR person_id 67318, JEREMEY BOWERS, AT "THE FUNKY GROOVES TOUR" ON 20180115
    --This would make it appear that Jeremy Bowers may possibly have an alibi for the date of the murder

--Now I want to see if either of the men that were at the club on the 9th  have a car with a plate number that matches the partial '%H42W%'. So I will create a query to search for a male that has a license plae that matches.

--The above query shows the JEREMY BOWERS has a plate that matches

--LOOKS LIKE JEREMY BOWERS IS HE MURDERER. BUT!!! HE WAS HIRED BY SOMEONE. WHO HIRED HIM?

--Now I want to find any interviews that the murder gave and see if I can track down the person that hired him.

SELECT * 
FROM interview
WHERE person_id = '67318'

--The above query show's Jeremy's statement below
    --	I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.

      --FACTS: 
        --Hired by a WOMAN
        --Woman is wealthy
        --She is 5'5" or 65" or 5'7" or 67"
        --Red Hair
        --Tesla Model S
        --Attended SQL Symphony Conert 3 times in December 2017

SELECT p.name, i.annual_income, d.gender, f.event_name
FROM drivers_license AS d
INNER JOIN person AS p ON d.id = p.license_id
INNER JOIN income AS i ON p.ssn = i.ssn
INNER JOIN facebook_event_checkin AS f ON f.person_id = p.id
WHERE d.gender = 'female'
AND d.hair_color = 'red'
AND d.car_make = 'Tesla'
AND d.car_model = 'Model S'
AND f.date BETWEEN '20171130' AND '20171231'


--The above query returns the following information:
    --Miranda Priestly with an anual income of $310,000.00, attended the SQL Symphony Concert 3 times in December 2017.