@REM hydrocarbure-transport launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM HYDROCARBURE_TRANSPORT_config.txt found in the HYDROCARBURE_TRANSPORT_HOME.
@setlocal enabledelayedexpansion

@echo off

if "%HYDROCARBURE_TRANSPORT_HOME%"=="" set "HYDROCARBURE_TRANSPORT_HOME=%~dp0\\.."

set "APP_LIB_DIR=%HYDROCARBURE_TRANSPORT_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%HYDROCARBURE_TRANSPORT_HOME%\HYDROCARBURE_TRANSPORT_config.txt"
set CFG_OPTS=
if exist %CFG_FILE% (
  FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%CFG_FILE%") DO (
    set DO_NOT_REUSE_ME=%%i
    rem ZOMG (Part #2) WE use !! here to delay the expansion of
    rem CFG_OPTS, otherwise it remains "" for this loop.
    set CFG_OPTS=!CFG_OPTS! !DO_NOT_REUSE_ME!
  )
)

rem We use the value of the JAVACMD environment variable if defined
set _JAVACMD=%JAVACMD%

if "%_JAVACMD%"=="" (
  if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running hydrocarbure-transport.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)


rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

:param_loop
call set _PARAM1=%%1
set "_TEST_PARAM=%~1"

if ["!_PARAM1!"]==[""] goto param_afterloop


rem ignore arguments that do not start with '-'
if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
set _APP_ARGS=!_APP_ARGS! !_PARAM1!
shift
goto param_loop

:param_java_check
if "!_TEST_PARAM:~0,2!"=="-J" (
  rem strip -J prefix
  set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
  shift
  goto param_loop
)

if "!_TEST_PARAM:~0,2!"=="-D" (
  rem test if this was double-quoted property "-Dprop=42"
  for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
    if not ["%%H"] == [""] (
      set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
    ) else if [%2] neq [] (
      rem it was a normal property: -Dprop=42 or -Drop="42"
      call set _PARAM1=%%1=%%2
      set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      shift
    )
  )
) else (
  if "!_TEST_PARAM!"=="-main" (
    call set CUSTOM_MAIN_CLASS=%%2
    shift
  ) else (
    set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  )
)
shift
goto param_loop
:param_afterloop

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!
:run
 
set "APP_CLASSPATH=%APP_LIB_DIR%\hydrocarbure-transport.hydrocarbure-transport-1.0.jar;%APP_LIB_DIR%\xmlbeans-2.6.0.jar;%APP_LIB_DIR%\libswing-6.0.1.0-386.jar;%APP_LIB_DIR%\itext-2.1.7.jar;%APP_LIB_DIR%\postgresql-9.4-1201-jdbc41.jar;%APP_LIB_DIR%\bcprov-jdk14-138.jar;%APP_LIB_DIR%\eigenbase-resgen.jar;%APP_LIB_DIR%\libpixie-6.0.1.0-386.jar;%APP_LIB_DIR%\commons-lang.jar;%APP_LIB_DIR%\libxml-6.0.1.0-386.jar;%APP_LIB_DIR%\commons-dbcp.jar;%APP_LIB_DIR%\mail-1.4.1.jar;%APP_LIB_DIR%\libbase-6.0.1.0-386.jar;%APP_LIB_DIR%\xmlunit.jar;%APP_LIB_DIR%\xalan.jar;%APP_LIB_DIR%\mondrian.jar;%APP_LIB_DIR%\libformula-6.0.1.0-386.jar;%APP_LIB_DIR%\commons-pool.jar;%APP_LIB_DIR%\bsf-2.4.0.jar;%APP_LIB_DIR%\poi-ooxml-schemas-3.12.jar;%APP_LIB_DIR%\librepository-6.0.1.0-386.jar;%APP_LIB_DIR%\servlet-api-2.4.jar;%APP_LIB_DIR%\commons-io.jar;%APP_LIB_DIR%\batik-css-1.7.jar;%APP_LIB_DIR%\commons-logging.jar;%APP_LIB_DIR%\batik-util-1.7.jar;%APP_LIB_DIR%\log4j.jar;%APP_LIB_DIR%\libloader-6.0.1.0-386.jar;%APP_LIB_DIR%\log4j-1.2.16.jar;%APP_LIB_DIR%\servlet-api-2.5.jar;%APP_LIB_DIR%\batik-svg-dom-1.7.jar;%APP_LIB_DIR%\poi-3.12.jar;%APP_LIB_DIR%\bcmail-jdk14-138.jar;%APP_LIB_DIR%\jlfgr.jar;%APP_LIB_DIR%\eigenbase-properties.jar;%APP_LIB_DIR%\libformat-6.0.1.0-386.jar;%APP_LIB_DIR%\js-1.7R1.jar;%APP_LIB_DIR%\libdocbundle-6.0.1.0-386.jar;%APP_LIB_DIR%\hsqldb-2.3.2.jar;%APP_LIB_DIR%\rsyntaxtextarea-1.3.2.jar;%APP_LIB_DIR%\batik-anim-1.7.jar;%APP_LIB_DIR%\libserializer-6.0.1.0-386.jar;%APP_LIB_DIR%\workbench.jar;%APP_LIB_DIR%\groovy-1.8.0.jar;%APP_LIB_DIR%\batik-bridge-1.7.jar;%APP_LIB_DIR%\ehcache-core-2.5.1.jar;%APP_LIB_DIR%\libfonts-6.0.1.0-386.jar;%APP_LIB_DIR%\commons-collections.jar;%APP_LIB_DIR%\batik-script-1.7.jar;%APP_LIB_DIR%\xml-apis.jar;%APP_LIB_DIR%\asm-3.2.jar;%APP_LIB_DIR%\xercesImpl.jar;%APP_LIB_DIR%\itext-rtf-2.1.7.jar;%APP_LIB_DIR%\batik-parser-1.7.jar;%APP_LIB_DIR%\commons-math.jar;%APP_LIB_DIR%\batik-awt-util-1.7.jar;%APP_LIB_DIR%\poi-ooxml-3.12.jar;%APP_LIB_DIR%\batik-gui-util-1.7.jar;%APP_LIB_DIR%\batik-gvt-1.7.jar;%APP_LIB_DIR%\javacup.jar;%APP_LIB_DIR%\bsh-1.3.0.jar;%APP_LIB_DIR%\flute-6.0.1.0-386.jar;%APP_LIB_DIR%\batik-dom-1.7.jar;%APP_LIB_DIR%\commons-vfs.jar;%APP_LIB_DIR%\pentaho-database-model-6.0.1.0-386.jar;%APP_LIB_DIR%\olap4j.jar;%APP_LIB_DIR%\pentaho-reporting-engine-classic-core-6.0.1.0-386.jar;%APP_LIB_DIR%\xml-apis-ext-1.3.04.jar;%APP_LIB_DIR%\eigenbase-xom.jar;%APP_LIB_DIR%\batik-ext-1.7.jar;%APP_LIB_DIR%\commons-vfs2.jar;%APP_LIB_DIR%\batik-xml-1.7.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.11.7.jar;%APP_LIB_DIR%\com.typesafe.play.twirl-api_2.11-1.1.1.jar;%APP_LIB_DIR%\org.apache.commons.commons-lang3-3.4.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-xml_2.11-1.0.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-enhancer-1.1.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-server_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.build-link-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-exceptions-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-iteratees_2.11-2.5.4.jar;%APP_LIB_DIR%\org.scala-stm.scala-stm_2.11-0.7.jar;%APP_LIB_DIR%\com.typesafe.config-1.3.0.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.1.7.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.1.7.jar;%APP_LIB_DIR%\com.typesafe.play.play-json_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-functional_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-datacommons_2.11-2.5.4.jar;%APP_LIB_DIR%\joda-time.joda-time-2.9.2.jar;%APP_LIB_DIR%\org.joda.joda-convert-1.8.1.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.11.7.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.7.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.7.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.7.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jdk8-2.7.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jsr310-2.7.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-netty-utils-2.5.4.jar;%APP_LIB_DIR%\org.slf4j.jul-to-slf4j-1.7.19.jar;%APP_LIB_DIR%\org.slf4j.jcl-over-slf4j-1.7.19.jar;%APP_LIB_DIR%\com.typesafe.play.play-streams_2.11-2.5.4.jar;%APP_LIB_DIR%\org.reactivestreams.reactive-streams-1.0.0.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-stream_2.11-2.4.4.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-actor_2.11-2.4.4.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-java8-compat_2.11-0.7.0.jar;%APP_LIB_DIR%\com.typesafe.ssl-config-akka_2.11-0.2.1.jar;%APP_LIB_DIR%\com.typesafe.ssl-config-core_2.11-0.2.1.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-parser-combinators_2.11-1.0.4.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-slf4j_2.11-2.4.4.jar;%APP_LIB_DIR%\commons-codec.commons-codec-1.10.jar;%APP_LIB_DIR%\xerces.xercesImpl-2.11.0.jar;%APP_LIB_DIR%\xml-apis.xml-apis-1.4.01.jar;%APP_LIB_DIR%\javax.transaction.jta-1.1.jar;%APP_LIB_DIR%\com.google.inject.guice-4.0.jar;%APP_LIB_DIR%\javax.inject.javax.inject-1.jar;%APP_LIB_DIR%\aopalliance.aopalliance-1.0.jar;%APP_LIB_DIR%\com.google.inject.extensions.guice-assistedinject-4.0.jar;%APP_LIB_DIR%\com.typesafe.play.play-java_2.11-2.5.4.jar;%APP_LIB_DIR%\org.yaml.snakeyaml-1.16.jar;%APP_LIB_DIR%\org.hibernate.hibernate-validator-5.2.4.Final.jar;%APP_LIB_DIR%\javax.validation.validation-api-1.1.0.Final.jar;%APP_LIB_DIR%\javax.el.javax.el-api-3.0.0.jar;%APP_LIB_DIR%\org.springframework.spring-context-4.2.4.RELEASE.jar;%APP_LIB_DIR%\org.springframework.spring-core-4.2.4.RELEASE.jar;%APP_LIB_DIR%\org.springframework.spring-beans-4.2.4.RELEASE.jar;%APP_LIB_DIR%\org.reflections.reflections-0.9.10.jar;%APP_LIB_DIR%\com.google.guava.guava-19.0.jar;%APP_LIB_DIR%\net.jodah.typetools-0.4.4.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-3.0.1.jar;%APP_LIB_DIR%\org.apache.tomcat.tomcat-servlet-api-8.0.33.jar;%APP_LIB_DIR%\com.typesafe.play.play-netty-server_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.netty.netty-reactive-streams-http-1.0.6.jar;%APP_LIB_DIR%\com.typesafe.netty.netty-reactive-streams-1.0.6.jar;%APP_LIB_DIR%\io.netty.netty-handler-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-buffer-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-common-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-http-4.0.36.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-native-epoll-4.0.36.Final-linux-x86_64.jar;%APP_LIB_DIR%\com.typesafe.play.play-logback_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-java-jdbc_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc-api_2.11-2.5.4.jar;%APP_LIB_DIR%\com.jolbox.bonecp-0.8.0.RELEASE.jar;%APP_LIB_DIR%\com.zaxxer.HikariCP-2.4.3.jar;%APP_LIB_DIR%\com.googlecode.usc.jdbcdslog-1.0.6.2.jar;%APP_LIB_DIR%\com.h2database.h2-1.4.191.jar;%APP_LIB_DIR%\tyrex.tyrex-1.0.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-cache_2.11-2.5.4.jar;%APP_LIB_DIR%\net.sf.ehcache.ehcache-core-2.6.11.jar;%APP_LIB_DIR%\com.typesafe.play.play-java-ws_2.11-2.5.4.jar;%APP_LIB_DIR%\com.typesafe.play.play-ws_2.11-2.5.4.jar;%APP_LIB_DIR%\org.asynchttpclient.async-http-client-2.0.2.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-resolver-dns-2.0.2.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-resolver-2.0.2.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.21.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-codec-dns-2.0.2.jar;%APP_LIB_DIR%\org.javassist.javassist-3.20.0-GA.jar;%APP_LIB_DIR%\oauth.signpost.signpost-core-1.2.1.2.jar;%APP_LIB_DIR%\oauth.signpost.signpost-commonshttp4-1.2.1.2.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpcore-4.0.1.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpclient-4.0.1.jar;%APP_LIB_DIR%\commons-logging.commons-logging-1.1.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-java-jpa_2.11-2.5.4.jar;%APP_LIB_DIR%\org.hibernate.javax.persistence.hibernate-jpa-2.1-api-1.0.0.Final.jar;%APP_LIB_DIR%\org.hibernate.hibernate-entitymanager-5.1.0.Final.jar;%APP_LIB_DIR%\org.jboss.logging.jboss-logging-3.3.0.Final.jar;%APP_LIB_DIR%\org.hibernate.hibernate-core-5.1.0.Final.jar;%APP_LIB_DIR%\antlr.antlr-2.7.7.jar;%APP_LIB_DIR%\org.apache.geronimo.specs.geronimo-jta_1.1_spec-1.1.1.jar;%APP_LIB_DIR%\org.jboss.jandex-2.0.0.Final.jar;%APP_LIB_DIR%\com.fasterxml.classmate-1.3.0.jar;%APP_LIB_DIR%\dom4j.dom4j-1.6.1.jar;%APP_LIB_DIR%\org.hibernate.common.hibernate-commons-annotations-5.0.1.Final.jar;%APP_LIB_DIR%\org.postgresql.postgresql-9.4-1201-jdbc41.jar;%APP_LIB_DIR%\hydrocarbure-transport.hydrocarbure-transport-1.0-assets.jar"
set "APP_MAIN_CLASS=play.core.server.ProdServerStart"

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !HYDROCARBURE_TRANSPORT_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal


:end

exit /B %ERRORLEVEL%
