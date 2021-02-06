FROM tomcat:8.5-jdk8

WORKDIR $CATALINA_HOME/webapps/identityiq

COPY identityiq.war $CATALINA_HOME/webapps/identityiq/

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN jar xvf identityiq.war

COPY iiq.properties $CATALINA_HOME/webapps/identityiq/WEB-INF/classes

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN chmod -R 777 --* && echo "import init.xml" | WEB-INF/bin/iiq console

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN chmod -R 777 $CATALINA_HOME/bin

WORKDIR $CATALINA_HOME/bin

CMD ["catalina.sh","run"]
