# appdevwebform

To run the webform:

* 1) Open the project


* Creating a virtual-environment. This basically ensures all the modules/libraries you download don't affect other projects and are only usable in the environment they are downloaded in. 
(optional but reccomended. If it isn't working it can be skipped)
  * "pip install virtualenv"
  * "python -m venv venv" 
  * "source venv/bin/activate"



* 2) Open a terminal window 
* 3) Make sure you're in the right directory
* 4) type "export FLASK_APP=application.py"
  * This sets an environment variable so that flask knows where to look for the code to run the app. 
* 5) Type "flask init-db" initializes the database. 
  * If you ever think the database is messed up, just run this. But, it drops all the tables that already exist, so all data will be lost.
* 6) Type "flask create <enter a name here>" this creates a new school with id=1. Not sure what will happen when two schools are created (they'd both ave the same id), but I don't think it will crash. In any case this will be changed but its here to make testing a little easier. 
* 6) Type "flask run" the website should be running now at http://localhost:5000.
  * If needed, the port can be changed, but I haven't done it
 
### All the code is in one file which is not great, but everything is in there. Basically five parts:
 
* I. (boilerplate stuff for starting flask, configuration, etc.) 
* II. The database models (School, Category, Profile)
* III. The commands for creating school, initializing databse, etc.
* IV. Functions that basically return the html pages to the browser so that data can be entered.
* V. A few functions that get all of the database data in put it in json, and one function that listens for a request (from the mobile app) and returns this json. 

# Mac Commands
```
pip install virtualenv
python -m venv venv
source venv/bin/activate
```
```
pip install -r requirements.txt
export FLASK_APP=application.py
```
  then
```
flask init-db
flask run
```
# Windows Commands
 ```
pip install virtualenv
python -m venv venv
venv\scripts\activate
pip install -r requirements.txt
```
```
set FLASK_APP=application.py
set LOCAL_TEST=True
```
 or
```
$env:FLASK_APP = "application.py"
$env:LOCAL_TEST='yes'
```
 then
```
flask init-db
flask run
```

# AWS Setup
 1. Setup RDS with a new database - (MySQL, free/whatever).
 2. Configure the RDS to allow inbound traffic from the beanstalk/anywhere (Under security section of connectivity and security, press the VPC security groups)
 3. Setup a beanstalk, and then assign it a key-value for a .pem file so you can SSH
 4. Use the following command template to SSH: ```ssh -i "**pemfile path**" ec2-user@**awsurl**```
 5. After ssh-ing, go to ```/var/app/current``` and do ```pip install -r requirements.txt```
 6. Then do ```export FLASK_APP="application.py"``` and you are done :)



