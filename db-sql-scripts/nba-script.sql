--https://www.kaggle.com/datasets/wyattowalsh/basketball/data

select * from team;

--how many games has each team won and lost in their entire history? * subquery method
select season_id, team_name, SUM(wins) as wins, SUM(losses) as losses, SUM(wins)::float / (SUM(wins)+SUM(losses)) as win_rate
from (
	select season_id, team_name_home as team_name,
		SUM(case when wl_home = 'W' then 1 else 0 end) as wins,
		SUM(case when wl_home = 'L' then 1 else 0 end) as losses
	from game
	where season_type = 'Regular Season'
	group by 1, 2
	union
	select season_id, team_name_away as team_name,
		SUM(case when wl_away = 'W' then 1 else 0 end) as wins,
		SUM(case when wl_away = 'L' then 1 else 0 end) as losses
	from game
	where season_type = 'Regular Season'
	group by 1, 2
)
group by 1, 2
order by win_rate DESC;

--how many games has each team won and lost in their entire history? * with method
with season_record as (
	select season_id, team_name_home as team_name,
		SUM(case when wl_home = 'W' then 1 else 0 end) as wins,
		SUM(case when wl_home = 'L' then 1 else 0 end) as losses
	from game
	where season_type = 'Regular Season'
	group by 1, 2
	union
	select season_id, team_name_away as team_name,
		SUM(case when wl_away = 'W' then 1 else 0 end) as wins,
		SUM(case when wl_away = 'L' then 1 else 0 end) as losses
	from game
	where season_type = 'Regular Season'
	group by 1, 2
)
select season_id, team_name, SUM(wins) as wins, SUM(losses) as losses, SUM(wins)::float / (SUM(wins)+SUM(losses)) as win_rate
from season_record
group by 1, 2
order by win_rate DESC;

--best 5-year record for a team
with season_record as (
	select season_id, team_name, SUM(wins) as wins, SUM(losses) as losses
	FROM(
		select season_id, team_name_home as team_name,
			SUM(case when wl_home = 'W' then 1 else 0 end) as wins,
			SUM(case when wl_home = 'L' then 1 else 0 end) as losses
		from game
		where season_type = 'Regular Season'
		group by 1, 2
		union
		select season_id, team_name_away as team_name,
			SUM(case when wl_away = 'W' then 1 else 0 end) as wins,
			SUM(case when wl_away = 'L' then 1 else 0 end) as losses
		from game
		where season_type = 'Regular Season'
		group by 1, 2
		)
		group by 1, 2
),
season_5y as (
	select season_id, team_name, wins, losses, ROUND(wins/(wins+losses), 3) as win_rate,
		SUM(wins) over (partition by team_name order by season_id rows between 4 preceding and current row) as wins_5y,
		SUM(losses) over (partition by team_name order by season_id rows between 4 preceding and current row) as loss_5y,
		COUNT(*) over (partition by team_name order by season_id rows between 4 preceding and current row) as seasons_included
	from season_record
)
select season_id, team_name, wins, losses, win_rate, wins_5y, loss_5y, ROUND(wins_5y/(wins_5y+loss_5y), 3) as win_rate_5y
from season_5y
where seasons_included = 5
order by win_rate_5y DESC

