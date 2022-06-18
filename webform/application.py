import click, os, random
from os.path import join, dirname, realpath
from flask import Flask, render_template, request, redirect, g, url_for, flash, session, jsonify, send_from_directory
from functools import wraps
from werkzeug.utils import secure_filename
import datetime
from dotenv import dotenv_values
# ENV VARIABLES +
#Second category added when updating spanish name from nothing, without updating english name initially
config=dotenv_values("config.env")
DB_URI_TEMP = 'sqlite:///../ebdb.db' if config["LOCAL_TEST"].lower() in ('true', '1', 't') else f"mysql+pymysql://{config['USER']}:{config['PASS']}@{config['DB_URL']}/{config['DB_NAME']}"
# CREATE APP

application = app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = DB_URI_TEMP
app.config['SECRET_KEY'] = 'h'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

UPLOAD_FOLDER = join(dirname(realpath(__file__)), 'uploads')#if os.getenv('LOCAL_TEST') is not None else '/efs/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app.config['TEMPLATES_AUTO_RELOAD'] = True
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def rand():
    return random.randint(0, 10000000)
# Importing here so app can initalize first
from database import School, AuthManager, Category, Profile, db
from swift_app import get_schools
db.init_app(app)

#==========================================================DB Formation above
@app.cli.command('schools')
def school_codes():
    auths = AuthManager.query.all()
    for row in auths:
        print(School.query.filter_by(id=row.id).first().name, row.code)


@app.cli.command('json')  
def test_json():
    school_id = School.query.first().id
    print(get_schools())


@app.cli.command('create')
@click.argument('name')
def create_school(name):
    new_school = School(name=name, hidden=False)
    code = rand()
    auth = AuthManager(code=code, school_id=new_school.id)
    new_school.auth = auth
    db.session.add(auth)
    db.session.add(new_school)
    db.session.commit()
    print("School: %s added successfully\nCode: %s" % (name, code))


@app.cli.command('test')
def hello_command():
    click.echo('Hello World')


@app.cli.command('init-db')
def test_command():
    db.drop_all()
    db.create_all()
    print('db initiated')


@app.cli.command('list')
def list_command():
    schools = School.query.all()
    [print(school.name, school.id, school.categories) for school in schools]
    if len(schools) == 0:
        print("No schools added at the moment")

#===================================================================DB commands above

# Requires g.school to be set before doing certain actions, acessible with the @login_required wrapper

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if g.school is None:
            return redirect(url_for('index'), next=request.url)
        return f(*args, **kwargs)

    return decorated_function

# Sets g.school based on inputted code

@app.before_request
def load_school():
    if "school_id" in session:
        school = School.query.filter_by(id=session["school_id"]).first()
        g.school = school
    else:
        redirect(index)

# Creates login page, if you have a GET request to load the page normally it loads index.html. If you send a POST request through the school number form if correct it sets the school id in session storage if wrong redirect

@app.route("/", methods=("GET", "POST"))
def index():
    if request.method == "GET":
        return render_template("index.html")
    else:
        y = request.form['code']
        s = AuthManager.query.filter_by(code=y).first()
        if (s is not None) and (s.code == y):
            session["school_id"] = s.school_id
            return redirect(url_for('school'))
        else:
            flash("Invalid school code.")
            return redirect(url_for('index'))

# checks if file extension is allowed

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# gets any filename in upload folder given file path


# Could be more secure. Not important

@app.route("/geticon/<path>", methods=("GET",))
@login_required
def get_icon(path):
    #return send_from_directory(app.config['UPLOAD_FOLDER'], path)
    return send_from_directory("./static", path)

@app.route("/getimg/<table>/<id>", methods=("GET",))
@login_required
def get_img(table, id):
    # gets current school img, sends image
    if table == "schools":
        if g.school.imgPath is not None:
            return send_from_directory(app.config['UPLOAD_FOLDER'], g.school.imgPath)
        else:
            return None
    #gets first category img path
    elif table == "categories":
        category = Category.query.filter_by(school_id=g.school.id, id=id).first()
        if category.imgPath is None:
            return None
        return send_from_directory("static", category.imgPath)
    #gets profile image path
    elif table == "profiles":
        if 'category_id' not in session:
            return jsonify(noimg=True)
        profile = Profile.query.filter_by(category_id=session['category_id'], id=id).first()
        return send_from_directory(app.config['UPLOAD_FOLDER'], profile.imgPath)
    else:
        pass


@app.route("/getimgs/<table>/<id>", methods=("GET",))
def getImagePath(table, id): 
    #Returns img_path
    if table == "schools":
        q = School.query.filter_by(id=id).first()
        img_path = q.imgPath if q is not None else ""
        return send_from_directory(app.config['UPLOAD_FOLDER'], img_path)
    #Returns img path
    elif table == "categories":
        q = Category.query.filter_by(id=id).first()
        img_path = q.imgPath if q is not None else ""
        return send_from_directory("static", img_path)
    #Returns img path
    elif table == "profiles":
        q = Profile.query.filter_by(id=id).first()
        img_path = q.imgPath if q is not None else ""
        return send_from_directory(app.config['UPLOAD_FOLDER'], img_path)
    else:
        return None

    #if img_path is None:
    #    return "no_image"
    
# returns JSON of category 

@app.route("/category_data/<id>", methods=('GET',))
@login_required
def category_data(id):
    category = Category.query.filter_by(school_id=g.school.id, id=id).first()
    if category.imgPath is None or category.imgPath is False:
        img_path = 'None'
    else:
        img_path = category.imgPath
    return jsonify(name_eng=category.name_eng, name_esp=category.name_esp, text_eng=category.text_eng,
                   text_esp=category.text_esp, imgPath=category.imgPath, hidden=category.hidden,
                   vimeoLink=category.vimeoLink)

# returns JSON if profile info

@app.route("/profile_data/<id>", methods=('GET',))
@login_required
def profile_data(id):
    if 'category_id' not in session:
        return jsonify(text="issue.")

    profile = Profile.query.filter_by(category_id=session['category_id'], id=id).first()

    if profile.imgPath is None or profile.imgPath is False:
        has_img = 0
    else:
        has_img = 1
    return jsonify(name_eng=profile.name_eng, name_esp=profile.name_esp,
                   text_eng=profile.text_eng, text_esp=profile.text_esp,
                   hasImg=has_img, vimeoLink=profile.vimeoLink, hidden=profile.hidden)


@app.route("/school", methods=("GET", "POST"))
@login_required
def school():

    if request.method == "POST":

        """
            If the request is to delete or hide a category:
        """
        if 'dfCId' in request.form:
            category_to_delete = Category.query.filter_by(id=request.form['dfCId']).first()
            print(category_to_delete)

            for prof in category_to_delete.profiles:
                if prof.imgPath is not None:
                    os.remove(os.path.join(app.config['UPLOAD_FOLDER'], prof.imgPath))
            db.session.delete(category_to_delete)
            db.session.commit()
            return redirect(url_for('school'))
        elif 'hfCId' in request.form:
            category_to_hide = Category.query.filter_by(id=request.form['hfCId']).first()
            category_to_hide.hidden = not category_to_hide.hidden
            db.session.commit()
            return redirect(url_for('school'))

        """
            If the request is to update school name: (ALSO USING THIS TO CHECK FOR UPLOADING/UPDATING PHOTO...
        """
        if 'updated_school_name' in request.form:
            # Checking for file
            if 'file' in request.files and request.files['file'].filename != '':
                file = request.files["file"]

                if allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    if filename in os.listdir(app.config['UPLOAD_FOLDER']):
                        filename = str(rand()) + filename
                    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                    s_imgPath = filename
                    g.school.imgPath = s_imgPath
                    db.session.commit()
                else:
                    flash("Issue uploading file")
            # Updating name
            g.school.name = request.form['updated_school_name']
            db.session.commit()
            return redirect(url_for('school'))

        """
            From this point on, all code is for UPDATING OR CREATING a category (not deleting or hiding).
            Check if the name of the category is in the form. 
        """
        
        if ("name_esp" not in request.form and "name_eng" not in request.form) or \
                (request.form["name_esp"] == "" and request.form["name_eng"] == ""):
            flash("Form not filled out")
            return redirect(url_for('school'))

        # Extract data from request.form -- !!!! Can change to just c_name_eng = request.form["name_eng"] but idk if it will give an error instead of a none if the object is not in request.form
        if "name_eng" in request.form:
            c_name_eng = request.form["name_eng"]
        else:
            c_name_eng = None
        if "name_esp" in request.form:
            c_name_esp = request.form["name_esp"]
        else:
            c_name_esp = None

        if "text_eng" in request.form:
            c_text_eng = request.form["text_eng"]
        else:
            c_text_eng = None

        if "text_esp" in request.form:
            c_text_esp = request.form["text_esp"]
        else:
            c_text_esp = None

        if "iconPath" in request.form:
            icon_path = request.form['iconPath']
        else:
            icon_path = None

        if "vimeoLink" in request.form:
            vimeoLink = request.form['vimeoLink']
        else:
            vimeoLink = None
        catId = request.form['catid']

        # This should be tested!!!!! -- Changed to catId tracking from html, not sure how this will hold up but had odd issues with the other version,might want to test old version on windows
        category = Category.query.filter_by(school_id=g.school.id, id=catId).first()
        
        if category is not None:
            print('updating %s' % c_name_eng)
            print(category.__dict__)
            if 'update' in request.form:
                category.name_eng = c_name_eng
                category.name_esp = c_name_esp
                category.text_eng = c_text_eng
                category.text_esp = c_text_esp
                category.imgPath = icon_path
                category.vimeoLink = vimeoLink
                db.session.commit()

            """
            elif 'delete' in request.form:
                db.session.delete(category)
                db.session.commit()
            elif 'toggle_hide' in request.form:
    
                category.hidden = not category.hidden
                db.session.commit()
            else:
                flash("This category shares name with another category.")
                return redirect(url_for('school'))
"""
        else:
            """
                If category doesn't exist, create it!
            """
            new_category = Category(school_id=g.school.id,
                                    name_eng=c_name_eng,
                                    name_esp=c_name_esp,
                                    text_eng=c_text_eng,
                                    text_esp=c_text_esp,
                                    vimeoLink=vimeoLink,
                                    imgPath=icon_path,
                                    hidden=False)
            db.session.add(new_category)
            db.session.commit()
    #Only 5 icons?
    return render_template("school.html", categories=g.school.categories, icons=['image1.png', 'image2.png', 'image3.png',
                                                                                 'image4.png', 'image5.png'])


@app.route('/school/<category_id>', methods=('POST', 'GET'))
@login_required
def manage_category(category_id):

    category = Category.query.filter_by(school_id=g.school.id, id=category_id).first()

    if category is None:
        return redirect(url_for('school'))

    if request.method == 'POST':

        early_return_template = render_template('manage_category.html',
                                                category_name=(category.name_eng if category.name_eng is not None
                                                               else category.name_esp),
                                                profiles=category.profiles, time=datetime.datetime.now().second)
        if 'dfPId' in request.form:
            profile_to_delete = Profile.query.filter_by(id=request.form['dfPId']).first()
            print(profile_to_delete)

            if profile_to_delete.imgPath is not None:
                os.remove(os.path.join(app.config['UPLOAD_FOLDER'], profile_to_delete.imgPath))
            db.session.delete(profile_to_delete)
            db.session.commit()
            return redirect(url_for("manage_category", category_id = category_id))
        elif 'hfPId' in request.form:
            profile_to_hide = Profile.query.filter_by(id=request.form['hfPId']).first()
            profile_to_hide.hidden = not profile_to_hide.hidden
            db.session.commit()
            return redirect(url_for('manage_category', category_id = category_id))
        # Make sure there is an ID to locate profile with, IF it is an update request
        if "update" in request.form and ("id" not in request.form or request.form["id"] == ""):
            flash("Unable to identify profile")
            return early_return_template
        # Ensure that the updated OR created profile has a name property (either eng or spanish)
        if "name_eng" not in request.form and "name_esp" not in request.form:
            flash("Profile must have a name!")
            return early_return_template

        # Check to see if request is to update:
        
        update_mode = "update" in request.form

        # Find profile from id:
        profile = None
        if update_mode:
            profile = Profile.query.filter_by(category_id=category.id, id=request.form["id"]).first()
        if profile is not None and update_mode is False:
            flash("Category already exists")
            return render_template('manage_category.html', category_name=(category.name_eng if category.name_eng is not
                                                                          None else category.name_esp), profiles=category.profiles, time=datetime.datetime.now().second)

        # Extract data from request.form
        if "textBody_eng" not in request.form:
            p_text_eng = None
        else:
            p_text_eng = request.form["textBody_eng"]
        if "textBody_esp" not in request.form:
            p_text_esp = None
        else:
            p_text_esp = request.form["textBody_esp"]

        if "name_eng" in request.form:
            p_name_eng = request.form["name_eng"]
        else:
            p_name_eng = None
        if "name_esp" in request.form:
            p_name_esp = request.form["name_esp"]
        else:
            p_name_esp = None

        if "vimeoLink" in request.form:
            vimeoLink = request.form["vimeoLink"]
        else:
            vimeoLink = None

        # Grab uploaded picture, overwrites similar names
        p_imgPath = None
        if "file" in request.files and request.files["file"].filename != "":
            file = request.files["file"]
            if allowed_file(file.filename):
                filename = secure_filename(file.filename)
                if filename in os.listdir(app.config['UPLOAD_FOLDER']):
                    filename = str(rand()) + filename
                file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                p_imgPath = filename
                
            else:
                flash("Issue uploading file")
        # Save/upload profile

        if update_mode:
            profile.text_eng = p_text_eng
            profile.text_esp = p_text_esp
            profile.name_eng = p_name_eng
            profile.name_esp = p_name_esp
            profile.vimeoLink = vimeoLink
            #moved this here temporarily
            if p_imgPath is not None: profile.imgPath = p_imgPath 
            db.session.commit()
            #TEMPORARY PATCH FOR PROFILE IMAGES NOT UPDATING SINCE CACHE BEING ANNOYING
            #return redirect(url_for('school'))
        else:
            new_profile = Profile(category_id=category.id,
                                  name_eng=p_name_eng,
                                  name_esp=p_name_esp,
                                  text_eng=p_text_eng,
                                  text_esp=p_text_esp,
                                  vimeoLink=vimeoLink,
                                  imgPath=p_imgPath,
                                  hidden=False)
            db.session.add(new_profile)
            db.session.commit()
    else:
        session['category_id'] = category.id

    return render_template('manage_category.html',
                           category_name=(category.name_eng if category.name_eng is not None
                                          else category.name_esp),
                           profiles=category.profiles, time=datetime.datetime.now().second)


#================================FLASK HTML INTERACTION ABOVE


@app.route('/get_json/schools', methods=('GET',))
def get_json():
    return jsonify(get_schools())
#============================================================JSON