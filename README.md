# Salesforce Lookup Rollup Summaries

As of now the Roll Up Summaries (COUNT, MIN, MAX, SUM) are ONLY available for Master-Detail relationship and NOT for Lookup relationship.

If you have a Lookup relationship between 2 objects then you need to write an Apex trigger on child object to get the Roll Up Summaries (COUNT, MIN, MAX, SUM) on parent object. Here you will find an example of code snippet for the Lookup Rollup Summaries.

### Considerations of Lookup Rollup Summaries
1. The Rollup Summaries logic should consider insert, update and delete operations.
2. The trigger should handle validation rules of child and as well as parent objects.
3. The exceptions should be handled gracefully and in a user-friendly manner.

#### A great tool on Rollup Summaries for administrators 
https://github.com/afawcett/declarative-lookup-rollup-summaries
