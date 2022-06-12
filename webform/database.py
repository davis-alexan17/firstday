from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import relationship
#from application import app
# CREATE APP

#db = SQLAlchemy(app)
db = SQLAlchemy()
class AuthManager(db.Model):
    __tablename__ = "auth_manager"
    id = db.Column(db.Integer, primary_key=True)
    """
    - This is essentially like a "User object" basically just used to verify sessions
    - For now, it will just use an id.
    """
    # For now just a code:
    code = db.Column(db.String(50))
    school_id = db.Column(db.Integer, db.ForeignKey("school.id"))


class School(db.Model):
    __tablename__ = "school"
    id = db.Column(db.Integer, primary_key=True)
    categories = relationship("Category")

    name = db.Column(db.String(50))
    imgPath = db.Column(db.String(50))
    hidden = db.Column(db.Boolean)

    # Authentication:
    auth = relationship("AuthManager", lazy=True, uselist=False)
    # set uselist to false to ensure a 1 to 1 relationship


class Category(db.Model):
    __tablename__ = "category"
    id = db.Column(db.Integer, primary_key=True)
    school_id = db.Column(db.Integer, db.ForeignKey("school.id"))

    profiles = relationship("Profile")
    ext_profiles = relationship("ExtendedProfile")

    name_eng = db.Column(db.String(50))
    name_esp = db.Column(db.String(50))

    imgPath = db.Column(db.String(50), nullable=True)
    vimeoLink = db.Column(db.String(100), nullable=True)

    text_eng = db.Column(db.String(1000))
    text_esp = db.Column(db.String(1000))   
    hidden = db.Column(db.Boolean)


class Profile(db.Model):
    __tablename__ = "profile"
    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey("category.id"))

    name_eng = db.Column(db.String(50))
    name_esp = db.Column(db.String(50))

    text_eng = db.Column(db.String(1000))
    text_esp = db.Column(db.String(1000))

    imgPath = db.Column(db.String(50))
    vimeoLink = db.Column(db.String(100), nullable=True)

    hidden = db.Column(db.Boolean)


class ExtendedProfile(db.Model):
    """
    This class is currently not in use. This exists so that in case there is demand for a new form of content that the
    current profile class cannot hold, this will be able to compensate. For example, holding profiles that contain a third language.
    """
    __tablename__ = "extended_profile"
    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey("category.id"))

