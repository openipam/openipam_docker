#!/bin/bash

conf_file='/usr/local/django-openipam/openipam/conf/local_settings.py'

cat << EOF > $conf_file
try:
    import psycopg2
except:
    from psycopg2ct import compat
    compat.register()

$(
if [ "$DEBUG" == "True" ]; then
cat << EOF_DEBUG
DEBUG = True

DEBUG_TOOLBAR_PANELS = (
    'debug_toolbar.panels.versions.VersionsPanel',
    'debug_toolbar.panels.timer.TimerPanel',
    'debug_toolbar.panels.settings.SettingsPanel',
    'debug_toolbar.panels.headers.HeadersPanel',
    'debug_toolbar.panels.request.RequestPanel',
    'debug_toolbar.panels.sql.SQLPanel',
    'debug_toolbar.panels.staticfiles.StaticFilesPanel',
    'debug_toolbar.panels.templates.TemplatesPanel',
    'debug_toolbar.panels.cache.CachePanel',
    'debug_toolbar.panels.signals.SignalsPanel',
    'debug_toolbar.panels.logging.LoggingPanel',
    'debug_toolbar.panels.redirects.RedirectsPanel',
)
EOF_DEBUG
else
	echo "DEBUG = False"
fi
)

ALLOWED_HOSTS = ['*']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',  # we are using some postgresql specific features
        'NAME': '$DB_DATABASE',                  # Or path to database file if using sqlite3.
        'USER': '$DB_USERNAME',                  # Not used with sqlite3.
        'PASSWORD': '$DB_PASSWORD',              # Not used with sqlite3.
        'HOST': '$DB_HOST',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '$DB_PORT',                      # Set to empty string for default. Not used with sqlite3.
        'ATOMIC_REQUESTS': True,
        'CONN_MAX_AGE': 600
    }
}

#EMAIL_HOST = 'mail.usu.edu'
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

INTERNAL_IPS = ('127.0.0.1',)

# SESSION_COOKIE_SECURE = True
# SESSION_EXPIRE_BROWSER_CLOSE = True

LOCAL_SECRET_KEY = '$LOCAL_SECRET_KEY'

LOCAL_MIDDLEWARE_CLASSES = [
    # Debug Toolbar
    #'debug_toolbar.middleware.DebugToolbarMiddleware',
    #'djangopad.middleware.sql_log.SQLLogMiddleware',
]

LOCAL_INSTALLED_APPS = (
$(
if [ -n $RAVEN_DSN ]; then
    echo "    'raven.contrib.django.raven_compat',"
fi
)
)

$(
if [ -n "$RAVEN_DSN" ]; then
    echo -e "RAVEN_CONFIG = {\n    'dsn': '$RAVEN_DSN'\n}"
fi
)

EOF

if [ "$STARTUP_DEBUG" == "True" ]; then
    echo "# $conf_file"
    cat $conf_file
    echo "# env"
    env
fi

uwsgi_add_args=$UWSGI_ADD_ARGS

unset DB_DATABASE DB_USERNAME DB_PASSWORD DB_HOST DB_PORT LOCAL_SECRET_KEY RAVEN_DSN UWSGI_ADD_ARGS

exec /usr/bin/uwsgi_python27 --ini=/etc/uwsgi/uwsgi.ini --master --enable-threads \
    --uid=openipam --gid=openipam  $uwsgi_add_args

