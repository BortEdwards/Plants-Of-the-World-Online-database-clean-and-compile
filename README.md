Plants-Of-the-World-Online-database-clean-and-compile

The POWO database comes in two halves - one with species taxonomy information the second with distriution information for the same taxa with a separate entry for each region found in.
For ease of use these two halves need to be compiled into a single dataframe and some errors need to be addressed:

Issues fixed:
- capitalized aberrent L3 area codes (resulted in failure to match verbatim area strings)
- removed errant tabs (resulted in data-reading issues)

Recompiled document "POWO.MOLmaster" from POWO database files including modifications:
- L3 verbatim areas re-interpreted from area codes
- calculated number of continents, regions, and areas each taxon found in
- "scientific name" created combining genus and species

NB entries for some taxa are still missing area codes at different levels but this reflects "unknown" status in POWO.