BOwl - Baby Owl 
====
[BOwl](https://github.com/eduardo-salazar/bowl) is a library to extract a facebook social network for a specific user


**Found a bug? Interested in contributing?** Check out and let me know xD

Description
-----------
This small app extract from your facebook account your friends and also the mutual friends you have with every friend. At the end it creates two files:
*   `{your_id}_nodes.csv` - This file contains a list of all your friends (id,name,link)
*		`{your_fb_id}_edges.csv` - This file contains a list of the connection between your nodes

Installation
-----------

If you wan to run the app locally 

Install dependencies
```
bundle install
```

Run sinatra app locally
```
puma
```

Load the app in your browser
```
http://localhost:3000/
```


Maintenance
-----------

_Pull requests_: BOwl exists is in the process of learning so pull requests are very welcome! If you have any questions,just open an issue.

Please note that this project is released with a Contributor Code of Conduct. By participating in
this project you agree to abide by its terms. See
[code_of_conduct.md](https://github.com/eduardo-salazar/bowl/blob/master/code_of_conduct.md) for more information.

Breaking/new Facebook changes and other urgent issues obviously will get addressed much more
quickly. (We've never had a security issue, but obviously that would be priority 0.)

Have questions? Found a breaking bug or urgent issue? You can write directly to me
I'm always happy to respond.
