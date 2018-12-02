SET search_path to mimiciii;

				  
/* only all diabetic patients number in 249 and 250 are: 10403 */
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a, patients p
where di.subject_id = a.subject_id and a.subject_id = p.subject_id
	and (
		di.ICD9_CODE like '249%'     -- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'   -- diabetes mellitus 
		)				  

					  
/* all patients younger than 18 are: 7971*/		
select count(distinct(a.subject_id))
	from diagnoses_icd di, admissions a, patients p
	where a.subject_id = di.subject_id and p.subject_id = a.subject_id
		and (
		di.ICD9_CODE like '249%'     -- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'   -- diabetes mellitus 
		)	
		and round((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 , 2) < 18					  

					  
/* patients under 249 and 250 but younger than 18 are: 6*/		
select count(distinct(a.subject_id))
	from diagnoses_icd di, admissions a, patients p
	where a.subject_id = di.subject_id and p.subject_id = a.subject_id
		and (
		di.ICD9_CODE like '249%'     -- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'   -- diabetes mellitus 
		)	
		and round((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 , 2) < 18

					  
/* 10397 = 10403 - 6*/
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a, patients p
where di.subject_id = a.subject_id and a.subject_id = p.subject_id
	and (
		di.ICD9_CODE like '249%'     -- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'   -- diabetes mellitus 
		)
	and (
		round((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 , 2) >= 18
		);
					  
					  
/* change to not exist query for double check, result is 10397, so correct */
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a
where di.subject_id = a.subject_id
	and (
		di.ICD9_CODE like '249%' 		-- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'		-- diabetes mellitus
		)
	and not exists(
		select *
		from admissions a, patients p
		where a.subject_id = di.subject_id and p.subject_id = a.subject_id
		and round((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 , 2) < 18
	);

					  
/* display all the unique subject_id who are those patients */
select distinct(a.subject_id)
from diagnoses_icd di, admissions a
where di.subject_id = a.subject_id
	and (
		di.ICD9_CODE like '249%' 		-- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'		-- diabetes mellitus
		)
	and not exists(
		select *
		from admissions a, patients p
		where a.subject_id = di.subject_id and p.subject_id = a.subject_id
		and round((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 , 2) < 18
	)
order by a.subject_id asc;
					  
					  
/* total diabetic patients who underwent hemodialysis and older than 18 */
select count(distinct(pm.subject_id))
from diagnoses_icd di, PROCEDUREEVENTS_MV pm, admissions a, patients p
where di.subject_id = pm.subject_id and a.subject_id = pm.subject_id and p.subject_id = a.subject_id
	and ( -- hemodialysis
		di.ICD9_CODE in ('5856', '9961', '99673', 'E8791', 'V451', 'V560', 'V561')
		)					  				  
	and round((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 , 2) >= 18;		  
					  
					  
select count(distinct(pm.subject_id))
from admissions a, patients p, PROCEDUREEVENTS_MV pm
where p.subject_id = a.subject_id and a.subject_id = pm.subject_id
	and (cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18; 
				  
					  
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a, patients p
where di.subject_id = a.subject_id and a.subject_id = p.subject_id
	and (cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18;		
					  
					  
select count(distinct(a.subject_id))
from admissions a, patients p
where a.subject_id = p.subject_id
	and (cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18;					  
				
										  
/* who has both Diabetes mellitus and received Hemodialysis */					  
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a, patients p, procedures_icd pi
where di.subject_id = a.subject_id 
    and a.subject_id = p.subject_id 
    and pi.subject_id = a.subject_id
    and exists (
        di.ICD9_CODE in ('5856','9961','99673','E8791','V451','V560','V561')  -- Hemodialysis
        )
	and exist (
		di.ICD9_CODE like '249%'      -- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'   -- diabetes mellitus 
		)
	and (
		(cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18
		);					  

		 
/* total 46520 */
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a
where di.subject_id = a.subject_id;

					  
/* 10403, rest should be 36117 */					  
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a
where di.subject_id = a.subject_id
	and (
		di.ICD9_CODE like '249%' 		-- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'		-- diabetes mellitus
		);

					  
/* 46512 */					  
select count(distinct(a.subject_id))
from diagnoses_icd di, admissions a
where di.subject_id = a.subject_id
	and not (
		di.ICD9_CODE like '249%' 		-- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'		-- diabetes mellitus
		);
					

/* 10403 */				  
select count(*)
from (select a.subject_id
	from diagnoses_icd di, admissions a, patients p
	where a.subject_id = di.subject_id and p.subject_id = a.subject_id
		and (
		di.ICD9_CODE like '249%'     -- secondary diabetes mellitus
		or di.ICD9_CODE like '250%'   -- diabetes mellitus 
		)	
	-- order by a.subject_id asc
	group by a.subject_id
		having count(distinct(di.ICD9_CODE)) = 2) as Z;

					 
/* filtered to 727 */					 
with diab as (
	select distinct(subject_id)	--10403 distinct id
	from diagnoses_icd 
	where icd9_code like '249%' 
		or icd9_code like '250%' )
select count(distinct(di.subject_id))
from diagnoses_icd di, diab, admissions a, patients p
where di.subject_id = diab.subject_id and a.subject_id = di.subject_id and p.subject_id = a.subject_id -- 10403
	and (cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18   -- filtered to 10397
	and (di.ICD9_CODE in ('5856','9961','99673','E8791','V451','V560','V561'));  -- Hemodialysis, filtered to 727

					 
/* 46520 distinct id */
select count(distinct(subject_id))
from diagnoses_icd;
					 
/* only with hemodialysis 1316 */
select count(distinct(subject_id))
from diagnoses_icd
where ICD9_CODE in ('5856','9961','99673','E8791','V451','V560','V561');

/* only with diabetes mellitus 10403 */
select count(distinct(subject_id))
from diagnoses_icd
where icd9_code like '249%' 
		or icd9_code like '250%';
					  
					  
with diab as (
	select distinct(a.subject_id) 			-- second diabtes adults who under procedures is 9460
	from diagnoses_icd di, admissions a, patients p, procedures_icd pi
	where di.subject_id = a.subject_id 
		and a.subject_id = p.subject_id		-- we have patient here for p.DOB information
		and pi.subject_id = a.subject_id
		and (
			di.ICD9_CODE like '249%'      	-- secondary diabetes mellitus
			or di.ICD9_CODE like '250%'   	-- diabetes mellitus 
			)
		and ((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18)  -- adults
		) 
select count(distinct(di.subject_id))  		-- second diabetes adults under hemodialysis procedures is 718
from diagnoses_icd di, diab
where di.subject_id = diab.subject_id
	and di.ICD9_CODE in ('5856','9961','99673','E8791','V451','V560','V561');  -- Hemodialysis
					  
					  
select distinct(category)
from noteevents;
	
with adult as (
	select distinct(a.subject_id)
	from ADMISSIONS a, PATIENTS p, diagnoses_icd di
	where a.SUBJECT_ID = di.SUBJECT_ID
		and p.SUBJECT_ID = a.SUBJECT_ID
		and ((cast(a.ADMITTIME as date) - cast(p.DOB as date))/365.242 >= 18)
	),
	diab as (
	select distinct(n.subject_id)
	from diagnoses_icd di, PROCEDUREEVENTS_MV pm, noteevents n, adult
	where di.subject_id = pm.subject_id 
		and n.subject_id = pm.subject_id
		and n.category not in ('ECG', 'Echo', 'Radiology')
		and (lower(n.TEXT) like ('%diabetes%') or n.TEXT like ('%DM%'))
		and (
			 lower(n.TEXT) like ('%hemodialysis%') 
		  or lower(n.TEXT) like ('%haemodialysis%') 
		  or lower(n.TEXT) like ('%kidney dialysis%') 
		  or lower(n.TEXT) like ('%renal dialysis%') 
		  or lower(n.TEXT) like ('%extracorporeal dialysis%') 
		  or n.TEXT like ('%on HD%') 
		  or n.TEXT like ('%HD today%') 
		  or n.TEXT like ('%tunneled HD%') 
		  or n.TEXT like ('%continue HD%') 
		  or n.TEXT like ('%cont HD%')
	)
	)				  
select distinct(diab.subject_id)		
from adult, diab
where adult.subject_id <> diab.subject_id;
			 
			 
