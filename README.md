 task-6
 
##  Task 6 – Subqueries and Nested Queries

### Objective:

To learn how to use **subqueries** (also called nested queries) in different parts of a SQL statement: `SELECT`, `WHERE`, and `FROM` clauses. This enhances query logic by enabling multi-level conditions and data transformation within a single query.

---

###  Tools Used:

* **MySQL Workbench** / **DB Browser for SQLite**
* SQL (Structured Query Language)

---

###  Schema Context:

This task builds upon the existing tables from Tasks 1–5:

* `Authors(AuthorID, Name, Country)`
* `Books(BookID, Title, AuthorID, Year)`
* `Borrowers(BorrowerID, Name, Email, Age)`
* `BorrowRecords(RecordID, BookID, BorrowerID, BorrowDate, ReturnDate)`

---

###  Queries Included:

#### 1 Subquery in the `SELECT` Clause

Displays each book along with the number of times it was borrowed.

```sql
SELECT Title,
  (SELECT COUNT(*) FROM BorrowRecords WHERE BorrowRecords.BookID = Books.BookID) AS TimesBorrowed
FROM Books;
```

#### 2 Subquery in the `WHERE` Clause

Finds names of borrowers who have borrowed **more than the average number of books**.

```sql
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
```

#### 3 Subquery in the `FROM` Clause

Finds the most borrowed book using a derived table.

```sql
SELECT Title, TotalBorrows
FROM (
  SELECT b.Title, COUNT(r.RecordID) AS TotalBorrows
  FROM Books b
  JOIN BorrowRecords r ON b.BookID = r.BookID
  GROUP BY b.Title
) AS BorrowStats
ORDER BY TotalBorrows DESC
LIMIT 1;
```

#### 4 Correlated Subquery

Finds all books borrowed by users **older than 23**.

```sql
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
```

#### 5 Subquery using `NOT IN`

Lists authors who **have not written any books**.

```sql
SELECT Name
FROM Authors
WHERE AuthorID NOT IN (
  SELECT DISTINCT AuthorID
  FROM Books
  WHERE AuthorID IS NOT NULL
);

