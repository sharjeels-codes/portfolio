SELECT 
  "CoCode", 
  "Date", 
  CAST (
    CAST ("GLAccount" AS INT) AS TEXT
  ) AS "GLAccount", 
  SUM("MonthlyBalance") AS "MonthlyBal", 
  SUM ("MonthlyBal") OVER (
    PARTITION BY "CoCode", 
    "GLAccount" 
    ORDER BY 
      "Date" ROWS UNBOUNDED PRECEDING
  ) AS "RunningTotal" 
FROM 
  (
    SELECT 
      "Company Code" AS "CoCode", 
      DATE_TRUNC(
        'MONTH', 
        DATE_FROM_PARTS(
          LEFT("Fiscal year period", 4), 
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  RIGHT("Fiscal year period", 2), 
                  '13', 
                  '12'
                ), 
                '14', 
                '12'
              ), 
              '15', 
              '12'
            ), 
            '16', 
            '12'
          ), 
          1
        )
      ) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS "Date", 
      "G/L Account Number" AS "GLAccount", 
      "Total Debit Postings" - "Total Credit Postings" AS "MonthlyBalance" 
    FROM 
      PRD_DATALAKE.MPC_PRD.FI_AGG_MPC
  ) 
GROUP BY 
  "CoCode", 
  "GLAccount", 
  "Date" 
ORDER BY 
  "Date" ASC
