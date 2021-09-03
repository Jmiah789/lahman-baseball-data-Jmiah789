select *
from people;

--1. What range of years for baseball games played does the provided database cover? 
--1871-2016

SELECT min(yearid), max(yearid)
FROM teams;

SELECT yearid, g
FROM teams;

--2. Find the name and height of the shortest player in the database. 
--Eddie Gaedel
-- How many games did he play in? What is the name of the team for which he played?
-- 1, St. Louis Browns

SELECT  min(height)
FROM people;

SELECT playerid, namegiven,namefirst,namelast, height
from people
where height = 43;

SELECT playerid, namegiven,namefirst,namelast, height 
FROM ( 
    SELECT 
       playerid, namegiven,namefirst,namelast, height, 
       ROW_NUMBER() OVER(ORDER BY height) AS minsub 
    FROM people
where height is not null
) as subquery
WHERE minsub = 1 

SELECT playerid, G_all, t.teamID, t.name
FROM appearances as a
inner join teams as t
on a.teamID = t.teamid AND a.yearid = t.yearid
WHERE playerid = 'gaedeed01';

/*3. Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors? David Taylor Price*/

SELECT DISTINCT cp.playerid, namegiven, namefirst, namelast, s.schoolid, s.schoolname
FROM people AS p
INNER JOIN collegeplaying AS cp
ON p.playerid = cp.playerid
INNER JOIN schools AS s
ON cp.schoolid = s.schoolid
WHERE s.schoolid = 'vandy'

SELECT  s.playerid, namegiven, namefirst, namelast, SUM(salary) AS salary, schoolname
FROM (SELECT DISTINCT cp.playerid AS playerid, namegiven, namefirst, namelast, s.schoolid, s.schoolname
		FROM people AS p
		INNER JOIN collegeplaying AS cp
		ON p.playerid = cp.playerid
		INNER JOIN schools AS s
		ON cp.schoolid = s.schoolid
		WHERE s.schoolid = 'vandy') AS subquery
LEFT Join salaries AS s
ON subquery.playerid = s.playerid
GROUP BY s.playerid, namegiven, namefirst, namelast, schoolname
ORDER BY SUM(salary) DESC;

/*4. Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/

SELECT po,
	case when pos = 'OF' then 'Outfield'
		when pos in ('SS', '1B', '2B', '3B') then 'Infield'
		else 'Battery' end as position_group
from fielding
where yearid = 2016;

Select position_group, sum(po) as total_putouts
FROM (SELECT po,
	case when pos = 'OF' then 'Outfield'
		when pos in ('SS', '1B', '2B', '3B') then 'Infield'
		else 'Battery' end as position_group
	from fielding
	where yearid = 2016) as subquery
group by position_group;


/*5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. 
Do you see any trends?*/

select case when yearid between 1920 and 1929 then '1920s'
	when yearid between 1930 and 1939 then '1930s'
	when yearid between 1940 and 1949 then '1940s'
	when yearid between 1950 and 1959 then '1950s'
	when yearid between 1960 and 1969 then '1960s'
	when yearid between 1970 and 1979 then '1970s'
	when yearid between 1980 and 1989 then '1980s'
	when yearid between 1990 and 1999 then '1990'
	when yearid between 2000 and 2009 then '2000s'
	when yearid between 2010 and 2019 then '2010s'
	else 'NA' end as decade,
	round(sum(cast(so as numeric))/sum(cast(g as numeric)),2) as average_strikouts,
	round(sum(cast(hr as numeric))/sum(cast(g as numeric)),2) as average_homeruns
from teams
group by decade
order by decade;

select case when yearid between 1920 and 1929 then '1920s'
	when yearid between 1930 and 1939 then '1930s'
	when yearid between 1940 and 1949 then '1940s'
	when yearid between 1950 and 1959 then '1950s'
	when yearid between 1960 and 1969 then '1960s'
	when yearid between 1970 and 1979 then '1970s'
	when yearid between 1980 and 1989 then '1980s'
	when yearid between 1990 and 1999 then '1990'
	when yearid between 2000 and 2009 then '2000s'
	when yearid between 2010 and 2019 then '2010s'
	else 'NA' end as decade,
	round(avg(cast(so as numeric)),2) as average_strikouts,
	round(avg(cast(hr as numeric)),2) as average_homeruns
from batting
group by decade
order by decade;


SELECT decade, 
		SUM(so) as so_batter, SUM(soa) as so_pitcher, 
		ROUND(CAST(SUM(so) as dec) / CAST(SUM(g) as dec), 2) as so_per_game,
		ROUND(CAST(SUM(hr) as dec) / CAST(SUM(g) as dec), 2) as hr_per_game
FROM (
	SELECT CASE 
			WHEN yearid >= 2010 THEN '2010s'
			WHEN yearid >= 2000 THEN '2000s'
			WHEN yearid >= 1990 THEN '1990s'
			WHEN yearid >= 1980 THEN '1980s'
			WHEN yearid >= 1970 THEN '1970s'
			WHEN yearid >= 1960 THEN '1960s'
			WHEN yearid >= 1950 THEN '1950s'
			WHEN yearid >= 1940 THEN '1940s'
			WHEN yearid >= 1930 THEN '1930s'
			WHEN yearid >= 1920 THEN '1920s'
			ELSE NULL
		END AS decade,
		so,
		soa,
		hr,
		g
	FROM teams
-- 	WHERE decade IS NOT NULL
) sub
WHERE decade IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;




/*6. Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.*/

SELECT playerid, sum(sb+cs) as steal_attempts, sum(sb) as succesful_steals,
	round(sum(cast(sb as numeric))/sum(cast(sb as numeric)+cast(cs as numeric)),2) as success_rate
from batting
where yearid = 2016
group by playerid
having sum(sb+cs) >= 20
order by success_rate desc;


/*7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 116
What is the smallest number of wins for a team that did win the world series? 63
Doing this will probably result in an unusually small number of wins for a world series champion – 
determine why this is the case. Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 12
What percentage of the time? 26% */


with world_series_winners as 
	 (select teamid, yearid, w
	  from teams
	  where wswin = 'Y'
	 AND yearid between '1970' and '2016')
select yearid, min(w) as least_wins
from world_series_winners
group by yearid
order by min(w);


with world_series_losers as
	(select teamid,yearid, w
	from teams
	where wswin ='N'
	AND yearid between '1970' and '2016')
select yearid, max(w) as most_wins
from world_series_losers
group by yearid
order by max(w) DESC;

with most_wins as
	(select yearid, max(w) as most_wins
	 from teams
	 where yearid between '1970' and '2016'
	 group by yearid
	 order by yearid
	),
	world_series_winners as 
	 (select teamid, yearid, w
	  from teams
	  where wswin = 'Y'
	 AND yearid between '1970' and '2016')
SELECT count(*) as champs_and_most_wins
from most_wins as m
inner join world_series_winners as w
on m.yearid=w.yearid and m.most_wins=w.w;



SELECT yearid, teamid,
	max(w) over (partition by yearid,teamid),
	wswin
from teams
where yearid between 1970 and 2016 
order by yearid,  wswin desc;

/*Using the attendance figures from the homegames table, 
find the teams and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

SELECT team, park_name, sum(attendance)/sum(games) as average_attendance
FROM homegames as h
inner join parks as p
on h.park = p.park
where h.year = '2016'
GROUP BY team, park_name
having sum(games)>10
ORDER BY average_attendance DESC
limit 5;

SELECT team, park_name, sum(attendance)/sum(games) as average_attendance
FROM homegames as h
inner join parks as p
on h.park = p.park
where h.year = '2016'
GROUP BY team, park_name
having sum(games)>10
ORDER BY average_attendance
limit 5;

..
/* 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) 
and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.*/




select m.playerid, namefirst, namelast, namegiven
from managers as m
inner join people as p
on m.playerid = p.playerid

