FROM amd64/ubuntu:latest
MAINTAINER Emil Moe

RUN apt-get update
RUN apt-get upgrade -y

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

RUN apt-get install -y sudo apt-utils ca-certificates curl nodejs npm libsasl2-dev default-jre bzr node-less gdebi-core python-pip wkhtmltopdf

RUN apt-get install -y postgresql-client python-babel python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml
RUN apt-get install -y libturbojpeg libjpeg62-dev xfonts-75dpi xfonts-base
RUN apt-get install -y python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-pychart python-pydot python-pyparsing python-pypdf python-reportlab
RUN apt-get update
RUN apt-get install -y python-babel python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-requests python-suds python-tz python-vatnumber python-vobject python-werkzeug python-xlsxwriter python-xlwt python-yaml python-gevent python-greenlet python-markupsafe python-ofxparse python-pillow python-psycogreen python-qrcode python-six python-xlrd python-wsgiref python-pypdf2 python-simplejson python-webdav python-zsi python-unittest2 python-pil python-libsass
RUN pip install ebaysdk jcconv pyserial pytz pyusb suds-jurko Python-Chart num2words pyPdf pyyaml html2text ninja2 gdata chardet libsass

RUN echo "odoo ALL = NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /tmp

# Install Odoo
ENV ODOO_VERSION 10.0
ENV ODOO_RELEASE 20181126

RUN curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb
RUN echo 'a68f31336b103c9cc334d8eb2f88bd5e754b5d74 odoo.deb' | sha1sum -c -
RUN dpkg --force-depends -i odoo.deb
RUN apt-get update
RUN apt-get -y install -f --no-install-recommends
RUN rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
# COPY ./odoo.conf /etc/odoo/
# RUN chown odoo /etc/odoo/odoo.conf
RUN chown odoo /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Mount /var/lib/odoo to allow restoring filestore and /mnt/addons for users addons
RUN mkdir -p /mnt/addons \
        && chown -R odoo /mnt/addons
VOLUME ["/var/lib/odoo", "/mnt/addons", "/usr/lib/python2.7/dist-packages/odoo/addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
# ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
