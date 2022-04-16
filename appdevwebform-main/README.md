# appdevwebform


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



