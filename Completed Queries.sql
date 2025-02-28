-- Select database
SET search_path TO rxnorm;

-- Renal Disease:
-- Q1. List the drug names of the class of drugs for first-line treatment of CKD, diabetes, or HTN if albuminuria is present.
SELECT rc1.str AS drug_name
	, rc1.code AS atc_code
	, rc2.str AS atc_class
FROM rxnconso rc1
LEFT JOIN rxnconso rc2
ON LEFT(rc1.code, 5) = rc2.code
JOIN rxnsat rs1
ON rc1.code = rs1.code
WHERE rc1.code LIKE ANY(ARRAY['C09A%','C09C%'])   --ATC codes for ACEi and ARB respectively
	AND rs1.atn = 'ATC_LEVEL'
	AND rs1.atv = '5'
ORDER BY atc_code
;


-- Blood:
-- Q1. Which drug classes are blood thinners?
SELECT rc.code as drug_class_code, MIN(rc.str) as drug_class_name
FROM rxnconso rc
INNER JOIN rxnsat rs
ON rc.rxcui = rs.rxcui
WHERE rc.code LIKE 'B01%'  -- ATC group code for antithrombotic agents
	AND rs.atn = 'ATC_LEVEL'
	AND rs.atv = '4'	    -- Select for pharmacological or therapeutic subgroups
GROUP BY 1
ORDER BY 1;

--Q2. List NDCs of the drug that requires consistent dietary vitamin K?
SELECT rc.str as drug_name, rs.atv as ndc
FROM rxnconso rc
JOIN
rxnsat rs
ON rc.rxcui = rs.rxcui
WHERE rc.str ILIKE 'warfarin%'
	AND rs.atn = 'NDC'
	AND rs.sab = 'RXNORM' 	--Normalized NDCs
	AND rc.tty = 'SCD'    	--Name, strength, and form
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

--Q3. What are the different brand names for the generic medication clopidogrel?
WITH rxcuis AS (
	SELECT DISTINCT rc.rxcui AS generic_rxcui
		, rc.str AS generic_name
		, rr.rxcui2 AS brand_rxcui
	FROM rxnconso rc
	INNER JOIN rxnrel rr
	ON rc.rxcui = rr.rxcui1
	WHERE rc.str LIKE 'clopidogrel'
	AND rr.rela = 'tradename_of'
	)
SELECT DISTINCT rc.str AS brand_name
FROM rxcuis
INNER JOIN rxnconso rc
ON rxcuis.brand_rxcui = rc.rxcui
;


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


-- General questions:
-- Q1. Find the salt forms of ephedrine.
SELECT rxcui, str AS drug_name
FROM rxnconso
WHERE str ILIKE 'ephedrine%'
AND tty = 'PIN'   -- Specify for salt or isomer forms
;