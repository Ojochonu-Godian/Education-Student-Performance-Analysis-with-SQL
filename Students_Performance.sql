-- FP20 CHALLENGE 31- EDUCATION/STUDENT PERFORMANCE ANALYSIS

USE students_performance;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

--Question 1: Which months show the highest and lowest total student assessment scores in the academic year?
WITH Average_Monthly_Performance AS (
		SELECT Month, MonthName, AVG(Score) AS Average_Score
		FROM Date D
		JOIN FactPerformance F
		ON D.DateKey = F.DateKey
		GROUP BY Month, MonthName
		)
SELECT MonthName, ROUND(Average_Score, 2) AS Average_Score
FROM Average_Monthly_Performance
ORDER BY Average_Score ASC;

--Question2: What percentage of all student assessments were passed, and how has this rate changed over time?

CREATE VIEW Passed_Percentage AS 
		SELECT PassedCourse, COUNT(PassedCourse) AS TotalCount
		FROM FactPerformance
		GROUP BY PassedCourse;
		
SELECT PassedCourse, TotalCount, FORMAT(TotalCount * 100.0 / SUM(TotalCount) OVER(), 'N2') + '%' AS Percentage
FROM Passed_Percentage;

--How has this rate changed over time?

WITH Performance_trend AS (
		SELECT D.Year, D.Month, D.MonthName,
		SUM(CASE WHEN F.PassedCourse = 'PASSED' THEN 1 ELSE 0 END) AS PassedCount, 
		COUNT(F.PassedCourse) AS TotalAssessment
FROM Date D
JOIN FactPerformance F
ON D.DateKey = F.DateKey
GROUP BY D.Month, D.Year, D.MonthName)

SELECT MonthName + ',' + CAST(Year AS varchar(4)) AS Academic_Year, PassedCount, TotalAssessment, 
		FORMAT(PassedCount * 100.0 / TotalAssessment, 'N2') + '%' AS Percentage
FROM Performance_trend
ORDER BY Year, Month;

-- Question 3: How does the average score differ across subjects in the most recent semester?
WITH LatestSemester AS (
		SELECT TOP 1 Year, Semester
		FROM Date
		ORDER BY Year DESC, Semester DESC),
AverageScorebySubject AS (
		SELECT s.SubjectName, d.Year, d.Semester, ROUND(AVG(f.Score), 2) AS Average_Score
		FROM Subjects s
		JOIN FactPerformance f
		ON s.SubjectID = f.SubjectID
		JOIN Date d
		ON d.DateKey = f.DateKey
		WHERE d.Year IN (SELECT Year FROM LatestSemester)
		AND d.Semester IN (SELECT Semester FROM LatestSemester)
		GROUP BY s.SubjectName, d.Year, d.Semester
		)
SELECT SubjectName, Semester + ',' + CAST(Year AS varchar(4)) AS Semester, Average_Score
FROM AverageScorebySubject
ORDER BY Average_Score DESC;

--OR

WITH LatestSemester AS (
		SELECT TOP 1 Year, Semester
		FROM Date
		ORDER BY Year DESC, Semester DESC),
AverageScorebySubject AS (
		SELECT s.SubjectName, d.Year, d.Semester, ROUND(AVG(f.Score), 2) AS Average_Score
		FROM Subjects s
		JOIN FactPerformance f
		ON s.SubjectID = f.SubjectID
		JOIN Date d
		ON d.DateKey = f.DateKey
		JOIN LatestSemester l
		ON l.Semester = d.Semester
		AND l.Year = d.Year
		GROUP BY s.SubjectName, d.Year, d.Semester
		)
SELECT SubjectName, Semester + ',' + CAST(Year AS varchar(4)) AS Semester, Average_Score
FROM AverageScorebySubject
ORDER BY Average_Score DESC;

--Question 4: Which students have achieved the top three highest overall weighted averages this year?
WITH StudentsWeightedAverages AS (
		SELECT s.StudentID, s.FullName, AVG(f.WeightedAverage) AS Average_WeightedAverage
		FROM Students s
		JOIN FactPerformance f
		ON s.StudentID = f.StudentID
		JOIN Date d
		ON d.DateKey = f.DateKey
		WHERE d.Year = 2025
		GROUP BY s.StudentID, s.FullName
		)
SELECT TOP 3 StudentID, FullName, Average_WeightedAverage
FROM StudentsWeightedAverages
ORDER BY Average_WeightedAverage DESC;


--Question 5: Are there subjects or assessments where students are consistently earning below-average scores?
WITH SubjectPerformance AS (
		SELECT s.SubjectName, a.AssessmentName, ROUND(AVG(f.Score), 2) AS Average_Score
		FROM Subjects s
		JOIN FactPerformance f
		ON s.SubjectID = f.SubjectID
		JOIN Assessment a
		ON a.AssessmentID = f.AssessmentID
		GROUP BY s.SubjectName, a.AssessmentName
		),
OverallAverage AS (
		SELECT ROUND(AVG(Score), 2) AS OverallAverage
		FROM FactPerformance
		)
SELECT SubjectName, AssessmentName, Average_Score, o.OverallAverage
FROM SubjectPerformance s
CROSS JOIN OverallAverage o
WHERE s.Average_Score < o.OverallAverage;

-- In terms of assessment, within subjects.
WITH SubjectAverage AS (
    SELECT SubjectID, ROUND(AVG(Score), 2) AS SubjectAverage
    FROM FactPerformance
    GROUP BY SubjectID),
AssessmentAverage AS (
    SELECT f.SubjectID, a.AssessmentName, ROUND(AVG(f.Score),2) AS AssessmentAverage
    FROM FactPerformance f
    JOIN Assessment a 
	ON a.AssessmentID = f.AssessmentID
    GROUP BY f.SubjectID, a.AssessmentName
)
SELECT s.SubjectName, a.AssessmentName, a.AssessmentAverage, sa.SubjectAverage
FROM AssessmentAverage a
JOIN SubjectAverage sa 
ON a.SubjectID = sa.SubjectID
JOIN Subjects s 
ON s.SubjectID = a.SubjectID
WHERE a.AssessmentAverage < sa.SubjectAverage
ORDER BY s.SubjectName;


--Question 6: What is the distribution of final grades across all students, and which grade occurs most frequently?
WITH GradeDistribution AS (
		SELECT FinalGrade, COUNT(*) AS TotalCount
		FROM FactPerformance
		GROUP BY FinalGrade)
SELECT FinalGrade, TotalCount, FORMAT(TotalCount * 100.0 / SUM(TotalCount) OVER(), 'N2') + '%' AS Percentage
FROM GradeDistribution
ORDER BY FinalGrade;

--Question 7: Which teachers have the highest average student weighted scores, and how do they compare to the overall average?
WITH WeightedScoreByTeachers AS (
		SELECT t.[Full Name] AS TeachersName, t.Department, ROUND(AVG(f.WeightedScore), 2) AS Average_WeightedScore --To calculate average performance for each teacher by student weighted average score
		FROM Teachers t
		JOIN FactPerformance f
		ON t.TeacherID = f.TeacherID
		GROUP BY t.[Full Name], t.Department),
OverallAverageWeightedScore AS (
		SELECT ROUND(AVG(WeightedScore), 2) AS OverallAverage
		FROM FactPerformance
		)
SELECT TeachersName, Department, Average_WeightedScore, OverallAverage,
		RANK () OVER (ORDER BY Average_WeightedScore DESC) AS TeachersRank,
		CASE 
			WHEN Average_WeightedScore > OverallAverage THEN 'Good Performance'
			WHEN Average_WeightedScore = OverallAverage THEN 'Average Performance'
			WHEN Average_WeightedScore < OverallAverage THEN 'Low Performance' 
		END AS Performance
FROM WeightedScoreByTeachers w
CROSS JOIN OverallAverageWeightedScore
ORDER BY Average_WeightedScore DESC;

--Question 8: Is there any pattern for students who did not pass (e.g., by subject, assessment type, or period)?
SELECT s.SubjectName, a.AssessmentType, COUNT(f.PassedCourse) AS StudentCount
FROM FactPerformance f
JOIN Subjects s
ON s.SubjectID = f.SubjectID
JOIN Assessment a
ON a.AssessmentID = f.AssessmentID
WHERE PassedCourse = 'FAILED'
GROUP BY s.SubjectName, a.AssessmentType
ORDER BY StudentCount DESC;

--Question 9: How often do students achieve perfect scores on assessments, and in which subjects does this most commonly occur?
WITH totalrecords AS (
	SELECT COUNT(*) AS TotalRecords
	FROM FactPerformance),
PerfectScores AS (
	SELECT COUNT(*) AS PerfectScores
	FROM FactPerformance
	WHERE Score = MaxScore
	)
SELECT 
    t.TotalRecords,
    p.PerfectScores,
    FORMAT( (p.PerfectScores * 100.0) / t.TotalRecords, 'N2') + '%' AS PerfectScorePercentage
FROM totalrecords t
CROSS JOIN PerfectScores p;

--which subjects does this most commonly occur

SELECT s.SubjectID, s.SubjectName, COUNT(f.RecordID) AS PerfectScoreCount
FROM Subjects s
JOIN FactPerformance f
ON f.SubjectID = s.SubjectID
WHERE f.Score = f.MaxScore
GROUP BY s.SubjectID, s.SubjectName
ORDER BY PerfectScoreCount DESC;


--Question 10: For a selected student, how have their scores and weighted averages changed throughout the year?

SELECT d.Month, d.Semester, d.MonthName, 
		ROUND(AVG(f.Score),2) AS AverageScore,
		ROUND(AVG(f.WeightedScore),2) AS AverageWeigthedScore
FROM Date d
JOIN FactPerformance f
ON f.DateKey = d.DateKey
JOIN Students s
ON s.StudentID = f.StudentID
WHERE d.Year = 2025 AND s.StudentID = 'STU033'
GROUP BY d.MonthName, d.Month, d.Semester
ORDER BY d.Month;
