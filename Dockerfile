FROM amd64/ubuntu:latest
MAINTAINER Emil Moe

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y apt-utils ca-certificates curl nodejs npm libsasl2-dev default-jre bzr node-less gdebi-core python-pip
# RUN apt-get install -y python-support python-gevent python-ldap python-renderpm python-vobject python-watchdog python-qrcode

RUN apt-get install -y postgresql-client python-babel python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml
RUN apt-get install -y libturbojpeg libjpeg62-dev xfonts-75dpi xfonts-base

WORKDIR /tmp

RUN curl -o wkhtmltox.deb -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.jessie_amd64.deb
RUN echo '4d104ff338dc2d2083457b3b1e9baab8ddf14202 wkhtmltox.deb' | sha1sum -c -
RUN dpkg --force-depends -i wkhtmltox.deb
RUN apt-get -y install -f --no-install-recommends
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm
RUN rm -rf /var/lib/apt/lists/* wkhtmltox.deb
# RUN pip install psycogreen==1.0

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
# RUN set -x; \
#         apt-get update \
#         && apt-get install -y --no-install-recommends \
#             ca-certificates \
#             curl \
#             nodejs \
#             npm \
#             libsasl2-dev \
#             default-jre \
#             bzr \
#             node-less \
#             python-gevent \
#             gdebi-core \
#             python-ldap \
#             python-pip \
#             python-qrcode \
#             python-renderpm \
#             python-support \
#             python-vobject \
#             python-watchdog \
#         && curl -o wkhtmltox.deb -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.jessie_amd64.deb \
#         && echo '4d104ff338dc2d2083457b3b1e9baab8ddf14202 wkhtmltox.deb' | sha1sum -c - \
#         && dpkg --force-depends -i wkhtmltox.deb \
#         && apt-get -y install -f --no-install-recommends \
#         && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
#         && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
#         && pip install psycogreen==1.0

# Install Odoo
ENV ODOO_VERSION 10.0
ENV ODOO_RELEASE 20181126

RUN curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb
RUN echo 'a68f31336b103c9cc334d8eb2f88bd5e754b5d74 odoo.deb' | sha1sum -c -
RUN dpkg --force-depends -i odoo.deb
RUN apt-get update
RUN apt-get -y install -f --no-install-recommends
RUN rm -rf /var/lib/apt/lists/* odoo.deb

# RUN set -x; \
#         curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
#         && echo 'a68f31336b103c9cc334d8eb2f88bd5e754b5d74 odoo.deb' | sha1sum -c - \
#         && dpkg --force-depends -i odoo.deb \
#         && apt-get update \
#         && apt-get -y install -f --no-install-recommends \
#         && rm -rf /var/lib/apt/lists/* odoo.deb

RUN apt-get install -y python-babel python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-requests python-suds python-tz python-vatnumber python-vobject python-werkzeug python-xlsxwriter python-xlwt python-yaml python-ebaysdk python-gevent python-greenlet python-jcconv python-markupsafe python-ofxparse python-pillow python-psycogreen python-pyserial python-pytz python-pyusb python-qrcode python-six python-xlrd python-wsgiref python-pypdf2 python-simplejson python-webdav python-zsi python-unittest2 python-pil python-libsass
RUN pip install suds-jurko pip install Python-Chart pip install num2words pip install pyPdf pip install pyyaml pip install html2text pip install ninja2 pip install gdata pip install chardet pip install libsass

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
RUN chown odoo /etc/odoo/odoo.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
