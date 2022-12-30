LOAD DATA 
INFILE '/home/oracle/.sqldeveloper/labs/import_data.txt'
DISCARDFILE '/home/oracle/.sqldeveloper/labs/import_data.dis'
INTO TABLE LAB18
FIELDS TERMINATED BY ","
(
id "round(:id, 2)",
text "upper(:text)",
date_value date "DD.MM.YYYY"
)
