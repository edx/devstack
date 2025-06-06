from enterprise_catalog.settings.local import *

# Generic OAuth2 variables irrespective of SSO/backend service key types.
OAUTH2_PROVIDER_URL = 'http://edx.devstack.lms:18000/oauth2'

# OAuth2 variables specific to social-auth/SSO login use case.
SOCIAL_AUTH_EDX_OAUTH2_KEY = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_KEY', 'enterprise-catalog-sso-key')
SOCIAL_AUTH_EDX_OAUTH2_SECRET = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_SECRET', 'enterprise-catalog-sso-secret')
SOCIAL_AUTH_EDX_OAUTH2_ISSUER = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_ISSUER', 'http://localhost:18000')
SOCIAL_AUTH_EDX_OAUTH2_URL_ROOT = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_URL_ROOT', 'http://edx.devstack.lms:18000')
SOCIAL_AUTH_EDX_OAUTH2_LOGOUT_URL = os.environ.get('SOCIAL_AUTH_EDX_OAUTH2_LOGOUT_URL', 'http://localhost:18000/logout')
SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT = os.environ.get(
    'SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT', 'http://localhost:18000',
)

# OAuth2 variables specific to backend service API calls.
BACKEND_SERVICE_EDX_OAUTH2_KEY = os.environ.get('BACKEND_SERVICE_EDX_OAUTH2_KEY', 'enterprise-catalog-backend-service-key')
BACKEND_SERVICE_EDX_OAUTH2_SECRET = os.environ.get('BACKEND_SERVICE_EDX_OAUTH2_SECRET', 'enterprise-catalog-backend-service-secret')

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

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DB_NAME', 'enterprise_catalog'),
        'USER': os.environ.get('DB_USER', 'catalog001'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'password'),
        'HOST': os.environ.get('DB_HOST', 'edx.devstack.mysql80'),
        'PORT': os.environ.get('DB_PORT', 3306),
        'ATOMIC_REQUESTS': False,
        'CONN_MAX_AGE': 60,
        # The default isolation level for MySQL is REPEATABLE READ, which is a little too aggressive
        # for our needs, particularly around reading celery task state via django-celery-results.
        # https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html#isolevel_read-committed
        'OPTIONS': {
            'isolation_level': 'read committed',
        },
    }
}

ALLOWED_HOSTS = ['*']

LMS_BASE_URL = 'http://edx.devstack.lms:18000'
DISCOVERY_SERVICE_API_URL = 'http://edx.devstack.discovery:18381/api/v1/'
DISCOVERY_SERVICE_URL = 'http://edx.devstack.discovery:18381/'
ENTERPRISE_LEARNER_PORTAL_BASE_URL = 'http://localhost:8734'
ECOMMERCE_BASE_URL = 'http://edx.devstack.ecommerce:18130'
LICENSE_MANAGER_BASE_URL = 'http://license-manager.app:18170'
STUDIO_BASE_URL = 'http://edx.devstack.lms:18010'

CELERY_WORKER_HIJACK_ROOT_LOGGER = True
CELERY_TASK_ALWAYS_EAGER = (
    os.environ.get("CELERY_ALWAYS_EAGER", "false").lower() == "true"
)

CORS_ORIGIN_WHITELIST = [
    # Enterprise learner portal MFE
    'http://localhost:8734',
    'http://localhost:18160',
    'http://localhost:18000',
    'http://localhost:18130',
    # Enterprise admin portal MFE
    'http://localhost:1991',
    # Enterprise explore catalog MFE
    'http://localhost:8735',
]

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyMemcacheCache',
        'LOCATION': 'edx.devstack.memcached:11211',
    }
}

CHAT_COMPLETION_API = 'http://test.chat.ai'
CHAT_COMPLETION_API_KEY = 'test chat completion api key'
CHAT_COMPLETION_API_CONNECT_TIMEOUT = 1
CHAT_COMPLETION_API_READ_TIMEOUT = 15
