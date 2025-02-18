-- Renal Disease:
-- Q1. List the drug names of the class of drugs for first-line treatment of CKD, diabetes, or HTN if albuminuria is present.

WITH drug AS (
SELECT rc.str AS drug_name, rc.code AS atc_code
FROM rxnconso rc
JOIN 
rxnsat rs
ON rc.code = rs.code
WHERE rc.code LIKE ANY(ARRAY['C09A%','C09C%'])   --ATC codes for ACEi and ARB respectively
AND rs.atn = 'ATC_LEVEL'
AND rs.atv = '5'
),
atc AS (
SELECT rc.code AS atc_code, rc.str AS atc_class
FROM rxnconso rc
JOIN
rxnsat rs
ON rs.code = rc.code
WHERE rc.code LIKE ANY(ARRAY['C09A%','C09C%'])   --ATC codes for ACEi and ARB respectively
AND rs.atn = 'ATC_LEVEL'
AND rs.atv = '4'
)
SELECT drug.*, atc.atc_class
FROM drug
LEFT JOIN atc
ON LEFT(drug.atc_code, 5) = atc.atc_code
ORDER BY drug.atc_code
;


-- Blood:
-- Q1. Which drug classes are blood thinners?
-- 1st Option:
SELECT code as drug_class_code, str as drug_class_name
FROM rxnconso
WHERE code LIKE 'B01A_'  -- ATC code for antithrombotic agents
ORDER BY drug_class_code;
-- 2nd Option:
SELECT rc.code as drug_class_code, rc.str as drug_class_name
FROM rxnconso rc
JOIN rxnsat rs
ON rc.rxcui = rs.rxcui
WHERE rc.code LIKE 'B01%'  -- ATC code for antithrombotic agents
AND rs.atn = 'ATC_LEVEL'
AND rs.atv = '4'
ORDER BY drug_class_code;

--Q2. List NDCs of the drug that requires consistent dietary vitamin K?
SELECT rc.str as drug_name
	, rs.atv as ndc
FROM rxnconso rc
JOIN
rxnsat rs
ON rc.rxcui = rs.rxcui
WHERE rc.str ILIKE 'warfarin%'
AND rs.atn = 'NDC'
AND rs.sab = 'RXNORM'
AND rc.tty = 'SCD'
ORDER BY drug_name;

--Q3. List RXCUI and NDC for one drug that should be administered if a patient develops heparin-induced thrombocytopenia.
SELECT rs.rxcui, rs.atv as ndc, rc.str as drug_name
FROM rxnsat rs
JOIN
rxnconso rc
ON rs.rxcui = rc.rxcui
WHERE rs.atn = 'NDC'
AND rc.sab = 'RXNORM'
AND rs.sab = 'RXNORM'
AND rc.str ILIKE '%argatroban%'
AND rc.tty = 'SCD'
ORDER BY rs.rxcui, ndc
;


--Cardiovascular
--Q1. Select drugs that are in the angiotensin II converting enzyme inhibitor (ACEi) class.
SELECT str as drug_name
	, code as atc_code
	, (select str
	   FROM rxnconso
	   WHERE code = 'C09A') AS drug_class_name
FROM rxnconso
WHERE code like 'C09A___'
ORDER BY atc_code;

--Q2. What are the hyperlipidemia drugs that can cause muscle damage, including rhabdomyolysis?
SELECT DISTINCT str AS drug_name
FROM rxnconso
WHERE str LIKE '%statin'
AND code LIKE 'C10AA__';


-- Neuro & Psych:
--Q1. Select antianxiolytics.
SELECT DISTINCT rs.rxcui
	, rc.str
FROM rxnsat rs
JOIN
rxnconso rc
ON rs.rxcui = rc.rxcui
WHERE atn = 'ATC_LEVEL'
AND atv = '5'
AND rs.code LIKE 'N05BA%'  -- Code for antianxiolytics
AND rc.tty = 'IN'
;