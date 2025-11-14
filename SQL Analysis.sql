-- Analysis Questions

# Q1. How many total customers are there, and how many have churned?
SELECT COUNT(*) AS total_customers,SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers FROM telecom_customer;

# Q2. What is the overall churn rate (%)?
SELECT ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent FROM telecom_customer;

# Q3. What is the average monthly charge and total revenue generated?
SELECT ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge,ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue FROM telecom_customer;

# Q4. What is the churn rate by gender?
SELECT gender,COUNT(*) AS total_customers,SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY gender;

# Q5. What is the churn rate across different contract types?
SELECT Contract,COUNT(*) AS total_customers,SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY Contract ORDER BY churn_rate_percent DESC;

# Q6. Which payment methods have the highest churn?
SELECT PaymentMethod,ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY PaymentMethod ORDER BY churn_rate_percent DESC;

# Q7. What is the churn rate by internet service type?
SELECT InternetService,ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY InternetService ORDER BY churn_rate_percent DESC;

# Q8. What is the average tenure for churned vs. retained customers?
SELECT Churn,ROUND(AVG(tenure), 1) AS avg_tenure FROM telecom_customer GROUP BY Churn;

# Q9. How does churn vary with tenure groups?
SELECT 
CASE 
	WHEN tenure BETWEEN 0 AND 12 THEN '0–12 months'
	WHEN tenure BETWEEN 13 AND 24 THEN '13–24 months'
	WHEN tenure BETWEEN 25 AND 48 THEN '25–48 months'
	ELSE '49+ months'
END AS tenure_group,COUNT(*) AS total_customers,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY tenure_group ORDER BY tenure_group;

# Q10. Which demographic segments show higher churn?
SELECT SeniorCitizen,Partner,Dependents,
ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY SeniorCitizen, Partner, Dependents ORDER BY churn_rate_percent DESC;

# Q11. What is the average monthly charge for churned vs. retained customers?
SELECT Churn,ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge FROM telecom_customer GROUP BY Churn;

# Q12. Which combination of contract type and payment method has the highest churn?
SELECT Contract,PaymentMethod,ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY Contract, PaymentMethod ORDER BY churn_rate_percent DESC;

# Q13. Who are the top 10 high-value churned customers by total charges?
SELECT customerID,TotalCharges,MonthlyCharges,tenure FROM telecom_customer WHERE Churn = 'Yes' ORDER BY TotalCharges DESC LIMIT 10;

# Q14. Customer Retention Summary (KPI Dashboard)
SELECT Contract,ROUND(AVG(tenure), 1) AS avg_tenure,ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charge,
ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM telecom_customer GROUP BY Contract ORDER BY churn_rate_percent DESC;

# Q15.Identify customers paying above average charges who churned
SELECT customerID, MonthlyCharges, Churn FROM telecom_customer WHERE Churn='Yes' AND MonthlyCharges 
> (SELECT AVG(MonthlyCharges) FROM telecom_customer) LIMIT 10;
  
# Q16.Use CTE to build a summary view showing churn %, avg tenure, avg total charges by Contract type
WITH contract_summary AS (
    SELECT 
        Contract,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
        AVG(tenure) AS avg_tenure,
        AVG(TotalCharges) AS avg_total_charges
    FROM telecom_customer
    GROUP BY Contract
)
SELECT 
    Contract,
    ROUND(churned_customers*100.0/total_customers,2) AS churn_rate_percent,
    ROUND(avg_tenure,2) AS avg_tenure,
    ROUND(avg_total_charges,2) AS avg_total_charges
FROM contract_summary;

# Q17.Percentage contribution of each Contract type to total churn
WITH total_churn AS (
    SELECT COUNT(*) AS total_churned
    FROM telecom_customer
    WHERE Churn='Yes'
)
SELECT 
    Contract,
    COUNT(*) AS churn_count,
    ROUND(COUNT(*)*100.0/(SELECT total_churned FROM total_churn),2) AS churn_percent_contribution
FROM telecom_customer
WHERE Churn='Yes'
GROUP BY Contract
ORDER BY churn_percent_contribution DESC;