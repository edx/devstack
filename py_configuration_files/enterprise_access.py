from enterprise_access.settings.local import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', 'enterprise_access'),
        'USER': os.environ.get('DB_USER', 'enterprise_access001'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'password'),
        'HOST': os.environ.get('DB_HOST', 'edx.devstack.mysql80'),
        'PORT': os.environ.get('DB_PORT', 3306),
        'ATOMIC_REQUESTS': False,
        'CONN_MAX_AGE': 60,
    }
}


CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyMemcacheCache',
        'LOCATION': 'edx.devstack.memcached:11211',
    }
}


# Generic OAuth2 variables irrespective of SSO/backend service key types.
OAUTH2_PROVIDER_URL = 'http://edx.devstack.lms:18000/oauth2'

# OAuth2 variables specific to social-auth/SSO login use case.
SOCIAL_AUTH_EDX_OAUTH2_KEY = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_KEY', 'enterprise-access-sso-key')
SOCIAL_AUTH_EDX_OAUTH2_SECRET = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_SECRET', 'enterprise-access-sso-secret')
SOCIAL_AUTH_EDX_OAUTH2_ISSUER = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_ISSUER', 'http://localhost:18000')
SOCIAL_AUTH_EDX_OAUTH2_URL_ROOT = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_URL_ROOT', 'http://edx.devstack.lms:18000')
SOCIAL_AUTH_EDX_OAUTH2_LOGOUT_URL = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_LOGOUT_URL', 'http://localhost:18000/logout')
SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT = os.environ.get(
    'SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT', 'http://localhost:18000',
)

# OAuth2 variables specific to backend service API calls.
BACKEND_SERVICE_EDX_OAUTH2_KEY = os.environ.get(
    'BACKEND_SERVICE_EDX_OAUTH2_KEY', 'enterprise-access-backend-service-key')
BACKEND_SERVICE_EDX_OAUTH2_SECRET = os.environ.get(
    'BACKEND_SERVICE_EDX_OAUTH2_SECRET', 'enterprise-access-backend-service-secret')

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

# Install django-extensions for improved dev experiences
# https://github.com/django-extensions/django-extensions#using-it
INSTALLED_APPS += ('django_extensions',)

# BEGIN CELERY
CELERY_WORKER_HIJACK_ROOT_LOGGER = True
CELERY_TASK_ALWAYS_EAGER = (
    os.environ.get("CELERY_ALWAYS_EAGER", "false").lower() == "true"
)
# END CELERY


# CORS CONFIG
CORS_ORIGIN_WHITELIST = [
    'http://localhost:1991',  # frontend-app-admin-portal
    'http://localhost:8734',  # frontend-app-learner-portal-enterprise
    'http://localhost:18450',  # frontend-app-support-tools
]
# END CORS

# CSRF CONFIG
CSRF_TRUSTED_ORIGINS = [
    'http://localhost:1991',  # frontend-app-admin-portal
    'http://localhost:8734',  # frontend-app-learner-portal-enterprise
    'http://localhost:18450',  # frontend-app-support-tools
]
# END CSRF CONFIG

ECOMMERCE_URL = 'http://edx.devstack.ecommerce:18130'
LICENSE_MANAGER_URL = 'http://edx.devstack.license-manager:18170'
LMS_URL = 'http://edx.devstack.lms:18000'
DISCOVERY_URL = 'http://edx.devstack.discovery:18381'
ENTERPRISE_LEARNER_PORTAL_URL = 'http://localhost:8734'
ENTERPRISE_ADMIN_PORTAL_URL = 'http://localhost:1991'
ENTERPRISE_CATALOG_URL = 'http://edx.devstack.enterprise-catalog:18160'
ENTERPRISE_SUBSIDY_URL = 'http://edx.devstack.enterprise-subsidy:18280'
ENTERPRISE_ACCESS_URL = 'http://localhost:18270'

# shell_plus
SHELL_PLUS_IMPORTS = [
    'from enterprise_access.apps.api.serializers import *',
    'from enterprise_access.apps.api_client import *',
    'from enterprise_access.utils import localized_utcnow',
    'from enterprise_access.apps.content_assignments import api as assignments_api',
    'from pprint import pprint',
    'from enterprise_access.apps.content_assignments import tasks as assignments_tasks',
]


################### Kafka Related Settings ##############################

# "Standard" Kafka settings as defined in https://github.com/openedx/event-bus-kafka/tree/main
INSTALLED_APPS += ('edx_event_bus_kafka',)
EVENT_BUS_KAFKA_SCHEMA_REGISTRY_URL = 'http://edx.devstack.schema-registry:8081'
EVENT_BUS_KAFKA_BOOTSTRAP_SERVERS = 'edx.devstack.kafka:29092'
EVENT_BUS_PRODUCER = 'edx_event_bus_kafka.create_producer'
EVENT_BUS_CONSUMER = 'edx_event_bus_kafka.KafkaEventConsumer'
EVENT_BUS_TOPIC_PREFIX = 'dev'

# Potentially deprecated kafka settings
KAFKA_ENABLED = False
KAFKA_REPLICATION_FACTOR_PER_TOPIC = 1
COUPON_CODE_REQUEST_TOPIC_NAME = "coupon-code-request-dev"
LICENSE_REQUEST_TOPIC_NAME = "license-request-dev"
ACCESS_POLICY_TOPIC_NAME = "access-policy-dev"
SUBSIDY_REDEMPTION_TOPIC_NAME = "subsidy-redemption-dev"
KAFKA_TOPICS = [
    COUPON_CODE_REQUEST_TOPIC_NAME,
    LICENSE_REQUEST_TOPIC_NAME,

    # Access policy events
    ACCESS_POLICY_TOPIC_NAME,
    SUBSIDY_REDEMPTION_TOPIC_NAME,
]

################### End Kafka Related Settings ##############################
