# Dockerfile that builds a fully functional image of your app.
#
# This image installs all Python dependencies for your application. It's based
# on CentOS 7 with Python 3 (https://github.com/inveniosoftware/docker-invenio)
# and includes Pip, Pipenv, Node.js, NPM and some few standard libraries
# Invenio usually needs.
#
# Note: It is important to keep the commands in this file in sync with your
# bootstrap script located in ./scripts/bootstrap.

FROM inveniosoftware/centos8-python:3.8

# Clone custom repositories
RUN git clone --depth 1 --branch v0.2 https://github.com/ingv-oe-dev/invenio-assets.git ../invenio-assets
RUN git clone --depth 1 --branch maint-10.x https://github.com/ingv-oe-dev/invenio-app-rdm.git ../invenio-app-rdm
RUN git clone --depth 1 --branch maint-0.39.x https://github.com/ingv-oe-dev/invenio-rdm-records.git ../invenio-rdm-records
RUN git clone --depth 1 --branch master https://github.com/ingv-oe-dev/invenio-accounts.git ../invenio-accounts
RUN git clone --depth 1 --branch improve-proj https://github.com/ingv-oe-dev/oedatarep-ts-loader.git ../oedatarep-ts-loader

COPY Pipfile Pipfile.lock ./
RUN pipenv install --deploy --system

COPY ./docker/uwsgi/ ${INVENIO_INSTANCE_PATH}
COPY ./invenio.cfg ${INVENIO_INSTANCE_PATH}
COPY ./templates/ ${INVENIO_INSTANCE_PATH}/templates/
COPY ./app_data/ ${INVENIO_INSTANCE_PATH}/app_data/
COPY ./ .

RUN cp -r ./static/. ${INVENIO_INSTANCE_PATH}/static/ && \
    cp -r ./assets/. ${INVENIO_INSTANCE_PATH}/assets/ && \
    invenio collect --verbose  && \
    invenio webpack create && \
    invenio webpack install --unsafe && \
    invenio webpack build

ENTRYPOINT [ "bash", "-c"]
