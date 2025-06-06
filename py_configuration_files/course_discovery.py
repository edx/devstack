# noinspection PyUnresolvedReferences
from course_discovery.settings._debug_toolbar import *  # isort:skip

from course_discovery.settings.production import *

DEBUG = True

# Docker does not support the syslog socket at /dev/log. Rely on the console.
LOGGING['handlers']['local'] = {
    'class': 'logging.NullHandler',
}

# Determine which requests should render Django Debug Toolbar
INTERNAL_IPS = ('127.0.0.1',)

CORS_ORIGIN_WHITELIST = (
    'http://localhost:8734',  # frontend-app-learner-portal-enterprise
    'http://localhost:1991',  # frontend-app-admin-portal
    'http://localhost:18400',  # frontend-app-publisher
    'http://localhost:18450',  # frontend-app-support-tools
    'http://localhost:2000',  # frontend-app-learning
)

ELASTICSEARCH_DSL['default']['hosts'] = 'edx.devstack.elasticsearch710:9200'

# Expand change threshold to something more forgiving, especially in local development scenarios where the count goes
# from 1->2 (100% change).
INDEX_SIZE_CHANGE_THRESHOLD = 1.01  # 101%

SOCIAL_AUTH_REDIRECT_IS_HTTPS = False

JWT_AUTH.update({
    'JWT_SECRET_KEY': 'lms-secret',
    'JWT_ISSUER': 'http://localhost:18000/oauth2',
    'JWT_AUDIENCE': None,
    'JWT_VERIFY_AUDIENCE': False,
    'JWT_PUBLIC_SIGNING_JWK_SET': (
        '{"keys": [{"kid": "devstack_key", "e": "AQAB", "kty": "RSA", "n": "smKFSYowG6nNUAdeqH1jQQnH1PmIHphzBmwJ5vRf1vu'
        '48BUI5VcVtUWIPqzRK_LDSlZYh9D0YFL0ZTxIrlb6Tn3Xz7pYvpIAeYuQv3_H5p8tbz7Fb8r63c1828wXPITVTv8f7oxx5W3lFFgpFAyYMmROC'
        '4Ee9qG5T38LFe8_oAuFCEntimWxN9F3P-FJQy43TL7wG54WodgiM0EgzkeLr5K6cDnyckWjTuZbWI-4ffcTgTZsL_Kq1owa_J2ngEfxMCObnzG'
        'y5ZLcTUomo4rZLjghVpq6KZxfS6I1Vz79ZsMVUWEdXOYePCKKsrQG20ogQEkmTf9FT_SouC6jPcHLXw"}]}'
    ),
    'JWT_ISSUERS': [{
        'AUDIENCE': 'lms-key',
        'ISSUER': 'http://localhost:18000/oauth2',
        'SECRET_KEY': 'lms-secret',
    }],
})

# MEDIA CONFIGURATION
# See: https://docs.djangoproject.com/en/dev/ref/settings/#media-url
MEDIA_ROOT = root('media')
# LOCAL_MEDIA_URL was added to support external services like edx-mktg retrieving
# static files in DEBUG and local Devstack
LOCAL_DISCOVERY_MEDIA_URL = '/media/'
MEDIA_URL = 'http://localhost:18381' + LOCAL_DISCOVERY_MEDIA_URL
# END MEDIA CONFIGURATION

DEFAULT_PARTNER_ID = 1

# Allow live changes to JS and CSS
COMPRESS_OFFLINE = False
COMPRESS_ENABLED = False

PARLER_LANGUAGES = {
    1: (
        {'code': LANGUAGE_CODE, },
        {'code': 'es', },
    ),
    'default': {
         'fallbacks': [PARLER_DEFAULT_LANGUAGE_CODE],
         'hide_untranslated': False,
     }
}

SOCIAL_AUTH_EDX_OAUTH2_ISSUER = "http://localhost:18000"
SOCIAL_AUTH_EDX_OAUTH2_URL_ROOT = "http://edx.devstack.lms:18000"
SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT = "http://localhost:18000"
SOCIAL_AUTH_EDX_OAUTH2_LOGOUT_URL = "http://localhost:18000/logout"

BACKEND_SERVICE_EDX_OAUTH2_PROVIDER_URL = "http://edx.devstack.lms:18000/oauth2"

ENABLE_PUBLISHER = True

ORG_BASE_LOGO_URL = "http://discovery:18381/media/"

CELERY_TASK_ALWAYS_EAGER = False

#################### Event bus backend ########################
INSTALLED_APPS += ('edx_event_bus_kafka',)
EVENT_BUS_KAFKA_SCHEMA_REGISTRY_URL = 'http://edx.devstack.schema-registry:8081'
EVENT_BUS_KAFKA_BOOTSTRAP_SERVERS = 'edx.devstack.kafka:29092'
EVENT_BUS_PRODUCER = 'edx_event_bus_kafka.create_producer'
EVENT_BUS_CONSUMER = 'edx_event_bus_kafka.KafkaEventConsumer'
EVENT_BUS_TOPIC_PREFIX = 'dev'

#####################################################################
# Lastly, see if the developer has any local overrides.
if os.path.isfile(join(dirname(abspath(__file__)), 'private.py')):
    from .private import *  # pylint: disable=import-error

DISCOVERY_BASE_URL = "http://edx.devstack.discovery:18381"
