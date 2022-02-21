from database import School, Category, Profile

def get_schools():
    schools = School.query.filter_by(hidden=False).all()
    json = "["
    for school in schools:
        categories = get_categories(school.id)
        s = "{\"name\": \"%s\", \"categories\": %s, \"imgKey\": \"%s\", \"id\": %s}" % (school.name, categories, school.imgPath, school.id)
        json = json + s + ", "
    if len(json) == 1:
        return json + "]"
    return json[:-2] + "]"


def get_categories(school_id):
    categories = Category.query.filter_by(school_id=school_id, hidden=False).all()
    json = "["
    for category in categories:
        profiles = get_profiles(category.id)
        s = "{\"name_eng\": \"%s\", \"name_esp\": \"%s\", \"text_eng\": \"%s\", \"text_esp\": \"%s\", \"profiles\": %s, \"imgKey\": \"%s\", \"id\": %s}" \
            % (category.name_eng, category.name_esp, category.text_eng, category.text_esp, profiles, category.imgPath, category.id)
        json = json + s + ", "
    if len(json) == 1:
        return json + "]"
    return json[:-2] + "]"


def get_profiles(category_id):
    profiles = Profile.query.filter_by(category_id=category_id, hidden=False).all()
    json = "["
    for profile in profiles:
        s = "{\"name_eng\": \"%s\", \"name_esp\": \"%s\", \"text_eng\": \"%s\", \"text_esp\": \"%s\",  \"imgKey\": \"%s\", \"id\": %s}" \
            % (profile.name_eng, profile.name_esp, profile.text_eng, profile.text_esp, profile.imgPath, profile.id)
        json = json + s + ", "
    if len(json) == 1:
        return json + "]"
    return json[:-2] + "]"