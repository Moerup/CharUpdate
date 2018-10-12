
Copy the Powershell scripts you need over to DKMDS12 + the Password.txt file.

--------------- CheckTest.ps1: ---------------
Used for checking all PC's if they are up/down or using trusted/SQL authentication
If you want to test a new computer you simply just add it to "$Global:PCArray"
It will write the information to the console.

--------------- UpdateChars.ps1: ---------------
Used for updating characteristics on all the PC's.
Edit "$Global:Char" to the desired characteristics
And if you want to add a new PC to the list, simply input them into "$Global:PCArrayTrusted" for Trusted authentication or "$Global:PCArraySQL" for SQL authentication
When the script is done it will create a file at the location of the script.

--------------- PullChars.ps1: ---------------
Used for selecting all characteristics on all of the PC's and outputting all unique characteristics into a file named Chars.txt saved at the scripts location.
And if you want to add a new PC to the list, simply input them into "$Global:PCArrayTrusted" for Trusted authentication or "$Global:PCArraySQL" for SQL authentication