#!/bin/bash

# Superset setup options
# export SUP_ROW_LIMIT=5000
# export SUP_SECRET_KEY='domino'
# export SUP_CSRF_ENABLED=True
# export LC_ALL=C.UTF-8
# export LANG=C.UTF-8

export SUPERSET_HOME=$DOMINO_WORKING_DIR
export SUP_META_DB_URI=sqlite:///$DOMINO_WORKING_DIR/superset.db

#export ADDITIONAL_LAUNCH_OPTIONS="--debugger"
export ADDITIONAL_LAUNCH_OPTIONS=""

# export PYTHONPATH=$DOMINO_WORKING_DIR:$PYTHONPATH

# check to see if the superset config already exists, if it does skip to
# running the user supplied docker-entrypoint.sh, note that this means
# that users can copy over a prewritten superset config and that will be used
# without being modified
# echo "Checking for existing Superset config..."
# if [ ! -f $SUPERSET_HOME/superset_config_tmp.py ]; then
#   echo "No Superset config found, creating from environment"
#   touch $SUPERSET_HOME/superset_config_tmp.py

#   cat > $SUPERSET_HOME/superset_config_tmp.py <<EOF

# from flask import redirect, g, flash, request
# from flask_appbuilder.security.views import UserDBModelView,AuthDBView
# from superset.security import SupersetSecurityManager
# from flask_appbuilder.security.views import expose
# from flask_appbuilder.security.manager import BaseSecurityManager
# from flask_login import login_user, logout_user

# ROW_LIMIT = ${SUP_ROW_LIMIT}
# SECRET_KEY = '${SUP_SECRET_KEY}'
# SQLALCHEMY_DATABASE_URI = '${SUP_META_DB_URI}'
# CSRF_ENABLED = ${SUP_CSRF_ENABLED}
# HTTP_HEADERS = {}
# PREVENT_UNSAFE_DB_CONNECTIONS = False
# UPLOAD_FOLDER='/home/ubuntu/uploads/'
# IMG_UPLOAD_FOLDER= '/home/ubuntu/uploads/'

# class CustomAuthDBView(AuthDBView):
#     login_template = 'appbuilder/general/security/login_db.html'

#     @expose('/login/', methods=['GET', 'POST'])
#     def login(self):
#         redirect_url = self.appbuilder.get_url_for_index
#         if request.args.get('redirect') is not None:
#             redirect_url = request.args.get('redirect')

#         if not g.user.is_authenticated:
#             user = self.appbuilder.sm.find_user(username='admin')
#             login_user(user, remember=False)
#             return redirect(redirect_url)
#         elif g.user.is_authenticated:
#             return redirect(redirect_url)

# class CustomSecurityManager(SupersetSecurityManager):
#     authdbview = CustomAuthDBView
#     def __init__(self, appbuilder):
#         super(CustomSecurityManager, self).__init__(appbuilder)

# #CUSTOM_SECURITY_MANAGER = CustomSecurityManager

# CSV_EXTENSIONS = {"csv", "tsv", "txt", "tab"}

# EOF
# fi



# set up Superset if we haven't already
if [ ! -f $SUPERSET_HOME/.setup-complete ]; then

  echo "Running first time setup for Superset"
  superset fab create-admin --username admin --password superset --firstname Admin --lastname Superset --email superset+admin@example.com

  echo "Initializing database"
  superset db upgrade

#   echo "Loading examples"
#   superset load_examples

  echo "Creating default roles and permissions"
  superset init

  touch $SUPERSET_HOME/.setup-complete

else
  # always upgrade the database, running any pending migrations
  superset db upgrade
  superset init
fi

echo "Starting up Superset"
(superset run --host "0.0.0.0" --port 8088 --with-threads --reload $ADDITIONAL_LAUNCH_OPTIONS 3>&1 1>&2 2>&3 | grep -v DEBUG\: |grep -v WARN\:  | grep -v INFO\:) 3>&1 1>&2 2>&3
