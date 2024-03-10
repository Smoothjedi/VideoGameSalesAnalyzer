# VideoGameSalesAnalyzer

This program is tailored for the "Video Game Sales.txt" document.
It is started by calling (analyzer-start), or just running the program in DrRacket.
This will give you a menu such as this:

Welcome to the Game Sales Analyzer!
Please make a selection.
You have up to 3 left.
1. Title
2. Platform
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 0 choices so far.

As you make selections, the menu options chosen will disappear:

1
Please enter your title: 
"Wii Sports"
Please make a selection.
You have up to 2 left.
2. Platform
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 1 choices so far.

Title is now removed as an option.
Since I know there is only one "Wii Sports", I will just pick no more filters:

6
How would you like your results sorted?
1. Rating
2. Sales

Rating gives immediate results, but Sales lets us pick a category:

2
Which region?
1. North America
2. Europe
3. Japan
4. Rest of World
5. Global
3
Rank: 1 Title: Wii Sports Platform: Wii Year: 2006 Genre: Sports Publisher: Nintendo North America: 40.43 Europe: 28.39 Japan: 3.77 Rest of World: 8.54 Global: 81.12 Rating: 76.28 

Would you like to analyze the data again?
1. Analyze again
Any other input will exit!
dfg
Thank you for using the analyzer!

There is some error handling in the code so bad options should not break the program. For example:

Welcome to the Game Sales Analyzer!
Please make a selection.
You have up to 3 left.
1. Title
2. Platform
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 0 choices so far.
456
Sorry, that is not a valid option
Please make a selection.
You have up to 3 left.
1. Title
2. Platform
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 0 choices so far.

Upon selecting an option:

Please make a selection.
You have up to 3 left.
1. Title
2. Platform
3. Year
4. Genre
5. Publisher
6. No more filters
You have made 0 choices so far.
5
Please enter the genre: 
asfdasd
Invalid input.
Please enter the genre: 
