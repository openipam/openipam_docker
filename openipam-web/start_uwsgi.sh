#!/bin/bash

conf_base='/usr/local/django-openipam/openipam/conf'
conf_file="$conf_base/local_settings.py"

cat << EOF > $conf_file
try:
    import psycopg2
except:
    from psycopg2ct import compat
    compat.register()

$(
if [ -n "$AUTHENTICATION_TYPE" ]; then
    if [ "$AUTHENTICATION_TYPE" = "AD" ]; then
cat << __AD_LDAP_EOF__
import ldap
from django_auth_ldap.config import LDAPSearch, ActiveDirectoryGroupType

import os

import json

LOCAL_AUTHENTICATION_BACKENDS = (
    'openipam.core.backends.IPAMLDAPBackend',
)

AUTH_LDAP_SERVER_URI = '$AD_LDAP_SERVER_URI'
AUTH_LDAP_BIND_DN = '$AD_LDAP_BIND_DN'
AUTH_LDAP_BIND_PASSWORD = '$AD_LDAP_BIND_PASSWORD'
AUTH_LDAP_USER_SEARCH = LDAPSearch(
    '$AD_LDAP_USER_BASE',
    ldap.SCOPE_SUBTREE,
    '$AD_LDAP_USER_FILTER',
)

# AUTH_LDAP_USER_DN_TEMPLATE = 'uid=%(user)s,ou=banner,dc=aggies,dc=usu,dc=edu'

AUTH_LDAP_GROUP_SEARCH = LDAPSearch('$AD_LDAP_GROUP_BASE',
                                    ldap.SCOPE_SUBTREE,
                                    '$AD_LDAP_GROUP_FILTER')

AUTH_LDAP_GROUP_TYPE = ActiveDirectoryGroupType()

AUTH_LDAP_USER_ATTR_MAP = {
    'first_name': '$AD_LDAP_FIRST_NAME_ATTRIBUTE',
    'last_name': '$AD_LDAP_LAST_NAME_ATTRIBUTE',
    'email': '$AD_LDAP_MAIL_ATTRIBUTE',
}

AUTH_LDAP_GLOBAL_OPTIONS = {
    ldap.OPT_X_TLS_REQUIRE_CERT: $AD_LDAP_TLS_REQCERT,
    ldap.OPT_REFERRALS: False,
}

# AUTH_LDAP_FIND_GROUP_PERMS = True
# AUTH_LDAP_CACHE_GROUPS = True
# AUTH_LDAP_GROUP_CACHE_TIMEOUT = 300
AUTH_LDAP_ALWAYS_UPDATE_USER = True
AUTH_LDAP_MIRROR_GROUPS = True

__AD_LDAP_EOF__
    fi
fi
)

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

$(
if [ -n "$EMAIL_HOST" ]; then
    echo "EMAIL_HOST = '$EMAIL_HOST'"
fi
)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

INTERNAL_IPS = ('127.0.0.1',)

SESSION_COOKIE_SECURE = True
SESSION_EXPIRE_BROWSER_CLOSE = True
SESSION_COOKIE_AGE = ${SESSION_COOKIE_AGE:-28800}

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

OPENIPAM = {
$(
if [ -n "$GUEST_PREFIX" -a -n "$GUEST_SUFFIX" ]; then
    echo -e "    'GUEST_HOSTNAME_FORMAT': ['$GUEST_PREFIX', '$GUEST_SUFFIX'],\n"
fi

if [ -n "$CAS_LOGIN_URL" ]; then
    echo "    'CAS_LOGIN': '$CAS_LOGIN_URL',"
else
    echo "    'CAS_LOGIN': False,"
fi

if [ -n "$DUO_HOST" ]; then
cat << __DUO_EOF__
    'DUO_LOGIN': True,
    'DUO_SETTINGS': {
        'IKEY': '$DUO_IKEY',
        'SKEY': '$DUO_SKEY',
        'AKEY': '$DUO_AKEY',
        'HOST': '$DUO_HOST',
    },
__DUO_EOF__
fi

if [ -n "$WEATHERMAP_DATA_JSON" ]; then
cat << __WEATHERMAP_EOF__
    'WEATHERMAP_DATA': json.loads("""$WEATHERMAP_DATA_JSON"""),
__WEATHERMAP_EOF__
fi
)
}

$(
if [ -n "$LOCAL_SETTINGS_APPEND" ] ; then
    echo "$LOCAL_SETTINGS_APPEND" | base64 -d | gunzip
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

# cat openipam-web/start_uwsgi.sh | grep -Eo -e '\$[A-Z_]+' openipam-web/start_uwsgi.sh | sort -u | sed 's/^\$/unset /'
unset AD_LDAP_BIND_DN
unset AD_LDAP_BIND_PASSWORD
unset AD_LDAP_FIRST_NAME_ATTRIBUTE
unset AD_LDAP_GROUP_BASE
unset AD_LDAP_GROUP_FILTER
unset AD_LDAP_LAST_NAME_ATTRIBUTE
unset AD_LDAP_MAIL_ATTRIBUTE
unset AD_LDAP_SERVER_URI
unset AD_LDAP_TLS_REQCERT
unset AD_LDAP_USER_BASE
unset AD_LDAP_USER_FILTER
unset AUTHENTICATION_TYPE
unset CAS_LOGIN_URL
unset DB_DATABASE
unset DB_HOST
unset DB_PASSWORD
unset DB_PORT
unset DB_USERNAME
unset DEBUG
unset DUO_AKEY
unset DUO_HOST
unset DUO_IKEY
unset DUO_SKEY
unset EMAIL_HOST
unset GUEST_PREFIX
unset GUEST_SUFFIX
unset LOCAL_SECRET_KEY
unset RAVEN_DSN
unset STARTUP_DEBUG
unset UWSGI_ADD_ARGS
unset WEATHERMAP_DATA_JSON

exec /usr/bin/uwsgi_python27 --ini=/etc/uwsgi/uwsgi.ini --master $uwsgi_add_args
