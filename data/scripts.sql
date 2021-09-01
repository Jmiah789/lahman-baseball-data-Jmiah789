select *
from people;

--What range of years for baseball games played does the provided database cover? 
--1871-2016

SELECT min(yearid), max(yearid)
FROM teams;

SELECT yearid, g
FROM teams;

--Find the name and height of the shortest player in the database. 
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

/*Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors?*/

SELECT distinct cp.playerid, namegiven, namefirst, namelast, s.schoolid, s.schoolname
From people as p
inner join collegeplaying as cp
on p.playerid = cp.playerid
inner join schools as s
on cp.schoolid = s.schoolid
where s.schoolid = 'vandy'

SELECT  s.playerid, namegiven, namefirst, namelast, sum(salary) as salary
from (SELECT DISTINCT cp.playerid as playerid, namegiven, namefirst, namelast, s.schoolid, s.schoolname
		From people as p
		inner join collegeplaying as cp
		on p.playerid = cp.playerid
		inner join schools as s
		on cp.schoolid = s.schoolid
		where s.schoolid = 'vandy') as subquery
inner join salaries as s
on subquery.playerid = s.playerid
group by s.playerid, namegiven, namefirst, namelast
order by sum(salary) DESC;

/*Using the fielding table, group players into three groups based on their position: 
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


/*Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. 
Do you see any trends?*/

select case when yearid between 1920 and 1929



/*Find the player who had the most success stealing bases in 2016, 
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


/*From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion – 
determine why this is the case. Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?*/


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

SELECT team, park_name, avg(attendance) as average_attendance
FROM homegames
GROUP BY team
ORDER BY 

..
/*Which managers have won the TSN Manager of the Year award in both the National League (NL) 
and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.*/