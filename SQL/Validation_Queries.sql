Select *
from [New Healthcare]

Select count (*) As Count
from [New Healthcare]

Select count (*) As Counts, appointment_id
from [New Healthcare]
group by appointment_id
Having count (*) > 1

SELECT 
    YEAR(App_Date) AS Year,
    DATENAME(MONTH, App_Date) AS Month_Name,
    MONTH(App_Date) AS Month_Number,
    COUNT(appointment_id) AS Total_Appointments,
    SUM(CASE WHEN Appointment_Status = 'No-show' 
        THEN 1 ELSE 0 END) AS No_Shows,
    SUM(CASE WHEN Billing_Amount > 0 
        THEN Billing_Amount ELSE 0 END) AS Total_Revenue
FROM [New healthcare]
WHERE App_Date IS NOT NULL
GROUP BY 
    YEAR(App_Date),
    MONTH(App_Date),
    DATENAME(MONTH, App_Date)
ORDER BY Year, MONTH(App_Date)


