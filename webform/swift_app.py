from json import JSONDecoder
from database import School, Category, Profile

def get_schools():
    schools = School.query.filter_by(hidden=False).all()
    json = []
    for school in schools:
        categories = get_categories(school.id)
        json.append({"name": school.name, "categories": categories, "imgKey": school.imgPath, "id": school.id})
    return json

def get_categories(school_id):
    categories = Category.query.filter_by(school_id=school_id, hidden=False).all()
    json = []
    for category in categories:
        profiles = get_profiles(category.id)
        json.append({"name_eng": category.name_eng, "name_esp": category.name_esp, "text_eng": category.text_eng, "text_esp": category.text_esp, "profiles": profiles, "imgKey": category.imgPath, "id": category.id})
    return json

def get_profiles(category_id):
    profiles = Profile.query.filter_by(category_id=category_id, hidden=False).all()
    json = []
    for profile in profiles:
        json.append({"name_eng": profile.name_eng, "name_esp": profile.name_esp, "text_eng": profile.text_eng, "text_esp": profile.text_esp, "imgKey": profile.imgPath, "id": profile.id, "vimeoLink": profile.vimeoLink})
    return json