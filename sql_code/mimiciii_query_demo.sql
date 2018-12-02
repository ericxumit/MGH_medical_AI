set search_path to mimiciii;      			-- must include this line every time start new queries


/* find all records in patients table */
select * from patients;         			


/* find all reords in admissions table */
select * from admissions;	


/* find how many patients we have */
select count(*) from patients;				


/* what genders we have in patients 'M' and 'F' */
select distinct(gender) from patients;		


/* find how many female patients */
select count(*) from patients where gender = 'F';					


/* number of patients, grouped by gender */
select gender, count(*) from patients group by gender;				


/* find mortalities record in patients */
select expire_flag, count(*) from patients group by expire_flag;	


/* patients age and mortality - this is a longer command so I used block comment */
select p.subject_id, p.dob, a.hadm_id, a.admittime, p.expire_flag		
from admissions a inner join patients p		-- admissions as a, patient table as p, inner join them as one table
on p.subject_id = a.subject_id;  			-- using keys to connect the two tables


/* 1. connect admissions table (as a) with patients table (as p) by inner join,
   2. define min (a.admittime) as earliest admittime and rename to first_admittime
   3. find first_admittime under every group of p.subject_id (every patient) */
select 
	p.subject_id, p.dob, a.hadm_id, a.admittime, p.expire_flag, 
	min (a.admittime) over (partition by p.subject_id) as first_admittime
from admissions a inner join patients p
on p.subject_id = a.subject_id
order by a.hadm_id, p.subject_id;


/* 1. create temporary table first_admission_time, include:
      - subject_id, dob, gender from p;
	  - first_admittime, first_admit_age abstracted from a via below formula;
   2. select same columns, use case function to create an age_group column:
      - categorize by different age range
   3. order by subject_id  */
with first_admission_time as 
	(select 
	 	p.subject_id, p.dob, p.gender, 
		min(a.admittime) as first_admittime,
		min(round((cast(admittime as date) - cast(dob as date)) / 365.242, 2)) as first_admit_age
	from patients p inner join admissions a
	on p.subject_id = a.subject_id
	group by p.subject_id, p.dob, p.gender
	order by p.subject_id
	)
select 
	subject_id, dob, gender, first_admittime, first_admit_age,
	case 					-- all ages >89 in the datbase were replaced with 300
		when first_admit_age > 89	then '>89'
		when first_admit_age >=14	then 'adult'
		when first_admit_age <=1	then 'neonate'	
		else 'middle'
		end as age_group
from first_admission_time
order by subject_id
			

/* now we pipe these two tables and add count function */
with first_admission_time as 
	(select 
	 	p.subject_id, p.dob, p.gender, 
		min(a.admittime) as first_admittime,
		min(round((cast(admittime as date) - cast(dob as date)) / 365.242, 2)) as first_admit_age
	from patients p inner join admissions a
	on p.subject_id = a.subject_id
	group by p.subject_id, p.dob, p.gender
	order by p.subject_id
	),		-- define first_admission_time table, derived from admissions and patients	
	age as
	(select
	 	subject_id, dob, gender, first_admittime, first_admit_age,
	 	case
	 		-- all ages > 90 in the databse were replaced with 300
	 		-- we check using > 100 as a conservative threshold to ensure capture them
	 		when first_admit_age > 100 	then '>89'
	 		when first_admit_age >=14	then 'adult'
	 		when first_admit_age <=1	then 'neonate'
	 		else 'middle'
	 		end as age_group
	 from first_admission_time
	)		-- define age table, derived from first_admission_time
select age_group, gender, count(subject_id) as NumberofPatients
from age
group by age_group, gender


/* ICU stays */
select * from transfers;

			
/* ICU stay example */
select * from transfers where hadm_id = 112213;

			
/* Services 
   prev_service and curr_service type, and transfertime */
select * from services;
			
			
/* how to gather useful information about patients admitted to ICU?
   Step 1 - retrieve subject_id, hadm_id, intime, outtime from icustays table; 
   Step 2 - retrieve calculated age of patients, using patients table;
   Step 3 - Separate age group, separate neonates from adults;
   Step 4 - incorporate admissions table, find how long the stay is before admit to ICU;
   Step 5 - find date of patient's death;
   Step 6 - find those die in hospital;
   Step 7 - find how many deaths occurred within ICU.  */

-- step1
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime from icustays ie;			

-- step2
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime,
		round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) as age
from icustays ie inner join patients pat
on ie.subject_id = pat.subject_id;

-- step3
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime,
		round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) as age,
	case 
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <= 1 	then 'neonate'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <=14	then 'middle'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) > 100	then '>89'
		else 'adult'
		end as icustay_age_group
from icustays ie inner join patients pat
on ie.subject_id = pat.subject_id;

-- step4
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime,
		round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) as age,
		round( (cast(ie.intime as date) - cast(adm.admittime as date)) / 365.242, 2) as preiculos,
	case 
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <= 1 	then 'neonate'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <=14	then 'middle'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) > 100	then '>89'
		else 'adult'
		end as icustay_age_group
-- notice here we have 3 tables connect by 2 keys: 
-- icustays -- subject_id -- patients
-- icustays -- hadm_id -- admissions
from icustays ie inner join patients pat on ie.subject_id = pat.subject_id
				inner join admissions adm on ie.hadm_id = adm.hadm_id;  
					 
-- step5 (add deadthtime on step4)
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime, adm.deathtime,
		round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) as age,
		round( (cast(ie.intime as date) - cast(adm.admittime as date)) / 365.242, 2) as preiculos,
	case 
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <= 1 	then 'neonate'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <=14	then 'middle'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) > 100	then '>89'
		else 'adult'
		end as icustay_age_group
from icustays ie inner join patients pat on ie.subject_id = pat.subject_id
				inner join admissions adm on ie.hadm_id = adm.hadm_id; 
					 
-- step6 
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime, adm.deathtime,
		round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) as age,
		round( (cast(ie.intime as date) - cast(adm.admittime as date)) / 365.242, 2) as preiculos,
	case 
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <= 1 	then 'neonate'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <=14	then 'middle'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) > 100	then '>89'
		else 'adult'
		end as icustay_age_group,
-- note there is already 'hospital_expire_flag' in admissions table which you could use
	case 
		when adm.hospital_expire_flag = 1	then 'Y'
		else 'N'
		end as hospital_expire_flag
from icustays ie inner join patients pat on ie.subject_id = pat.subject_id
				inner join admissions adm on ie.hadm_id = adm.hadm_id; 

-- step7
select ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime, ie.outtime, adm.deathtime,
		round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) as age,
		round( (cast(ie.intime as date) - cast(adm.admittime as date)) / 365.242, 2) as preiculos,
	case 
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <= 1 	then 'neonate'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) <=14	then 'middle'
		when round( (cast(ie.intime as date) - cast(pat.dob as date)) / 365.242, 2) > 100	then '>89'
		else 'adult'
		end as icustay_age_group,
-- note there is already 'hospital_expire_flag' in admissions table which you could use
	case 
		when adm.hospital_expire_flag = 1	then 'Y'
		else 'N'
		end as hospital_expire_flag,
-- note the hospital_expire_flag is equivalent to 'is adm.deathtime not null?'
	case 
		when adm.deathtime between ie.intime and ie.outtime	then 'Y'
		-- sometimes there are typographical errors in the death date so check before intime
		when adm.deathtime <= ie.intime 	then 'Y'
		when adm.deathtime <= ie.intime and adm.discharge_location = 'DEAD/EXPIRED'	then 'Y'
		else 'N'
		end as icustay_expire_flag
from icustays ie inner join patients pat on ie.subject_id = pat.subject_id
				inner join admissions adm on ie.hadm_id = adm.hadm_id; 