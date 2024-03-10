# VideoGameSalesAnalyzer

This program is tailored for the "Video Game Sales.txt" document.
It is started by calling (analyzer-start), or just running the program in DrRacket.
# Core features
Filters on Genre:

Welcome to the Game Sales Analyzer!
Please make a selection.
You have up to 3 left.
1. Title
2. Region
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 0 choices so far.
4
Please enter the genre: 
"Sports"
Please make a selection.
You have up to 2 left.
1. Title
2. Region
3. Year
5. Publisher
6. No more filters
You have made 1 choices so far.

Filters by Region:
2
Which region?
1. North America
2. Europe
3. Japan
4. Rest of World
5. Global
1
Please make a selection.
You have up to 1 left.
1. Title
3. Year
5. Publisher
6. No more filters
You have made 2 choices so far.

Filters by Date, and reverses the date input:
3
Please enter the year range (i.e. "2001 - 2004": 
"2002-2001"
Please make a selection.
You have up to 0 left.

Sorts by Rating or Rank, here Rating specifically:
How would you like your results sorted?
1. Rating
2. Rank

1
Rank: 807 Title: SSX Tricky Platform: PS2 Year: 2001 Genre: Sports Publisher: Electronic Arts North America: 0.85 Rating: 92.54 
Rank: 1036 Title: NCAA Football 2003 Platform: PS2 Year: 2002 Genre: Sports Publisher: Electronic Arts North America: 1.16 Rating: 91.36 
...

Handles partial match for Publisher, and all data are case insensitive:
You have up to 3 left.
1. Title
2. Region
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 0 choices so far.
5
Please enter the genre: 
"ten"
Please make a selection.
You have up to 2 left.
1. Title
2. Region
3. Year
4. Genre
6. No more filters
You have made 1 choices so far.

Sorts by Rank:
6
How would you like your results sorted?
1. Rating
2. Rank

2

Rank: 1 Title: Wii Sports Platform: Wii Year: 2006 Genre: Sports Publisher: Nintendo North America: 40.43 Europe: 28.39 Japan: 3.77 Rest of World: 8.54 Global: 81.12 Rating: 76.28 
Rank: 2 Title: Super Mario Bros. Platform: NES Year: 1985 Genre: Platform Publisher: Nintendo North America: 29.08 Europe: 3.58 Japan: 6.81 Rest of World: 0.77 Global: 40.24 Rating: 91
...

Finally, has an option to repeat or exit:
Would you like to analyze the data again?
1. Analyze again
Any other input will exit!
fasdf
Thank you for using the analyzer!
