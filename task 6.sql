-- Create Database
CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;
-- ========================
-- TASK 1: SCHEMA CREATION
-- ========================

-- Drop tables if they already exist
DROP TABLE IF EXISTS BorrowRecords;
DROP TABLE IF EXISTS Borrowers;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;

-- Create Authors Table
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    Name VARCHAR(100),
    Country VARCHAR(100)
);

-- Create Books Table
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100),
    AuthorID INT,
    Year INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Create Borrowers Table
CREATE TABLE Borrowers (
    BorrowerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Age INT
);

-- Create BorrowRecords Table
CREATE TABLE BorrowRecords (
    RecordID INT PRIMARY KEY,
    BookID INT,
    BorrowerID INT,
    BorrowDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (BorrowerID) REFERENCES Borrowers(BorrowerID)
);

-- ================================
-- TASK 2: DATA INSERTION & NULLS
-- ================================

-- Insert into Authors
INSERT INTO Authors (AuthorID, Name, Country) VALUES
(1, 'J.K. Rowling', 'UK'),
(2, 'George Orwell', 'UK'),
(3, 'Haruki Murakami', 'Japan'),
(4, 'Unknown Author', NULL);

-- Insert into Books
INSERT INTO Books (BookID, Title, AuthorID, Year) VALUES
(101, 'Harry Potter', 1, 1997),
(102, '1984', 2, 1949),
(103, 'Kafka on the Shore', 3, 2002),
(104, 'Book without Author', NULL, 2020);

-- Insert into Borrowers
INSERT INTO Borrowers (BorrowerID, Name, Email, Age) VALUES
(201, 'Alice', 'alice@example.com', 22),
(202, 'Bob', 'bob@example.com', 25),
(203, 'Charlie', 'charlie@example.com', NULL);

-- Insert into BorrowRecords
INSERT INTO BorrowRecords (RecordID, BookID, BorrowerID, BorrowDate, ReturnDate) VALUES
(301, 101, 201, '2024-06-01', '2024-06-10'),
(302, 102, 202, '2024-06-05', NULL),
(303, 103, 203, '2024-06-07', '2024-06-14');

-- =====================
-- TASK 3: SELECT QUERIES
-- =====================

-- Get all books
SELECT * FROM Books;

-- Get all borrowers with non-null ages
SELECT * FROM Borrowers WHERE Age IS NOT NULL;

-- Get books published after 1950
SELECT * FROM Books WHERE Year > 1950;

-- =============================
-- TASK 4: AGGREGATES & GROUPING
-- =============================

-- Count number of books per author
SELECT a.Name AS AuthorName, COUNT(b.BookID) AS TotalBooks
FROM Authors a
LEFT JOIN Books b ON a.AuthorID = b.AuthorID
GROUP BY a.Name;

-- Get number of books borrowed by each borrower
SELECT br.Name AS BorrowerName, COUNT(r.RecordID) AS BooksBorrowed
FROM BorrowRecords r
JOIN Borrowers br ON r.BorrowerID = br.BorrowerID
GROUP BY br.Name;

-- Average age of borrowers
SELECT AVG(Age) AS AvgBorrowerAge FROM Borrowers;

-- ====================
-- TASK 5: SQL JOINS
-- ====================

-- 1. INNER JOIN: Books with Authors
SELECT b.Title, a.Name AS AuthorName
FROM Books b
INNER JOIN Authors a ON b.AuthorID = a.AuthorID;

-- 2. LEFT JOIN: All books + authors
SELECT b.Title, a.Name AS AuthorName
FROM Books b
LEFT JOIN Authors a ON b.AuthorID = a.AuthorID;

-- 3. RIGHT JOIN: All authors + books (MySQL only)
SELECT b.Title, a.Name AS AuthorName
FROM Books b
RIGHT JOIN Authors a ON b.AuthorID = a.AuthorID;

-- 4. FULL OUTER JOIN (MySQL workaround using UNION)
SELECT b.Title, a.Name AS AuthorName
FROM Books b
LEFT JOIN Authors a ON b.AuthorID = a.AuthorID

UNION

SELECT b.Title, a.Name AS AuthorName
FROM Books b
RIGHT JOIN Authors a ON b.AuthorID = a.AuthorID;

-- 5. INNER JOIN BorrowRecords + Books + Borrowers
SELECT br.Name AS BorrowerName, bk.Title, r.BorrowDate, r.ReturnDate
FROM BorrowRecords r
INNER JOIN Books bk ON r.BookID = bk.BookID
INNER JOIN Borrowers br ON r.BorrowerID = br.BorrowerID;
-- ========================================
-- TASK 6: Subqueries and Nested Queries
-- Objective: Use subqueries in SELECT, WHERE, and FROM
-- Tools: MySQL Workbench / DB Browser for SQLite
-- ========================================

-- Subquery in SELECT Clause:
-- Show each book along with how many times it was borrowed
SELECT 
    Title,
    (SELECT COUNT(*) 
     FROM BorrowRecords 
     WHERE BorrowRecords.BookID = Books.BookID) AS TimesBorrowed
FROM Books;

-- Subquery in WHERE Clause:
-- Show names of borrowers who borrowed more than average
SELECT Name
FROM Borrowers
WHERE BorrowerID IN (
    SELECT BorrowerID
    FROM BorrowRecords
    GROUP BY BorrowerID
    HAVING COUNT(*) > (
        SELECT AVG(book_count)
        FROM (
            SELECT COUNT(*) AS book_count
            FROM BorrowRecords
            GROUP BY BorrowerID
        ) AS BorrowAvg
    )
);

-- Subquery in FROM Clause:
-- Find the most borrowed book using a derived table
SELECT Title, TotalBorrows
FROM (
    SELECT b.Title, COUNT(r.RecordID) AS TotalBorrows
    FROM Books b
    JOIN BorrowRecords r ON b.BookID = r.BookID
    GROUP BY b.Title
) AS BorrowStats
ORDER BY TotalBorrows DESC
LIMIT 1;

-- Correlated Subquery (in WHERE Clause):
-- List books borrowed by users older than 23
SELECT Title
FROM Books
WHERE BookID IN (
    SELECT BookID
    FROM BorrowRecords
    WHERE BorrowerID IN (
        SELECT BorrowerID
        FROM Borrowers
        WHERE Age > 23
    )
);

-- 5Subquery with NOT IN:
-- List authors who have not written any books
SELECT Name
FROM Authors
WHERE AuthorID NOT IN (
    SELECT DISTINCT AuthorID
    FROM Books
    WHERE AuthorID IS NOT NULL
);
