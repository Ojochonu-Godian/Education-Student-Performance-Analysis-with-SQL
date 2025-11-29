# Education/Student Performance Analysis

This repository provides the SQL data analysis script created for the FP20 Analytics Challenge 31, which aimed to find patterns and actionable insights within a large student performance dataset using T-SQL.

The primary goal of this project is to provide a reliable, repeatable script [Students_Performance.sql](https://github.com/Ojochonu-Godian/Education-Student-Performance-Analysis-with-SQL/blob/main/Students_Performance.sql) for extracting, aggregating, and transforming key performance indicators, 
allowing administrators and educators to quickly understand student achievement, identify risk areas, and assess teaching effectiveness directly from the database.

## Project Goal
The primary goal is to look deeply into student scores, assessment outcomes, and course achievements across various subjects and time periods to:
1. Uncover learning trends: Determine when performance peaks and falls during the school year.
2. Highlight disparities: Analyze how average scores differ across subjects.
3. Identify students at risk: Pinpoint patterns among students who fail assessments.
4. Recognize top performers: Determine students and teachers with the highest weighted averages.

## Database Schema
The analysis is based on a comprehensive [dataset](https://fp20analytics.com/datasets/) tracking student performance metrics. The data schema involves several interconnected tables:
- Date: Stores date and academic period information.
- Students: Stores student details.
- Subjects: Stores subject information.
- Teachers: Stores teacher details and departments.
- Assessment: Stores assessment information.
- FactPerformance: Stores student assessment results and links to all other tables.

## Entity Relationship Diagram
The Entity relationship diagram showing the relationships and structure of the database is shown below

<img width="1480" height="1648" alt="Education_Student Performance" src="https://github.com/user-attachments/assets/e5f0ece3-2bfa-4f59-99d0-bbc29a45281c" />

## Key Analytical Questions
The [Students_Performance.sql](https://github.com/Ojochonu-Godian/Education-Student-Performance-Analysis-with-SQL/blob/main/Students_Performance.sql) script is structured to provide direct answers to the following 10 analytical questions:

#### Performance Trends & Timing

1. Which months show the highest and lowest total student assessment scores in the academic year?
2. What percentage of all student assessments were passed, and how has this rate changed over time?
3. How often do students achieve perfect scores on assessments, and in which subjects does this most commonly occur?

#### Disparity & Risk Analysis

4. How does the average score differ across subjects in the most recent semester?
5. Are there subjects or assessments where students are consistently earning below-average scores (both overall and within the subject)?
6. Is there any pattern for students who did not pass (e.g., by subject, assessment type, or period)?
7. What is the distribution of final grades across all students, and which grade occurs most frequently?

#### High Achievers & Teaching Effectiveness

8. Which students have achieved the top three highest overall weighted averages this year?
9. Which teachers have the highest average student weighted scores, and how do they compare to the overall average?
10. For a selected student, how have their scores and weighted averages changed throughout the year?

#### Technologies and Features

Technology: T‑SQL on a relational database (MSSQL Server).

##### Key features:

- Common Table Expressions (CTEs) for modular analysis.
- Analytical queries using AVG, COUNT, window functions, and conditional aggregations.
- Views (e.g., Passed_Percentage) for reusable metrics.
- Ranking and performance classification for teachers via RANK() and CASE expressions.


