-- Shout out to Taufiq (techTFQ) for providing this challenge! (https://www.youtube.com/watch?v=ZwFfiadQB3k)
-- Q: the objective is to validate the student response and 
  -- present it in a single table with list of columns mentioned using SQL.
  
-- Ouput columns: roll_number, student_name, class, section, school_name, 
  -- math_correct, math_wrong, math_yet_to_learn, math_score
  -- science_correct, science_wrong, science_yet_to_learn, science_score

-- Columns per table
  -- question_paper_code: paper_code | class | subject
  -- correct_answer: question_paper | question_number | correct_option
  -- student_list: roll_number | student_name | class | section | school_name
  -- student_response: roll_number | question_paper_code | question_number | option_marked

select
  sr.roll_number
  , sl.student_name
  , sl.class
  , sl.section
  , sl.school_name
  
  , sum(case when subject = 'Math' and (ca.correct_option = sr.option_marked) then 1 else 0 end) as math_correct
  , sum(case when subject = 'Math' and (sr.option_marked != 'e') and 
      (ca.correct_option != sr.option_marked) then 1 else 0 end) as math_wrong
  , sum(case when subject = 'Math' and (sr.option_marked = 'e') then 1 else 0 end) as math_yet_to_learn
  , sum(case when subject = 'Math' and (ca.correct_option = sr.option_marked) then 1 else 0 end) as math_score
  , round(sum(case when subject = 'Math' and (ca.correct_option = sr.option_marked) then 1 else 0 end)*100.0 /
      sum(case when subject = 'Math' then 1 else 0 end),2) as math_percentage

  , sum(case when subject = 'Science' and (ca.correct_option = sr.option_marked) then 1 else 0 end) as science_correct
  , sum(case when subject = 'Science'  and (sr.option_marked != 'e') 
      and (ca.correct_option != sr.option_marked) then 1 else 0 end) as science_wrong
  , sum(case when subject = 'Science' and (sr.option_marked = 'e') then 1 else 0 end) as science_yet_to_learn
  , sum(case when subject = 'Science' and (ca.correct_option = sr.option_marked) then 1 else 0 end) as science_score
  , round(sum(case when subject = 'Science' and (ca.correct_option = sr.option_marked) then 1 else 0 end)*100.0 /
      sum(case when subject = 'Science' then 1 else 0 end),2) as science_percentage

from `sql_interview_query_for_DA.student_response` sr
join `sql_interview_query_for_DA.student_list` sl 
  on sl.roll_number = sr.roll_number
join `sql_interview_query_for_DA.question_paper_code` q 
  on sr.question_paper_code = q.paper_code
join `sql_interview_query_for_DA.correct_answer` ca 
  on ca.question_paper_code = sr.question_paper_code 
    and ca.question_number = sr.question_number
group by 1,2,3,4,5
order by 1 asc
-- limit 10
;