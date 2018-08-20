# Notes on Statistical Analyses

## FAQ

### How do I reproduce stats in the existing Google Sheets dashboard?

In [the dashboard](https://www.google.com/url?hl=en&q=https://docs.google.com/spreadsheets/d/1fAUTuhdfih_oJBBtUCOCzeIOUedK_Gj6rvo7kThhRLM/edit?usp%3Dsharing&source=gmail&ust=1528653289542000&usg=AFQjCNGNk_JQw-KE89SGj-3ssZBsoVidBQ), go to the "Report Configuration" tab. Query the same metric and dimensions as are listed there. Note that for Android, it's eventAction instead of eventCategory, and using the latter results in too few sessions.  

### What are the differences in event and path tracking across platforms?

Android records events differently from the other platforms. Per [the dashboard](https://www.google.com/url?hl=en&q=https://docs.google.com/spreadsheets/d/1fAUTuhdfih_oJBBtUCOCzeIOUedK_Gj6rvo7kThhRLM/edit?usp%3Dsharing&source=gmail&ust=1528653289542000&usg=AFQjCNGNk_JQw-KE89SGj-3ssZBsoVidBQ) > Report Configuration, I learned that the type of event (e.g., helper detail displayed, phone call made, etc.) is tracked under eventCategory for the three non-Android platform are tracked under eventAction for Android. See the function *fetch_one_platform* (the part where *paths == FALSE*) for an example. 

There are also important differences when analyzing path data. In the three non-Android platforms, you can access the paths by looking at the eventCategory called Caseflow, for which the variable eventAction contains the caseflow number (see [this codebook of caseflow numbers](https://docs.google.com/spreadsheets/d/1-Zqk_HU_vIoLYeICdjtBDljCGrSt-9Tg_a53C2XrOsc/edit#gid=0)
). But in Android, you instead have to look at the eventLabel variable, which contains some entries called "Case Flow XXX", where XXX is a number. Those XXX numbers are the same as the case flow numbers in the other platforms. See the function *fetch_one_platform* (the part where *paths == TRUE*) for an example. 

### What are paths?

They are trajectories that the user can take through the app (series of clicks). Note that the numbering of the paths changed in 2018 (see [this codebook of caseflow numbers](https://docs.google.com/spreadsheets/d/1-Zqk_HU_vIoLYeICdjtBDljCGrSt-9Tg_a53C2XrOsc/edit#gid=0)
). Paths allow detailed analyses, e.g., parsing users who query wildlife vs. domestic animal issues. See the above FAQ before analyzing path data. 