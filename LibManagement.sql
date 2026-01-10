Use Library

select * from books

select * from branch

select * from branch_reports

select * from employees

select * from issued_status

select * from members

select * from return_status

-- Foreign Key

Alter table issued_status
add constraint fk_members
Foreign Key (issued_member_id)
References members(member_id)

Alter table issued_status
add constraint fk_books
Foreign Key (issued_book_isbn)
References books(isbn)

Alter table issued_status
add constraint fk_employees
Foreign Key (issued_emp_id)
References employees(emp_id)

Alter table employees
add constraint fk_branch
Foreign Key (branch_id)
References branch(branch_id)



ALTER TABLE employees ALTER COLUMN branch_id VARCHAR(20);


Alter table return_status
add constraint fk_issued_status
Foreign Key (issued_id)
References issued_status(issued_id)

ALTER TABLE branch
ALTER COLUMN contact_no VARCHAR(20)



--CRUD OPERATIONS

--1 : Creating a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

SELECT * from books

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', '6.00', 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')


--2 : Updating an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_address = '123 Main St'


--3 : Deleting a Record from the Issued Status Table.

DELETE FROM issued_status
WHERE issued_id = 'IS121'

--4 : Retrieving all Books Issued by a Specific Employee( Eg. emp_id = 'E101')

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--5 : Members Who Have Issued More Than One Book.

SELECT issued_emp_id FROM issued_status
GROUP BY issued_emp_id
HAVING count(*) > 1


--CREATE TABLE AS SELECT (CTAS)

--6 : Creating Summary Tables

SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

-- DATA ANALYSIS & FINDINGS

 --7 : Books in a Specific Category:

 SELECT * FROM books
 WHERE category = 'Classic'


 --8 : Total Rental Income by Category:


 SELECT b.category, 
 sum(b.rental_price) as total_revenue,
 count(*)
 FROM books b
 LEFT JOIN issued_status i
 ON b.isbn = i.issued_book_isbn
GROUP BY b.category


 --9 : Members Who Registered in the Last 180 Days:
 

 SELECT * FROM members
WHERE reg_date = DATEADD('2024-11-01', -180, CAST(GETDATE() AS DATE));


--10 : List Employees with Their Branch Manager's Name and their branch details:

select * from employees
select * from branch 
select * from branch_reports


SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id


--11 : Create a table of Book with Rental price below $7

SELECT * from books

SELECT * 
INTO expensive_books
FROM books
WHERE rental_price > 7;

SELECT * FROM expensive_books


--12 : List of books not yet returned

SELECT * FROM issued_status ist
LEFT JOIN return_status rt
ON ist.issued_id = rt.issued_id
WHERE rt.return_id IS NULL


--13 : Identifying members with Overdue books, assuming return period is 30 days


SELECT * FROM members

SELECT m.member_id, 
       m.member_name, 
       ist.issued_book_name, 
       ist.issued_date, 
       rt.return_date
FROM issued_status ist
LEFT JOIN return_status rt
    ON ist.issued_id = rt.issued_id
LEFT JOIN members m
ON m.member_id = ist.issued_member_id
WHERE  rt.return_id IS NULL
AND (ist.issued_date < DATEADD(DAY, -30, GETDATE()))


-- 14 : Branch Performance Report


SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
	INTO branch_report
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id

SELECT * FROM branch_report


--15 : Creating a Table of Active Members who have issued at least one book in the last 2 months


SELECT *
INTO active_member
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATEADD(MONTH, -2, '2024-12-31'))

SELECT * 
FROM active_member;




-- 16 : Employees with the Most Book Issues Processed 


SELECT 
    e.emp_name,
    b.branch_id,  
    COUNT(i.issued_id) AS no_book_issued
FROM issued_status i
JOIN employees e
    ON e.emp_id = i.issued_emp_id
JOIN branch b
    ON e.branch_id = b.branch_id
GROUP BY 
    e.emp_name,
    b.branch_id





