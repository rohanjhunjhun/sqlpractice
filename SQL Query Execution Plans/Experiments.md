# BigQuery Optimization Experiments
_Date: 15 Oct 2025_  
_Experiment: Partitioning and Clustering on StackOverflow Questions Table_(37GB dataset)

---

### Query 1
```sql
CREATE TABLE `practice.questions_partitioned_date`
PARTITION BY TIMESTAMP_TRUNC(creation_date, MONTH)
AS
SELECT * FROM `practice.questions_raw`;
Purpose:
Test monthly partitioning on creation_date to avoid daily partition limits.

Observation:
Daily partitioning failed due to exceeding 4000 partitions.
Monthly partitioning succeeded — confirms that partition granularity must be chosen carefully to avoid limits.

Query 2
sql
Copy code
SELECT MIN(creation_date), MAX(creation_date)
FROM `practice.questions_raw`;
Purpose:
Check the date range of raw data.

Observation:
176 MB billed, 557 ms runtime. Baseline for comparison with partitioned table.

Query 3
sql
Copy code
SELECT MIN(creation_date), MAX(creation_date)
FROM `practice.questions_partitioned_date`;
Purpose:
Test if partition pruning helps when reading min/max across entire dataset.

Observation:
Same 176 MB billed and 557 ms runtime — entire table scanned since query touches all partitions.

Query 4
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_partitioned_date`
WHERE creation_date BETWEEN "2022-01-01" AND "2022-03-01";
Purpose:
Check partition pruning effectiveness.

Observation:
10 MB billed, 324 ms runtime — only relevant partitions scanned, strong optimization over raw table.

Query 5
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_raw`
WHERE creation_date BETWEEN "2022-01-01" AND "2022-03-01";
Purpose:
Compare same filter on unpartitioned data.

Observation:
176 MB billed, 846 ms runtime — full scan since no partitions. Confirms partition pruning benefit.

Query 6
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_raw`
WHERE creation_date BETWEEN "2022-01-01" AND "2022-03-01"
  AND owner_user_id = 2012677;
Purpose:
Filter by both date and user on raw table.

Observation:
347 MB billed, 20 s runtime — high scan cost and shuffle time.

Query 7
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_partitioned_date`
WHERE creation_date BETWEEN "2022-01-01" AND "2022-03-01"
  AND owner_user_id = 2012677;
Purpose:
Filter by date and user on partitioned table.

Observation:
4.3 MB billed, 458 ms runtime — partition pruning effective, but without clustering still scans more blocks.

Query 8
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_clustered`
WHERE creation_date BETWEEN "2022-01-01" AND "2022-03-01"
  AND owner_user_id = 2012677;
Purpose:
Combine partitioning and clustering benefits.

Observation:
0.8 MB billed, 195 ms runtime — major reduction in bytes read due to both pruning and clustering on user ID.

Query 9
sql
Copy code
SELECT title, score, creation_date
FROM `practice.questions_raw`
WHERE DATE(creation_date) = '2022-02-05'
ORDER BY score DESC
LIMIT 10;
Purpose:
Evaluate ORDER BY performance on raw vs optimized tables.

Observation:
1.56 GB billed, 73 s runtime — full scan with expensive sort.

Query 10
sql
Copy code
SELECT title, score, creation_date
FROM `practice.questions_partitioned_date`
WHERE DATE(creation_date) = '2022-02-05'
ORDER BY score DESC
LIMIT 10;
Purpose:
Same query on partitioned table.

Observation:
10.57 MB billed, 835 ms runtime — partition pruning works, significant improvement.

Query 11
sql
Copy code
SELECT title, score, creation_date
FROM `practice.questions_clustered`
WHERE DATE(creation_date) = '2022-02-05'
ORDER BY score DESC
LIMIT 10;
Purpose:
Test clustering effect on ORDER BY.

Observation:
10.57 MB billed, 378 ms runtime — same data scanned but faster sort due to clustering on score.

Query 12
sql
Copy code
SELECT owner_user_id, COUNT(*) AS cnt
FROM `practice.questions_raw`
WHERE DATE(creation_date) BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY owner_user_id
ORDER BY cnt DESC
LIMIT 20;
Purpose:
Compare aggregation on raw vs clustered tables.

Observation:
347 MB billed, 41 s runtime, 21.5 MB shuffled — heavy shuffle and slow due to full scan.

Query 13
sql
Copy code
SELECT owner_user_id, COUNT(*) AS cnt
FROM `practice.questions_clustered`
WHERE DATE(creation_date) BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY owner_user_id
ORDER BY cnt DESC
LIMIT 20;
Purpose:
Same aggregation on clustered table.

Observation:
19.3 MB billed, 5 s runtime, 15.7 MB shuffled — huge improvement in scan and shuffle efficiency.

Query 14
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_raw`
WHERE score >= 0;
Purpose:
Broad filter — compare behavior across table types.

Observation:
176 MB billed, 14 s runtime, 5.3 KB shuffled — full scan unavoidable.

Query 15
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_partitioned_date`
WHERE score >= 0;
Purpose:
Test partitioned table for broad filter.

Observation:
176 MB billed, 63 s runtime, 6.1 KB shuffled — no pruning since condition touches all rows; overhead makes it slower.

Query 16
sql
Copy code
SELECT COUNT(*)
FROM `practice.questions_clustered`
WHERE score >= 0;
Purpose:
Test clustered table for same broad filter.

Observation:
176 MB billed, 62 s runtime, 6.7 KB shuffled — clustering doesn’t help when nearly all rows match.

🧩 Key Learnings
Partitioning and clustering only help when the filter allows data pruning.

For broad scans, raw tables may actually be faster due to less metadata overhead.

Combining both partitioning and clustering gives the best results for selective filters.

Shuffle bytes reflect data exchanged between stages — lower is better for performance.

Always design partition and clustering keys based on query patterns, not just column type.