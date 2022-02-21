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


Windows commands (in command line in the folder with application.py):
 pip install -r requirements.txt
 pip install virtualenv
 python -m venv venv
 venv\scripts\activate

 set FLASK_APP=application.py or $env:FLASK_APP = "application.py"
 set LOCAL_TEST=True or $env:LOCAL_TEST='yes'
 flask init-db
 flask run


AWS Setup:
Setup RDS with a new database - (MySQL, free/whatever).
Configure the RDS to allow inbound traffic from the beanstalk/anywhere (Under security section of connectivity and security, press the VPC security groups)
Setup a beanstalk, and then assign it a key-value for a .pem file so you can SSH
Use the following command template to SSH: "ssh -i "C:\Users\alexd\Downloads\appdev.pem" ec2-user@ec2-54-167-96-206.compute-1.amazonaws.com"
After ssh-ing, go to "/var/app/current" and do "pip install -r requirements.txt"
Then do "export FLASK_APP="application.py"" and you are done :)


Error mac:
[2021-11-04 14:36:16,936] ERROR in app: Exception on /getimg/profiles/1 [GET]
Traceback (most recent call last):
  File "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/flask/app.py", line 2447, in wsgi_app
    response = self.full_dispatch_request()
  File "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/flask/app.py", line 1952, in full_dispatch_request
    rv = self.handle_user_exception(e)
  File "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/flask/app.py", line 1821, in handle_user_exception
    reraise(exc_type, exc_value, tb)
  File "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/flask/_compat.py", line 39, in reraise
    raise value
  File "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/flask/app.py", line 1950, in full_dispatch_request
    rv = self.dispatch_request()
  File "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/flask/app.py", line 1936, in dispatch_request
    return self.view_functions[rule.endpoint](**req.view_args)
  File "/Users/alex/Desktop/AppDev/appdevwebform-main/application.py", line 85, in decorated_function
    return f(*args, **kwargs)
  File "/Users/alex/Desktop/AppDev/appdevwebform-main/application.py", line 153, in get_img
    return send_from_directory(app.config['UPLOAD_FOLDER'], profile.imgPath)
AttributeError: 'NoneType' object has no attribute 'imgPath'
