-- Remove duplicates
delete t1 from avg_total_social_time t1
inner join avg_total_social_time t2
where t1.id > t2.id
and t1.age = t2.age
and t1.gender = t2.gender
and t1.time_spent = t2.time_spent
and t1.platform = t2.platform;

-- Handle missing values (replace null appropriate default values)
update avg_total_social_time 
set age = coalesce(age, 0),
	gender = coalesce (gender, 'Unknown'),
	time_spent = coalesce(time_spent, 0),
	platform = coalesce(platform, 'Unknown'),
	interests = coalesce(interests, 'Unknown'),
	location = coalesce(location, 'Unknown'),
	demographics = coalesce(demographics, 'Unknown'),
	profession = coalesce(profession, 'Unknown'),
	income = coalesce(income, 0),
	indebt = coalesce(indebt, false),
	isHomeOwner = coalesce(isHomeOwner, False),
	Owns_Car = coalesce(Owns_Car, False);
	
-- Basic statistics
select 
	avg(age) as avg_age,
	avg(time_spent) as avg_time_spent,
	avg(income) as avg_income
from avg_total_social_time atst;

-- Gender Distribution
select 	
	gender, 
	count(*) as count,
	avg(age) as avg_age
from avg_total_social_time atst 
group by gender;

-- AGE RELATED
-- Age distribution by platform
select 
	platform,
	count(case when age between 18 and 34 then 1 end) as '18-34',
	count(case when age between 35 and 54 then 1 end) as '35-54',
	count(case when age > 54 then 1 end) as '54+'
from avg_total_social_time atst 
group by platform;

-- Average time spent by age group
select 
	case 
		when age < 18 then 'under 18'
		when age between 18 and 34 then '18-34'
		when age between 35 and 54 then '35-54'
		else '54+'
	end as age_group,
	avg(time_spent) as avg_time_spent
from avg_total_social_time atst 
group by age_group
order by avg_time_spent desc;


-- INTEREST
-- Top interests by platform
with ranked_interest as (
	select 
		platform, 
		interests,
		count(*) as interest_count,
		row_number() over (partition by platform order by count(*) desc) as rn
	from avg_total_social_time atst 
	group by platform, interests
)
select platform, interests, interest_count
from ranked_interest
order by platform, interest_count desc;

-- Average income by interest
select 
	interests, 
	avg(income) as avg_income, 
	count(*) as user_count
from avg_total_social_time atst 
group by interests 
order by avg_income desc;

-- DEMOGRAPHIC & LOCATION 
-- User distribution by demographics and location
select 
	demographics,
	location, 
	count(*) as user_count,
	avg(time_spent) as avg_time_spent
from avg_total_social_time atst 
group by demographics, location 
order by user_count desc;

-- Platform preference by location
with platform_rank as (
	select 
		location,
		platform,
		count(*) as user_count,
		row_number() over (partition by location order by count(*) desc) as rn
	from avg_total_social_time atst 
	group by location, platform
)
select location, platform, user_count
from platform_rank
where rn = 1
order by user_count desc;

-- ECONOMIC FACTORS
-- Debt and home ownership rates by income bracket
select 
	case 
		when income < 13000 then 'Low'
		when income between 13000 and 17000 then 'Medium'
		else 'High'
	end as income_bracket,
	avg(case when indebt then 1 else 0 end) as debt_rate,
	avg(case when isHomeOwner then 1 else 0 end) as home_ownership_rate,
	avg(case when owns_car then 1 else 0 end) as car_ownership_rate
from avg_total_social_time atst 
group by income_bracket;

-- Average time spent by economic factors
select 	
	case when indebt then 'In Debt' else 'Not in Debt' end as debt_status,
	case when isHomeOwner then 'Home Owner' else 'Not Home Owner' end as home_status,
	case when owns_car then 'Car Owner' else 'Not Car Owner' end as car_status,
	avg(time_spent) as avg_time_spent
from avg_total_social_time atst 
group by debt_status, home_status, car_status
order by avg_time_spent desc;


-- PLATFORM
-- Distribution of users by platform
select 
	platform,
	count(*) as user_count,
	avg(time_spent) as avg_time_spent
from avg_total_social_time atst 
group by platform 
order by user_count desc;

-- User engagement levels by platform
select 	
	platform,
	count(*) as total_users,
	count(case when time_spent < 4 then 1 end ) as low_engagement,
	count(case when time_spent between 4 and 6 then 1 end) as medium_engagement,
	count(case when time_spent > 6 then 1 end) as high_engagement
from avg_total_social_time atst 
group by platform;

-- Time spent on platform by demographics
select 
	demographics,
	avg(time_spent) as avg_time_spent
from avg_total_social_time atst 
group by demographics;


-- PROFESSION & PLATFORM CORRELATION
-- Top profession by platform
with profession_rank as (
	select 
		platform,
		profession,
		count(*) as prof_count,
		row_number() over (partition by platform order by count(*) desc) as rn
	from avg_total_social_time atst 
	group by platform, profession
)
select platform, profession, prof_count
from profession_rank
where rn <= 3
order by platform, rn;

-- Average income by platform and profession
select 
	platform,
	profession,
	avg(income) as avg_income,
	count(*) as user_count
from avg_total_social_time atst 
group by platform, profession
having user_count > 10
order by avg_income desc ;

