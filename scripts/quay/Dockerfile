FROM registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7

MAINTAINER Manny Evangelista <man@redhat.com>

LABEL com.redhat.component="jenkins-slave-image-mgmt" \
      name="skopeojenkinsslave" \
      architecture="x86_64" \
      io.k8s.display-name="Jenkins Slave Image Management" \
      io.k8s.description="Image management tools on top of the jenkins slave base image" \
      io.openshift.tags="openshift,jenkins,slave,copy"
USER root

RUN yum repolist > /dev/null && \
    yum clean all && \
    yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-extras-rpms  && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-ose-3.9-rpms && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    INSTALL_PKGS="skopeo python27-python-pip python-idna atomic docker openscap-utils scap-security-guide" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS


RUN yum install python27-python-pip -y && \
    scl enable python27 bash -y

RUN pip install --upgrade pip && \
    pip install --user docker && \ 
    pip install --user docker-py

RUN yum install python-idna -y && \
    yum install atomic -y

RUN yum install openscap-utils -y && \
    yum install scap-security-guide -y

USER 1001
