--add table CONCEPT

CREATE TABLE CONCEPT
(
  CONCEPT_ID        INTEGER                     NOT NULL,
  CONCEPT_NAME      VARCHAR2(256 BYTE)          NOT NULL,
  CONCEPT_LEVEL     NUMBER                      NOT NULL,
  CONCEPT_CLASS     VARCHAR2(60 BYTE)           NOT NULL,
  VOCABULARY_ID     INTEGER                     NOT NULL,
  CONCEPT_CODE      VARCHAR2(40 BYTE)           NOT NULL,
  VALID_START_DATE  DATE                        NOT NULL,
  VALID_END_DATE    DATE                        DEFAULT '31-Dec-2099'         NOT NULL,
  INVALID_REASON    CHAR(1 BYTE)
) NOLOGGING;
COMMENT ON TABLE CONCEPT IS 'A list of all valid terminology concepts across domains and their attributes. Concepts are derived from existing standards.';

COMMENT ON COLUMN CONCEPT.CONCEPT_ID IS 'A system-generated identifier to uniquely identify each concept across all concept types.';

COMMENT ON COLUMN CONCEPT.CONCEPT_NAME IS 'An unambiguous, meaningful and descriptive name for the concept.';

COMMENT ON COLUMN CONCEPT.CONCEPT_LEVEL IS 'The level of hierarchy associated with the concept. Different concept levels are assigned to concepts to depict their seniority in a clearly defined hierarchy, such as drugs, conditions, etc. A concept level of 0 is assigned to concepts that are not part of a standard vocabulary, but are part of the vocabulary for reference purposes (e.g. drug form).';

COMMENT ON COLUMN CONCEPT.CONCEPT_CLASS IS 'The category or class of the concept along both the hierarchical tree as well as different domains within a vocabulary. Examples are ''Clinical Drug'', ''Ingredient'', ''Clinical Finding'' etc.';

COMMENT ON COLUMN CONCEPT.VOCABULARY_ID IS 'A foreign key to the vocabulary table indicating from which source the concept has been adapted.';

COMMENT ON COLUMN CONCEPT.CONCEPT_CODE IS 'The concept code represents the identifier of the concept in the source data it originates from, such as SNOMED-CT concept IDs, RxNorm RXCUIs etc. Note that concept codes are not unique across vocabularies.';

COMMENT ON COLUMN CONCEPT.VALID_START_DATE IS 'The date when the was first recorded.';

COMMENT ON COLUMN CONCEPT.VALID_END_DATE IS 'The date when the concept became invalid because it was deleted or superseded (updated) by a new concept. The default value is 31-Dec-2099.';

COMMENT ON COLUMN CONCEPT.INVALID_REASON IS 'Concepts that are replaced with a new concept are designated "Updated" (U) and concepts that are removed without replacement are "Deprecated" (D).';

CREATE INDEX CONCEPT_CODE ON CONCEPT (CONCEPT_CODE, VOCABULARY_ID);
CREATE UNIQUE INDEX XPKCONCEPT ON CONCEPT (CONCEPT_ID);

ALTER TABLE CONCEPT ADD (
  CHECK ( invalid_reason IN ('D', 'U'))
  ENABLE VALIDATE,
  CONSTRAINT XPKCONCEPT
  PRIMARY KEY
  (CONCEPT_ID)
  USING INDEX XPKCONCEPT
  ENABLE VALIDATE);
  
--add table RELATIONSHIP

CREATE TABLE RELATIONSHIP
(
  RELATIONSHIP_ID       INTEGER                 NOT NULL,
  RELATIONSHIP_NAME     VARCHAR2(256 BYTE)      NOT NULL,
  IS_HIERARCHICAL       INTEGER                 NOT NULL,
  DEFINES_ANCESTRY      INTEGER                 DEFAULT 1                     NOT NULL,
  REVERSE_RELATIONSHIP  INTEGER
) NOLOGGING;

COMMENT ON TABLE RELATIONSHIP IS 'A list of relationship between concepts. Some of these relationships are generic (e.g. "Subsumes" relationship), others are domain-specific.';

COMMENT ON COLUMN RELATIONSHIP.RELATIONSHIP_ID IS 'The type of relationship captured by the relationship record.';

COMMENT ON COLUMN RELATIONSHIP.RELATIONSHIP_NAME IS 'The text that describes the relationship type.';

COMMENT ON COLUMN RELATIONSHIP.IS_HIERARCHICAL IS 'Defines whether a relationship defines concepts into classes or hierarchies. Values are Y for hierarchical relationship or NULL if not';

COMMENT ON COLUMN RELATIONSHIP.DEFINES_ANCESTRY IS 'Defines whether a hierarchical relationship contributes to the concept_ancestor table. These are subsets of the hierarchical relationships. Valid values are Y or NULL.';

COMMENT ON COLUMN RELATIONSHIP.REVERSE_RELATIONSHIP IS 'Relationship ID of the reverse relationship to this one. Corresponding records of reverse relationships have their concept_id_1 and concept_id_2 swapped.';

CREATE UNIQUE INDEX XPKRELATIONSHIP_TYPE ON RELATIONSHIP
(RELATIONSHIP_ID);

ALTER TABLE RELATIONSHIP ADD (
  CONSTRAINT XPKRELATIONSHIP_TYPE
  PRIMARY KEY
  (RELATIONSHIP_ID)
  USING INDEX XPKRELATIONSHIP_TYPE
  ENABLE VALIDATE);

--add table CONCEPT_RELATIONSHIP
  
CREATE TABLE CONCEPT_RELATIONSHIP
(
  CONCEPT_ID_1      INTEGER                     NOT NULL,
  CONCEPT_ID_2      INTEGER                     NOT NULL,
  RELATIONSHIP_ID   INTEGER                     NOT NULL,
  VALID_START_DATE  DATE                        NOT NULL,
  VALID_END_DATE    DATE                        DEFAULT '31-Dec-2099'         NOT NULL,
  INVALID_REASON    CHAR(1 BYTE)
) NOLOGGING;

COMMENT ON TABLE CONCEPT_RELATIONSHIP IS 'A list of relationship between concepts. Some of these relationships are generic (e.g. ''Subsumes'' relationship), others are domain-specific.';

COMMENT ON COLUMN CONCEPT_RELATIONSHIP.CONCEPT_ID_1 IS 'A foreign key to the concept in the concept table associated with the relationship. Relationships are directional, and this field represents the source concept designation.';

COMMENT ON COLUMN CONCEPT_RELATIONSHIP.CONCEPT_ID_2 IS 'A foreign key to the concept in the concept table associated with the relationship. Relationships are directional, and this field represents the destination concept designation.';

COMMENT ON COLUMN CONCEPT_RELATIONSHIP.RELATIONSHIP_ID IS 'The type of relationship as defined in the relationship table.';

COMMENT ON COLUMN CONCEPT_RELATIONSHIP.VALID_START_DATE IS 'The date when the the relationship was first recorded.';

COMMENT ON COLUMN CONCEPT_RELATIONSHIP.VALID_END_DATE IS 'The date when the relationship became invalid because it was deleted or superseded (updated) by a new relationship. Default value is 31-Dec-2099.';

COMMENT ON COLUMN CONCEPT_RELATIONSHIP.INVALID_REASON IS 'Reason the relationship was invalidated. Possible values are D (deleted), U (replaced with an update) or NULL when valid_end_date has the default  value.';

CREATE UNIQUE INDEX XPKCONCEPT_RELATIONSHIP ON CONCEPT_RELATIONSHIP
(CONCEPT_ID_1, CONCEPT_ID_2, RELATIONSHIP_ID); 


ALTER TABLE CONCEPT_RELATIONSHIP ADD (
  CHECK ( invalid_reason IN ('D', 'U'))
  ENABLE VALIDATE,
  CHECK ( invalid_reason IN ('D', 'U'))
  ENABLE VALIDATE,
  CHECK (invalid_reason in ('D', 'U'))
  ENABLE VALIDATE,
  CONSTRAINT XPKCONCEPT_RELATIONSHIP
  PRIMARY KEY
  (CONCEPT_ID_1, CONCEPT_ID_2, RELATIONSHIP_ID)
  USING INDEX XPKCONCEPT_RELATIONSHIP
  ENABLE VALIDATE);

 
ALTER TABLE CONCEPT_RELATIONSHIP ADD (
  CONSTRAINT CONCEPT_REL_CHILD_FK 
  FOREIGN KEY (CONCEPT_ID_2) 
  REFERENCES CONCEPT (CONCEPT_ID)
  ENABLE VALIDATE,
  CONSTRAINT CONCEPT_REL_PARENT_FK 
  FOREIGN KEY (CONCEPT_ID_1) 
  REFERENCES CONCEPT (CONCEPT_ID)
  ENABLE VALIDATE,
  CONSTRAINT CONCEPT_REL_REL_TYPE_FK 
  FOREIGN KEY (RELATIONSHIP_ID) 
  REFERENCES RELATIONSHIP (RELATIONSHIP_ID)
  ENABLE VALIDATE);

--add table CONCEPT_ANCESTOR

CREATE TABLE CONCEPT_ANCESTOR
(
  ANCESTOR_CONCEPT_ID       INTEGER             NOT NULL,
  DESCENDANT_CONCEPT_ID     INTEGER             NOT NULL,
  MAX_LEVELS_OF_SEPARATION  NUMBER,
  MIN_LEVELS_OF_SEPARATION  NUMBER
) NOLOGGING;  

COMMENT ON TABLE CONCEPT_ANCESTOR IS 'A specialized table containing only hierarchical relationship between concepts that may span several generations.';

COMMENT ON COLUMN CONCEPT_ANCESTOR.ANCESTOR_CONCEPT_ID IS 'A foreign key to the concept code in the concept table for the higher-level concept that forms the ancestor in the relationship.';

COMMENT ON COLUMN CONCEPT_ANCESTOR.DESCENDANT_CONCEPT_ID IS 'A foreign key to the concept code in the concept table for the lower-level concept that forms the descendant in the relationship.';

COMMENT ON COLUMN CONCEPT_ANCESTOR.MAX_LEVELS_OF_SEPARATION IS 'The maximum separation in number of levels of hierarchy between ancestor and descendant concepts. This is an optional attribute that is used to simplify hierarchic analysis. ';

COMMENT ON COLUMN CONCEPT_ANCESTOR.MIN_LEVELS_OF_SEPARATION IS 'The minimum separation in number of levels of hierarchy between ancestor and descendant concepts. This is an optional attribute that is used to simplify hierarchic analysis.';

CREATE UNIQUE INDEX XPKCONCEPT_ANCESTOR ON CONCEPT_ANCESTOR
(ANCESTOR_CONCEPT_ID, DESCENDANT_CONCEPT_ID);

ALTER TABLE CONCEPT_ANCESTOR ADD (
  CONSTRAINT XPKCONCEPT_ANCESTOR
  PRIMARY KEY
  (ANCESTOR_CONCEPT_ID, DESCENDANT_CONCEPT_ID)
  USING INDEX XPKCONCEPT_ANCESTOR
  ENABLE VALIDATE);

ALTER TABLE CONCEPT_ANCESTOR ADD (
  CONSTRAINT CONCEPT_ANCESTOR_FK 
  FOREIGN KEY (ANCESTOR_CONCEPT_ID) 
  REFERENCES CONCEPT (CONCEPT_ID)
  ENABLE VALIDATE,
  CONSTRAINT CONCEPT_DESCENDANT_FK 
  FOREIGN KEY (DESCENDANT_CONCEPT_ID) 
  REFERENCES CONCEPT (CONCEPT_ID)
  ENABLE VALIDATE);

--add table CONCEPT_SYNONYM

CREATE TABLE CONCEPT_SYNONYM
(
  CONCEPT_SYNONYM_ID    INTEGER                 NOT NULL,
  CONCEPT_ID            INTEGER                 NOT NULL,
  CONCEPT_SYNONYM_NAME  VARCHAR2(1000 BYTE)     NOT NULL
) NOLOGGING;

COMMENT ON TABLE CONCEPT_SYNONYM IS 'A table with synonyms for concepts that have more than one valid name or description.';

COMMENT ON COLUMN CONCEPT_SYNONYM.CONCEPT_SYNONYM_ID IS 'A system-generated unique identifier for each concept synonym.';

COMMENT ON COLUMN CONCEPT_SYNONYM.CONCEPT_ID IS 'A foreign key to the concept in the concept table. ';

COMMENT ON COLUMN CONCEPT_SYNONYM.CONCEPT_SYNONYM_NAME IS 'The alternative name for the concept.';

CREATE UNIQUE INDEX XPKCONCEPT_SYNONYM ON CONCEPT_SYNONYM
(CONCEPT_SYNONYM_ID);

ALTER TABLE CONCEPT_SYNONYM ADD (
  CONSTRAINT XPKCONCEPT_SYNONYM
  PRIMARY KEY
  (CONCEPT_SYNONYM_ID)
  USING INDEX XPKCONCEPT_SYNONYM
  ENABLE VALIDATE);

ALTER TABLE CONCEPT_SYNONYM ADD (
  CONSTRAINT CONCEPT_SYNONYM_CONCEPT_FK 
  FOREIGN KEY (CONCEPT_ID) 
  REFERENCES CONCEPT (CONCEPT_ID)
  ENABLE VALIDATE);

--add table SOURCE_TO_CONCEPT_MAP

CREATE TABLE SOURCE_TO_CONCEPT_MAP
(
  SOURCE_CODE              VARCHAR2(40 BYTE)    NOT NULL,
  SOURCE_VOCABULARY_ID     INTEGER              NOT NULL,
  SOURCE_CODE_DESCRIPTION  VARCHAR2(256 BYTE),
  TARGET_CONCEPT_ID        INTEGER              NOT NULL,
  TARGET_VOCABULARY_ID     INTEGER              NOT NULL,
  MAPPING_TYPE             VARCHAR2(256 BYTE),
  PRIMARY_MAP              CHAR(1 BYTE),
  VALID_START_DATE         DATE                 NOT NULL,
  VALID_END_DATE           DATE                 NOT NULL,
  INVALID_REASON           CHAR(1 BYTE)
) NOLOGGING;

CREATE INDEX SOURCE_TO_CONCEPT_SOURCE_IDX ON SOURCE_TO_CONCEPT_MAP
(SOURCE_CODE);

CREATE UNIQUE INDEX XPKSOURCE_TO_CONCEPT_MAP ON SOURCE_TO_CONCEPT_MAP
(SOURCE_VOCABULARY_ID, TARGET_CONCEPT_ID, SOURCE_CODE, VALID_END_DATE);

ALTER TABLE SOURCE_TO_CONCEPT_MAP ADD (
  CHECK (primary_map in ('Y'))
  ENABLE VALIDATE,
  CHECK (invalid_reason in ('D', 'U'))
  ENABLE VALIDATE,
  CONSTRAINT XPKSOURCE_TO_CONCEPT_MAP
  PRIMARY KEY
  (SOURCE_VOCABULARY_ID, TARGET_CONCEPT_ID, SOURCE_CODE, VALID_END_DATE)
  USING INDEX XPKSOURCE_TO_CONCEPT_MAP
  ENABLE VALIDATE);

ALTER TABLE SOURCE_TO_CONCEPT_MAP ADD (
  CONSTRAINT SOURCE_TO_CONCEPT_CONCEPT 
  FOREIGN KEY (TARGET_CONCEPT_ID) 
  REFERENCES CONCEPT (CONCEPT_ID)
  ENABLE VALIDATE);

--fill tables

INSERT INTO devv5.relationship_conversion (relationship_id,
                                           relationship_id_new)
   SELECT   ROWNUM
          + (SELECT MAX (relationship_id)
               FROM devv5.relationship_conversion)
             AS rn,
          relationship_id
     FROM ( (SELECT relationship_id FROM devv5.relationship
             UNION ALL
             SELECT reverse_relationship_id FROM devv5.relationship)
           MINUS
           SELECT relationship_id_new FROM devv5.relationship_conversion);
COMMIT;

CREATE TABLE t_concept_class_conversion

AS
   (SELECT concept_class, concept_class_id_new
      FROM devv5.concept_class_conversion
     WHERE concept_class_id_new NOT IN (  SELECT concept_class_id_new
                                            FROM devv5.concept_class_conversion
                                        GROUP BY concept_class_id_new
                                          HAVING COUNT (*) > 1))
   UNION ALL
   (  SELECT concept_class_id_new AS concept_class, concept_class_id_new
        FROM devv5.concept_class_conversion
    GROUP BY concept_class_id_new
      HAVING COUNT (*) > 1)
   UNION ALL
   (SELECT concept_class_id AS concept_class,
           concept_class_id AS concept_class_id_new
      FROM devv5.concept
    MINUS
    SELECT concept_class_id_new, concept_class_id_new
      FROM devv5.concept_class_conversion);
		   
 INSERT INTO RELATIONSHIP (RELATIONSHIP_ID,
                          RELATIONSHIP_NAME,
                          IS_HIERARCHICAL,
                          DEFINES_ANCESTRY,
                          REVERSE_RELATIONSHIP)
   SELECT rc.relationship_id,
          r.relationship_name,
          r.is_hierarchical,
          r.defines_ancestry,
          rc_rev.relationship_id
     FROM devv5.relationship r,
          devv5.relationship_conversion rc,
          devv5.relationship_conversion rc_rev
    WHERE     r.relationship_id = rc.relationship_id_new
          AND r.reverse_relationship_id = rc_rev.relationship_id_new;
COMMIT;

INSERT /*+ APPEND */
      INTO  concept (CONCEPT_ID,
                     CONCEPT_NAME,
                     CONCEPT_LEVEL,
                     CONCEPT_CLASS,
                     VOCABULARY_ID,
                     CONCEPT_CODE,
                     VALID_START_DATE,
                     VALID_END_DATE,
                     INVALID_REASON)

select distinct
  c.concept_id, c.concept_name,
  case c.vocabulary_id 
    when 'SNOMED' then -- full hierarchy
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when c.descendant_concept_id is null then 1 -- if it has no children then leaf
            when p.ancestor_concept_id is null then 3 -- if it has no parents then top guy
            else 2 -- in the middle
          end
      end
    when 'ICD9CM' then 0 -- all source
    when 'ICD9Proc' then  -- hierarchy, but no top guys
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when c.descendant_concept_id is null then 1 -- if it has no children then leaf
            else 2 -- in the middle
          end
      end
    when 'CPT4' then -- full hierarchy
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when c.descendant_concept_id is null then 1 -- if it has no children then leaf
            when p.ancestor_concept_id is null then 3 -- if it has no parents then top guy
            else 2 -- in the middle
          end
      end
    when 'LOINC' then -- full hierarchy
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when c.descendant_concept_id is null then 1 -- if it has no children then leaf
            when p.ancestor_concept_id is null then 3 -- if it has no parents then top guy
            else 2 -- in the middle
          end
      end
    when 'NDFRT' then -- full hierarchy
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when p.ancestor_concept_id is null then 4 -- if it has no parents then top guy
            else 3 -- in the middle
          end
      end
    when 'RxNorm' then -- specialized hierarchy
      case 
        when c.standard_concept is null then 0
        else
          case concept_class_id
            when 'Ingredient' then 2
            when 'Clinical Drug' then 1
            when 'Branded Drug' then 1
            when 'Clinical Pack' then 1
            when 'Branded Pack' then 1
            else 0
          end
      end
    when 'NDC' then 0
    when 'GPI' then 0
    when 'Race' then -- 2 level hierarchy
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when c.descendant_concept_id is null then 1 -- if it has no children then leaf
            else 2 -- on top
          end
      end
    when 'MedDRA' then -- specialized hierarchy
      case 
        when c.standard_concept is null then 0
        else
          case concept_class_id
            when 'LLT' then 1
            when 'PT' then 2
            when 'HLT' then 3
            when 'HLGT' then 4
            when 'SOC' then 5
          end
      end
    when 'Multum' then 0
    when 'Read' then 0
    when 'OXMIS' then 0
    when 'Indication' then 
      case 
        when c.standard_concept is null then 0
        else 3 -- Drug hierarchy on top of Ingredient (level 2)
      end
    when 'ETC' then
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when p.ancestor_concept_id is null then 4 -- if it has no parents then top guy
            else 3 -- in the middle
          end
      end
    when 'ATC' then 
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when p.ancestor_concept_id is null then 4 -- if it has no parents then top guy
            else 3 -- in the middle
          end
      end
    when 'Multilex' then 
      case 
        when c.standard_concept is null then 0
        else
          case concept_class_id
            when 'Ingredient' then 2
            when 'Clinical Drug' then 1
            when 'Branded Drug' then 1
            when 'Clinical Pack' then 1
            when 'Branded Pack' then 1
            else 0
          end
      end
    when 'Visit' then -- flat list
      case 
        when c.standard_concept is null then 0
        else 2 -- on top of place of service
      end
    when 'SMQ' then
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when c.descendant_concept_id is null then 1 -- if it has no children then leaf
            when p.ancestor_concept_id is null then 3 -- if it has no parents then top guy
            else 2 -- in the middle
          end
      end
    when 'VA Class' then 
      case 
        when c.standard_concept is null then 0
        else 
          case 
            when p.ancestor_concept_id is null then 4 -- if it has no parents then top guy
            else 3 -- in the middle
          end
      end
    when 'Cohort' then 0
    when 'ICD10' then 0
    when 'ICD10PCS' then 0
    when 'MDC' then 
      case 
        when c.standard_concept is null then 0
        else 2 -- on top of DRG (level 1)
      end
    when 'Mesh' then 0
    when 'Specialty' then
      case 
        when c.standard_concept is null then 0
        else 2 -- on top of DRG (level 1)
      end
    when 'SPL' then
      case 
        when c.standard_concept is null then 0
        else 3 -- on top of Ingredient (level 2)
      end
    when 'Genseqno' then 0
    when 'CCS' then 0
    when 'OPCS4' then 0
    when 'Gemscript' then 0
    when 'HES Specialty' then 0
    when 'PCORNet' then 0
    when 'ICD10CM' then 0
    else -- flat list
      case
        when c.standard_concept is null then 0
        else 1
      end
  end as concept_level,
  ccc.concept_class,
          vc.vocabulary_id_v4,
          c.concept_code,
          c.valid_start_date,
          c.valid_end_date,
          c.invalid_reason
from devv5.concept c
join t_concept_class_conversion ccc on ccc.concept_class_id_new = c.concept_class_id
join devv5.vocabulary_conversion vc on vc.vocabulary_id_v5 = c.vocabulary_id
left join devv5.concept_ancestor p on p.descendant_concept_id = c.concept_id and p.ancestor_concept_id!=p.descendant_concept_id -- get parents
left join devv5.concept_ancestor c on c.ancestor_concept_id = c.concept_id and c.ancestor_concept_id!=c.descendant_concept_id -- get children
WHERE EXISTS (SELECT 1
                    FROM devv5.concept c_int
                   WHERE     c_int.vocabulary_id = c.vocabulary_id
                         AND standard_concept = 'S')  -- where there is at least one standard concept in the same vocabulary
OR c.concept_code in ('OMOP generated','No matching concept');
COMMIT;	

DROP TABLE t_concept_class_conversion PURGE;	  

INSERT /*+ APPEND */
      INTO  concept_relationship (CONCEPT_ID_1,
                                  CONCEPT_ID_2,
                                  RELATIONSHIP_ID,
                                  VALID_START_DATE,
                                  VALID_END_DATE,
                                  INVALID_REASON)
   SELECT r.concept_id_1,
          r.concept_id_2,
          rc.relationship_id AS relationship_id,
          r.valid_start_date,
          r.valid_end_date,
          r.invalid_reason
     FROM devv5.concept_relationship r, devv5.relationship_conversion rc
    WHERE     r.relationship_id = rc.relationship_id_new
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = r.concept_id_1)
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = r.concept_id_2);
COMMIT;	




INSERT /*+ APPEND */
      INTO  concept_relationship (CONCEPT_ID_1,
                                  CONCEPT_ID_2,
                                  RELATIONSHIP_ID,
                                  VALID_START_DATE,
                                  VALID_END_DATE,
                                  INVALID_REASON)
   SELECT c.concept_id AS concept_id_1,
          d.domain_concept_id AS concept_id_2,
          360 AS relationship_id,                                  --Is domain
          TO_DATE ('19700101', 'yyyymmdd') AS valid_start_date,
          TO_DATE ('20991231', 'yyyymmdd') AS valid_end_date,
          NULL AS invalid_reason
     FROM devv5.concept c, devv5.domain d
    WHERE     c.domain_id = d.domain_id
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = c.concept_id)
          AND NOT EXISTS
                 (SELECT 1
                    FROM concept_relationship r_int
                   WHERE     r_int.concept_id_1 = c.concept_id
                         AND r_int.concept_id_2 = d.domain_concept_id
                         AND relationship_id = 360)
   UNION ALL
   SELECT d.domain_concept_id AS concept_id_1,
          c.concept_id AS concept_id_2,
          359 AS relationship_id,                            --Domain subsumes
          TO_DATE ('19700101', 'yyyymmdd') AS valid_start_date,
          TO_DATE ('20991231', 'yyyymmdd') AS valid_end_date,
          NULL AS invalid_reason
     FROM devv5.concept c, devv5.domain d
    WHERE     c.domain_id = d.domain_id
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = c.concept_id)    
          AND NOT EXISTS
                 (SELECT 1
                    FROM concept_relationship r_int
                   WHERE     r_int.concept_id_1 = d.domain_concept_id
                         AND r_int.concept_id_2 = c.concept_id
                         AND relationship_id = 359);
COMMIT;

INSERT /*+ APPEND */
      INTO  concept_ancestor (ANCESTOR_CONCEPT_ID,
                              DESCENDANT_CONCEPT_ID,
                              MAX_LEVELS_OF_SEPARATION,
                              MIN_LEVELS_OF_SEPARATION)
   SELECT ca.ancestor_concept_id,
          ca.descendant_concept_id,
          ca.max_levels_of_separation,
          ca.min_levels_of_separation
     FROM devv5.concept_ancestor ca
    WHERE     EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = ca.ancestor_concept_id)
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = ca.descendant_concept_id);	 

COMMIT;

INSERT /*+ APPEND */
      INTO  concept_synonym (CONCEPT_SYNONYM_ID,
                             CONCEPT_ID,
                             CONCEPT_SYNONYM_NAME)
   SELECT ROWNUM AS concept_synonym_id,
          cs.concept_id,
          cs.concept_synonym_name
     FROM devv5.concept_synonym cs
    WHERE EXISTS
             (SELECT 1
                FROM concept c_int
               WHERE c_int.concept_id = cs.concept_id);
COMMIT;	 

INSERT /*+ APPEND */
      INTO  source_to_concept_map (SOURCE_CODE,
                                   SOURCE_VOCABULARY_ID,
                                   SOURCE_CODE_DESCRIPTION,
                                   TARGET_CONCEPT_ID,
                                   TARGET_VOCABULARY_ID,
                                   MAPPING_TYPE,
                                   PRIMARY_MAP,
                                   VALID_START_DATE,
                                   VALID_END_DATE,
                                   INVALID_REASON)
   SELECT DISTINCT c1.concept_code AS SOURCE_CODE,
                   vc1.vocabulary_id_v4 AS SOURCE_VOCABULARY_ID,
                   c1.concept_name AS SOURCE_CODE_DESCRIPTION,
                   c2.concept_id AS TARGET_CONCEPT_ID,
                   vc2.vocabulary_id_v4 AS TARGET_VOCABULARY_ID,
                   c2.domain_id AS MAPPING_TYPE,
                   'Y' AS PRIMARY_MAP,
                   r.valid_start_date AS VALID_START_DATE,
                   r.valid_end_date AS VALID_END_DATE,
                   r.invalid_reason AS INVALID_REASON
     FROM devv5.concept c1,
          devv5.concept c2,
          devv5.concept_relationship r,
          devv5.vocabulary_conversion vc1,
          devv5.vocabulary_conversion vc2
    WHERE     c1.concept_id = r.concept_id_1
          AND c2.concept_id = r.concept_id_2
          AND r.relationship_id = 'Maps to'
          AND c1.vocabulary_id = vc1.vocabulary_id_v5
          AND c2.vocabulary_id = vc2.vocabulary_id_v5
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = c1.concept_id)
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = c2.concept_id)
   UNION ALL
   SELECT DISTINCT c1.concept_code AS SOURCE_CODE,
                   vc1.vocabulary_id_v4 AS SOURCE_VOCABULARY_ID,
                   c1.concept_name AS SOURCE_CODE_DESCRIPTION,
                   0 AS TARGET_CONCEPT_ID,
                   0 AS TARGET_VOCABULARY_ID,
                   'Unmapped' AS MAPPING_TYPE,
                   'Y' AS PRIMARY_MAP,
                   c1.valid_start_date AS VALID_START_DATE,
                   c1.valid_end_date AS VALID_END_DATE,
                   NULL AS INVALID_REASON
     FROM devv5.concept c1
          LEFT JOIN devv5.concept_relationship r
             ON     r.concept_id_1 = c1.concept_id
                AND r.relationship_id = 'Maps to'
                AND r.invalid_reason IS NULL
          JOIN devv5.vocabulary_conversion vc1
             ON vc1.vocabulary_id_v5 = c1.vocabulary_id
    WHERE     r.concept_id_1 IS NULL
          AND c1.concept_code <> 'OMOP generated'
          AND c1.concept_id NOT IN (38000782, 38000781, 38000783, 44819222,44819208,38004574, 44819209, 44819226, 38000024,38000301,44819227)
          AND EXISTS
                 (SELECT 1
                    FROM concept c_int
                   WHERE c_int.concept_id = c1.concept_id);

COMMIT;		  