
USE project;

-- 1. Total revenue realized
SELECT SUM(revenue_realized) AS Total_Revenue_Realized
FROM fact_bookings;

-- 2. Total number of bookings
SELECT COUNT(*) AS Total_Bookings
FROM fact_bookings;

-- 3. Total room capacity across all hotels
SELECT SUM(capacity) AS Total_Room_Capacity
FROM fact_aggregated_bookings;

-- 4. Total number of successful bookings
SELECT SUM(successful_bookings) AS Total_Successful_Bookings
FROM fact_aggregated_bookings;

-- 5. Occupancy rate (Successful bookings / capacity)
SELECT (SUM(successful_bookings) / SUM(capacity)) * 100 AS Occupancy_Rate
FROM fact_aggregated_bookings;

-- 6. Average ratings
SELECT AVG(ratings_given) AS Average_Rating
FROM fact_bookings;

-- 7. Days of data from May to July
SELECT DATEDIFF('2024-07-31', '2024-05-01') + 1 AS Total_Days;

-- 8. Total Cancelled Bookings
SELECT COUNT(*) AS Total_Cancelled_Bookings
FROM fact_bookings
WHERE booking_status = 'Cancelled';

-- 9. Cancellation Percentage
SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS Cancellation_Percentage
FROM fact_bookings
WHERE booking_status = 'Cancelled';

-- 10. Total Checked Out Bookings
SELECT COUNT(*) AS Total_Checked_Out_Bookings
FROM fact_bookings
WHERE booking_status = 'Checked Out';

-- 11. Total No Show Bookings
SELECT COUNT(*) AS Total_No_Show_Bookings
FROM fact_bookings
WHERE booking_status = 'No Show';

-- 12. No Show Percentage
SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS No_Show_Percentage
FROM fact_bookings
WHERE booking_status = 'No Show';

-- 13. Booking Platform Contribution
SELECT booking_platform, 
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings) AS Booking_Platform_Contribution_Percentage
FROM fact_bookings
GROUP BY booking_platform;

-- 14. Room Class Contribution
SELECT dr.room_class, 
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings) AS Room_Class_Contribution_Percentage
FROM fact_bookings fb
JOIN dim_rooms dr ON fb.room_category = dr.room_id
GROUP BY dr.room_class;

-- 15. Average Daily Rate (ADR)
SELECT SUM(revenue_realized) / COUNT(*) AS ADR
FROM fact_bookings
WHERE booking_status = 'Checked Out';

-- 16. Realization Percentage (Checked Out / [Checked Out + No Show])
SELECT 
    (SELECT COUNT(*) FROM fact_bookings WHERE booking_status = 'Checked Out') * 100.0 /
    (SELECT COUNT(*) FROM fact_bookings WHERE booking_status IN ('Checked Out', 'No Show')) AS Realization_Percentage;

-- 17. Revenue Per Available Room (RevPAR)
SELECT SUM(fb.revenue_realized) / SUM(fab.capacity) AS RevPAR
FROM fact_bookings fb
JOIN fact_aggregated_bookings fab ON fb.property_id = fab.property_id;

-- 18. Daily Booked Room Nights (DBRN)
SELECT SUM(successful_bookings) / DATEDIFF(MAX(check_in_date), MIN(check_in_date)) AS DBRN
FROM fact_aggregated_bookings;

-- 19. Daily Sellable Room Nights (DSRN)
SELECT SUM(capacity) / DATEDIFF(MAX(check_in_date), MIN(check_in_date)) AS DSRN
FROM fact_aggregated_bookings;

-- 20. Daily Utilized Room Nights (DURN)
SELECT SUM(successful_bookings) / DATEDIFF(MAX(check_out_date), MIN(check_in_date)) AS DURN
FROM fact_bookings;

-- Additional: Cancellation Reason Breakdown
SELECT cancellation_reason, COUNT(*) AS Count
FROM fact_bookings
WHERE booking_status = 'Cancelled'
GROUP BY cancellation_reason
ORDER BY Count DESC;


-- Additional: Weekend vs Weekday Revenue
SELECT CASE 
           WHEN DAYOFWEEK(check_in_date) IN (1, 7) THEN 'Weekend'
           ELSE 'Weekday'
       END AS Day_Type,
       COUNT(*) AS Bookings,
       SUM(revenue_realized) AS Revenue
FROM fact_bookings
GROUP BY Day_Type;

-- Additional: Underperforming Hotels
SELECT property_id, SUM(successful_bookings) / SUM(capacity) * 100 AS Occupancy_Rate
FROM fact_aggregated_bookings
GROUP BY property_id
HAVING Occupancy_Rate < 50;
