-- Display all the details of the employees who did not work at any job in the past.

SELECT 
    *
FROM
    employees
WHERE
    employee_id NOT IN (SELECT 
            employee_id
        FROM
            job_history)
            
-- End


-- Find the details of employees who are not working in any department.

SELECT 
    employee_id, first_name, last_name, job_id, manager_id
FROM
    employees
WHERE
    department_id IS NULL
        OR TRIM(department_id) = ''
        
-- End


-- Write a query to find the details of other employees who work in the same job as the employee with employee_id as 107.

SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    department_id,
    job_id
FROM
    employees
WHERE
    job_id IN (SELECT 
            job_id
        FROM
            employees
        WHERE
            employee_id = 107)
            
-- End



-- Write a query to display the employee details who report to Adam. 

SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) 'full_name',
    salary
FROM
    employees
WHERE
    manager_id IN (SELECT 
            employee_id
        FROM
            employees
        WHERE
            first_name = 'Adam')
ORDER BY employee_id

-- End


-- Display the details of the employees who work in departments 50,10, or 80 and whose salary is between 5000 to 10000 and also where employees have no commission_pct(commission percentage).

SELECT 
    employee_id, first_name, last_name, salary
FROM
    employees
WHERE
    commission_pct IS NULL
        AND salary BETWEEN 5000 AND 10000
        AND department_id IN (50 , 10, 80)
ORDER BY employee_id

-- End


-- Find the Full name and the salaries of those employees whose salary is not in the range 6000-18000 (Both values are inclusive). Sort the result in ascending order by Full name.

SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name, salary
FROM
    employees
WHERE
    salary NOT BETWEEN 6000 AND 18000
ORDER BY full_name

-- End


-- Find the details of the employees who are working in the departments 'Administration', 'Marketing', and 'Human Resources'.

SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary
FROM
    employees
WHERE
    department_id IN (SELECT 
            department_id
        FROM
            departments
        WHERE
            department_name IN ('Administration' , 'Marketing', 'Human Resources'))
            
-- End


-- Write a query to extract details of all the employees who were hired between the dates November 15th, 1998, and August 25th, 2001.

SELECT 
    first_name, last_name, job_id, hire_date
FROM
    employees
WHERE
    hire_date BETWEEN '1998-11-15' AND '2001-08-25'
    
-- End


-- Write a query to find all the employees whose first_name ends with the letter 'n'.

SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    phone_number
FROM
    employees
WHERE
    first_name LIKE '%n'

-- End


-- Display the details of all the employees whose department location is in Seattle.


SELECT 
    first_name, last_name, employee_id, job_id
FROM
    employees
WHERE
    department_id IN (SELECT 
            department_id
        FROM
            departments
        WHERE
            location_id IN (SELECT 
                    location_id
                FROM
                    locations
                WHERE
                    city = 'Seattle'))
                    
-- End


/*Based on the employee's salary, divide the employees into three different classes.

1. Salary greater than 20,000 (i.e, excluding 20,000) as 'Class A'
2. Salary between 10,000 to 20,000 (i.e, including both 10,000 and 20,000) as 'Class B'
3. Salary less than 10,000 (i.e, excluding 10,000) as 'Class C'. Return the new column as 'Salary_bin'. */         

SELECT 
    employee_id,
    salary,
    CASE
        WHEN salary > 20000 THEN 'Class A'
        WHEN salary BETWEEN 10000 AND 20000 THEN 'Class B'
        WHEN salary < 10000 THEN 'Class C'
    END AS Salary_bin
FROM
    employees
    
-- End


-- Using the employees table, create a new column as 'Accountant'.
-- If the employees are working at the 'FI_ACCOUNT' or 'AC_ACCOUNT' designation then label it as 1, else label all other designations as 0.

SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    CASE
        WHEN job_id IN ('FI_ACCOUNT' , 'AC_ACCOUNT') THEN 1
        ELSE 0
    END AS Accountant
FROM
    employees
    
-- End


-- Display the details of those employees who have a manager working in the department that is US (i.e., country_id) based.

SELECT 
    e.employee_id, e.first_name, e.last_name
FROM
    employees AS e
        JOIN
    employees e1 ON e.manager_id = e1.employee_id
        JOIN
    departments AS d ON e1.department_id = d.department_id
        JOIN
    locations AS l ON d.location_id = l.location_id
WHERE
    country_id = 'US'
ORDER BY e.employee_id

-- End


-- Find the details of all those employees who work in the 'Human Resources' department.

SELECT 
    employee_id,
    e.department_id,
    first_name,
    last_name,
    job_id,
    d.department_name
FROM
    employees AS e
        LEFT JOIN
    departments AS d ON e.department_id = d.department_id
WHERE
    d.department_name = 'Human Resources'
    
-- End


-- Write a query to display the details of the employees who belong to the 'Europe' region.

SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.salary,
    e.phone_number,
    d.department_id,
    d.department_name,
    l.street_address,
    l.city,
    c.country_name,
    r.region_id,
    r.region_name
FROM
    employees AS e
        LEFT JOIN
    departments AS d ON e.department_id = d.department_id
        LEFT JOIN
    locations AS l ON d.location_id = l.location_id
        LEFT JOIN
    countries AS c ON l.country_id = c.country_id
        LEFT JOIN
    regions AS r ON c.region_id = r.region_id
WHERE
    r.region_name = 'Europe'
ORDER BY e.salary DESC , e.employee_id

-- End


-- Display the details of the employees who had job titles like 'sales' in the past and the min_salary is greater than or equal to 6000.

SELECT 
    jh.employee_id,
    d.department_name,
    j.job_id,
    j.job_title,
    j.min_salary
FROM
    jobs AS j
        LEFT JOIN
    job_history AS jh ON j.job_id = jh.job_id
        LEFT JOIN
    departments AS d ON jh.department_id = d.department_id
WHERE
    j.job_title LIKE '%sales%'
        AND j.min_salary >= 6000
ORDER BY jh.employee_id , j.min_salary

-- End


-- Write a query to display the details of all those departments that don't have any working employees.

SELECT 
    d.department_id, d.department_name
FROM
    departments AS d
        LEFT JOIN
    employees AS e ON d.manager_id = e.manager_id
WHERE
    d.manager_id IS NULL

-- End


-- Display the details of the employees who joined the company before their managers joined the company.

SELECT 
    e.employee_id, e.first_name, e.last_name
FROM
    employees AS e
        JOIN
    employees AS m ON e.manager_id = m.employee_id
WHERE
    e.hire_date < m.hire_date
ORDER BY e.employee_id

-- End


-- Write a SQL query to find all the details of those employees who earn the third-highest salary.

SELECT 
    *
FROM
    employees
WHERE
    salary IN (SELECT 
            MAX(salary)
        FROM
            employees
        WHERE
            salary < (SELECT 
                    MAX(salary)
                FROM
                    employees
                WHERE
                    salary < (SELECT 
                            MAX(salary)
                        FROM
                            employees)))
					
-- End


-- Find the details of the employees who earn less than the average salary in their respective departments.

SELECT 
    employee_id, first_name, last_name, department_id, salary
FROM
    employees e1
WHERE
    salary < (SELECT 
            AVG(salary)
        FROM
            employees e2
        WHERE
            e2.department_id = e1.department_id)
ORDER BY employee_id

-- End


-- Display the employee's full name of all those employees whose salary is greater than 40% of their department’s total salary.    

SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name
FROM
    employees e1
WHERE
    salary > (SELECT 
            0.4 * SUM(salary)
        FROM
            employees e2
        WHERE
            e2.department_id = e1.department_id)
            
-- End


-- Write a query to display the full name of a manager who manages 4 or more employees.            

SELECT 
    CONCAT(first_name, ' ', last_name) AS 'full_name'
FROM
    employees
WHERE
    employee_id IN (SELECT 
            manager_id
        FROM
            employees
        GROUP BY manager_id
        HAVING COUNT(*) >= 4)
        
-- End


-- Write a query to display the count of employees and the total salary paid to employees for each department.

SELECT 
    d.department_name,
    COUNT(*) AS No_of_Employees,
    SUM(salary) AS Total_Salary
FROM
    employees AS e
        LEFT JOIN
    departments AS d ON e.department_id = d.department_id
WHERE
    d.department_name IS NOT NULL
GROUP BY department_name
ORDER BY department_name

-- End


/* Write a query to tag the department as per the count of employees working in that department.

1. If the number of employees is 1 then the "Junior Department"
2. If the number of employees is ≤ 4 then "Intermediate Department".
3. If the number of employees is > 4 then it is "Senior Department" and save the column as "Department_level." */

SELECT 
    Department,
    No_of_employees,
    CASE
        WHEN z.No_of_Employees = 1 THEN 'Junior Department'
        WHEN z.No_of_Employees <= 4 THEN 'Intermediate Department'
        WHEN z.No_of_Employees > 4 THEN 'Senior Department'
    END AS Department_level
FROM
    (SELECT 
        d.department_id AS Department,
            COUNT(*) AS No_of_Employees,
            department_name
    FROM
        employees AS e
    LEFT JOIN departments AS d ON e.department_id = d.department_id
    GROUP BY department_name , d.department_id
    ORDER BY No_of_Employees , Department) z
    
-- End


-- Display the details of those departments where the salary of each employee in that department is at least 9000.

SELECT 
    *
FROM
    departments
WHERE
    department_id IN (SELECT 
            department_id
        FROM
            employees e
        GROUP BY department_id
        HAVING MIN(salary) >= 9000)
        
-- End


-- Display all the country names where the average salary provided for the employees of that country is greater than 8000.

SELECT 
    c.country_name
FROM
    employees e
        LEFT JOIN
    departments d ON e.department_id = d.department_id
        LEFT JOIN
    locations l ON d.location_id = l.location_id
        LEFT JOIN
    countries c ON l.country_id = c.country_id
GROUP BY c.country_name
HAVING AVG(e.salary) > 8000

-- End


-- Write a query to find the average salary of the employees for each department.

SELECT 
    e.department_id,
    d.department_name,
    AVG(e.salary) AS Average_salary
FROM
    employees e
        LEFT JOIN
    departments d ON e.department_id = d.department_id
WHERE
    e.department_id IS NOT NULL
GROUP BY e.department_id , d.department_name
ORDER BY e.department_id

-- End


/* Write a query to calculate

1. The row number ,
2. rank , and
3. dense rank of employees based on the salary column in descending order within each department. */

SELECT
  CONCAT(first_name,' ',last_name) 'full_name',
  department_id,
  salary,
  ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY salary DESC) AS emp_row_no,
  RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS emp_rank,
  DENSE_RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS emp_dense_rank
FROM
  employees
ORDER BY
  department_id,
  salary DESC
  
-- End


-- Write a query to display the details of the employees who have the 5th highest salary in each job category.

SELECT
  z.employee_id,
  z.first_name,
  z.job_id
FROM (
  SELECT
    employee_id,
    first_name,
    job_id,
    DENSE_RANK() OVER (PARTITION BY job_id ORDER BY salary DESC) AS highest
  FROM
    employees) z
WHERE
  z.highest = 5
ORDER BY
  z.employee_id
  
-- End


-- Calculate the absolute average of the salary difference for each job category, return the job id and average difference for each job, and order each partition based on the job id.

SELECT
  job_id,
  AVG(diff)
FROM (
  SELECT
    *,
    ABS(salary-s) diff
  FROM (
    SELECT
      job_id,
      salary,
      LAG(salary) OVER(PARTITION BY job_id ORDER BY job_id) AS s
    FROM
      employees) t )tt
GROUP BY
  job_id
  
-- End


-- Write a query to find the first day of the first job of every employee.

SELECT
  z.first_name,
  z.start_date AS first_day_job
FROM (
  SELECT
    e.first_name,
    jb.start_date,
    DENSE_RANK() OVER (PARTITION BY jb.employee_id ORDER BY start_date) AS fjb
  FROM
    job_history AS jb
  LEFT JOIN
    employees AS e
  ON
    jb.employee_id = e.employee_id) z
WHERE
  z.fjb = 1
ORDER BY
  z.first_name
  
-- End


-- Write a Query to find the first day of the most recent job of every employee.

SELECT
  z.first_name,
  z.start_date AS recent_job
FROM (
  SELECT
    e.first_name,
    jb.start_date,
    DENSE_RANK() OVER (PARTITION BY jb.employee_id ORDER BY start_date DESC) AS fjb
  FROM
    job_history AS jb
  LEFT JOIN
    employees AS e
  ON
    jb.employee_id = e.employee_id) z
WHERE
  z.fjb = 1
ORDER BY
  z.first_name
  
-- End


-- Write a query to find the starting maximum salary of the first job that every employee held.

SELECT
  z.first_name,
  z.last_name,
  z.max_salary AS first_job_sal
FROM (
  SELECT
    e.first_name,
    e.last_name,
    j.max_salary,
    DENSE_RANK() OVER (PARTITION BY jb.employee_id ORDER BY start_date) AS fjb
  FROM
    job_history AS jb
  LEFT JOIN
    employees AS e
  ON
    jb.employee_id = e.employee_id
  LEFT JOIN
    jobs AS j
  ON
    jb.job_id = j.job_id) z
WHERE
  z.fjb = 1
ORDER BY
  z.first_name
  
-- End


-- Display the employee's details along with the current job and the previous job of all the employees in the company.

SELECT
  e.first_name,
  e.last_name,
  j.job_title,
  LAG(j.job_title) OVER (PARTITION BY e.employee_id ORDER BY jb.start_date) AS previous_job
FROM
  employees e
LEFT JOIN
  job_history jb
ON
  e.employee_id = jb.employee_id
LEFT JOIN
  jobs j
ON
  jb.job_id = j. job_id
WHERE
  j.job_title IS NOT NULL
  
-- End


-- Display the employee's details along with the previous job and the next promoted job for all the employees in the company.

SELECT
  e.employee_id,
  e.first_name,
  e.last_name,
  j.job_title AS first_job,
  LEAD(j.job_title) OVER (PARTITION BY e.employee_id ORDER BY jb.start_date) AS promoted_to
FROM
  employees e
LEFT JOIN
  job_history jb
ON
  e.employee_id = jb.employee_id
LEFT JOIN
  jobs j
ON
  jb.job_id = j. job_id
WHERE
  j.job_title IS NOT NULL
  
-- End


-- Find the quartile of each record based on the salary of the employee.

SELECT
  employee_id,
  first_name,
  department_id,
  job_id,
  salary,
  NTILE(4) OVER (ORDER BY salary) AS Quartile
FROM
  employees
ORDER BY
  Quartile,
  salary,
  employee_id
  
-- End


-- Display the details of the employees who earn the highest salary in their departments.

SELECT
  department_name,
  first_name,
  last_name,
  salary
FROM (
  SELECT
    department_name,
    DENSE_RANK() OVER (PARTITION BY department_name ORDER BY salary DESC) AS rank_value,
    first_name,
    last_name,
    salary
  FROM
    employees e
  JOIN
    departments d
  ON
    d.department_id = e.department_id) t
WHERE
  rank_value = 1
  
-- End


-- Write a query to display the employee's details and calculate the total years the employees have been working in the company till 8th June 2022. Return the details of those employees who have been working for atleast 28 years.

SELECT 
    employee_id,
    first_name,
    last_name,
    DATEDIFF('2022-06-08', MIN(hire_date)) / 365 AS Total_years
FROM
    employees
GROUP BY employee_id , first_name , last_name
HAVING DATEDIFF('2022-06-08', MIN(hire_date)) / 365 >= 28

-- End


-- Write a query to extract the day, month, and year from the hire_date of the employees. Display the extracted columns and the details of those employees who were hired in the year 2000 and in January month and also salary is greater than 5000.

SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    hire_date,
    EXTRACT(DAY FROM hire_date) AS Day,
    EXTRACT(MONTH FROM hire_date) AS Month,
    EXTRACT(YEAR FROM hire_date) AS Year
FROM
    employees
WHERE
    EXTRACT(YEAR FROM hire_date) = 2000
        AND EXTRACT(MONTH FROM hire_date) = 1
        AND salary > 5000
        
-- End


-- Display the employee's details who were hired in the month of October and their salary is greater than 4000.

SELECT 
    employee_id, first_name, last_name
FROM
    (SELECT 
        employee_id,
            first_name,
            last_name,
            EXTRACT(MONTH FROM hire_date)
    FROM
        employees
    WHERE
        EXTRACT(MONTH FROM hire_date) = 10
            AND salary > 4000) z
            
-- End


-- Write a query to display the manager details and calculate the total number of years the managers have been working in the company till 8th June 2022. Return the details of those managers whose experience is more than 25 years.

SELECT 
    e.first_name,
    e.last_name,
    e.employee_id,
    e.salary,
    d.department_name,
    DATEDIFF('2022-06-08', MIN(e.hire_date)) / 365 AS Experience
FROM
    employees m
        JOIN
    employees e ON m.manager_id = e.employee_id
        LEFT JOIN
    departments d ON e.department_id = d.department_id
GROUP BY e.employee_id , e.first_name , e.last_name , d.department_name , e.salary
HAVING DATEDIFF('2022-06-08', MIN(e.hire_date)) / 365 > 25
ORDER BY e.employee_id

-- End


-- Write a query to count the number of employees hired each year.

SELECT 
    Year, COUNT(Year) AS Employees_count
FROM
    (SELECT 
        EXTRACT(YEAR FROM hire_date) AS Year
    FROM
        employees) z
GROUP BY Year
ORDER BY Employees_count DESC

-- End


-- Display the details of those employees who were hired between the given date '1998-01-01' and three months after from the given date.

SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    e.hire_date,
    l.city
FROM
    employees AS e
        LEFT JOIN
    departments AS d ON e.department_id = d.department_id
        LEFT JOIN
    locations AS l ON d.location_id = l.location_id
WHERE
    hire_date BETWEEN '1998-01-01' AND DATE_ADD('1998-01-01', INTERVAL 3 MONTH)
ORDER BY e.employee_id

-- End


-- Write a query to display the details of those employees who were hired between the given date '1998-01-01' and six months before from the given date and also whose salary is highest in each department.

SELECT
  employee_id,
  first_name,
  last_name,
  salary,
  hire_date,
  department_id
FROM (
  SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    hire_date,
    department_id,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank_value
  FROM
    employees
  WHERE
    hire_date BETWEEN DATE_SUB("1998-01-01",INTERVAL 6 month)
    AND "1998-01-01") z
WHERE
  rank_value = 1
  
-- End


-- Write a query to display the details of the employees who had worked less than a year.

SELECT 
    jh.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    j.job_title
FROM
    job_history AS jh
        LEFT JOIN
    employees AS e ON jh.employee_id = e.employee_id
        LEFT JOIN
    jobs AS j ON jh.job_id = j.job_id
WHERE
    DATEDIFF(jh.end_date, jh.start_date) / 365 < 1
ORDER BY jh.employee_id , j.job_title

-- End


-- Extract the details of the employees who work under the same manager.

SELECT 
    z.*, CONCAT(e.first_name, ' ', e.last_name) AS Employee
FROM
    employees e
        JOIN
    (SELECT 
        m.manager_id,
            CONCAT(e.first_name, ' ', e.last_name) AS Manager
    FROM
        employees AS e
    LEFT JOIN employees AS m ON e.employee_id = m.manager_id
    WHERE
        m.manager_id IS NOT NULL
    GROUP BY m.manager_id , e.first_name , e.last_name) z ON e.manager_id = z.manager_id
ORDER BY z.manager_id , Employee

-- End


-- Write a query to add 5000 for every employee's salary and save the column as 'Net_salary' and display the details of those employees whose Net_Salary is greater than 20000.

WITH
  t AS (
  SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    salary+5000 'Net_Salary'
  FROM
    employees)
SELECT
  *
FROM
  t
WHERE
  Net_Salary > 20000
  
-- End


-- Display the employee information who works in department 80 or has a salary of more than 10000 using the union operator.

(SELECT 
    *
FROM
    employees
WHERE
    department_id = 80) UNION (SELECT 
    *
FROM
    employees
WHERE
    salary > 10000)
    
-- End


/* Create a view as 'emp_view' that has the details i.e, employee_id, first_name, last_name, salary, department_id, department_name, location_id, street_address, and city.
Write a query to display the details from the view of those employees who work in departments that are located in Seattle or Southlake. */

CREATE OR REPLACE VIEW emp_view AS
    SELECT 
        employee_id,
        first_name,
        last_name,
        salary,
        dep.department_id,
        department_name,
        loc.location_id,
        street_address,
        city
    FROM
        employees emp
            JOIN
        departments dep ON emp.department_id = dep.department_id
            JOIN
        locations loc ON dep.location_id = loc.location_id;
SELECT 
    *
FROM
    emp_view
WHERE
    city IN ('Seattle' , 'Southlake')
    
-- End


-- Use CTEs and display the 12th highest salary from the employee's table.

WITH
  highest AS (
  SELECT
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS rank_value
  FROM
    employees)
SELECT
  salary
FROM
  highest
WHERE
  highest.rank_value = 12
  
-- End


/* Create a view as 'Manager_details' that has manager details i.e, employee id, manager's full name as 'Manager', salary, phone_number, department_id, department_name, street_address, city, country_name.
Display the details of the Top 5 managers with the highest salary from the view 'Manager_details'. */

/* YOUR QUERY GOES HERE
   Example: SELECT * FROM employees; 
*/
create or replace view Manager_details as
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS Manager,
    e.salary,
    e.phone_number,
    d.department_id,
    d.department_name,
    l.street_address,
    l.city,
    c.country_name
FROM
    employees e
        JOIN
    employees m ON e.employee_id = m.manager_id
        LEFT JOIN
    departments d ON e.department_id = d.department_id
        LEFT JOIN
    locations l ON d.location_id = l.location_id
        LEFT JOIN
    countries c ON l.country_id = c.country_id
GROUP BY e.employee_id , CONCAT(e.first_name, ' ', e.last_name) , e.salary , e.phone_number , d.department_id , d.department_name , l.street_address , l.city , c.country_name;

SELECT 
    employee_id, Manager, salary, department_name
FROM
    Manager_details
order by salary desc
limit 5

-- End