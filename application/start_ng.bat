
SET graphviz_root=D:\graphviz
PATH=%graphviz_root%\bin;%PATH%

SET git_root=C:\_apps_\_dev_\_source_control_\_git_\PortableGit
PATH=%git_root%\bin;%PATH%

REM echo " ******************************************************** "
SET starting_path=%~dp0
SET jruby_jar=jruby-complete.jar
SET jdbc_jar=jdbcmssql-gems.jar
SET main_script=start.rb

SET log_path=%starting_path%log\
SET new_log=scripts.log
SET old_log=%new_log%.old
if exist "%log_path%%old_log%" del "%log_path%%old_log%"
if exist "%log_path%%new_log%" rename "%log_path%%new_log%" "%old_log%"
if exist "%log_path%%new_log%" del "%log_path%%new_log%"

SET log_path=%starting_path%
SET new_log=%main_script%.log
SET old_log=%new_log%.old
if exist "%log_path%%old_log%" del "%log_path%%old_log%"
if exist "%log_path%%new_log%" rename "%log_path%%new_log%" "%old_log%"
if exist "%log_path%%new_log%" del "%log_path%%new_log%"

REM if exist %main_script%.log.old del %main_script%.log.old
REM if exist %main_script%.log rename "%main_script%.log" "%main_script%.log.old"
REM echo 'if exist %main_script%.log rename "%main_script%.log" "%main_script%.log.old"'

REM java -ng -classpath "*.jar" -jar %jruby_jar% -S %main_script%
REM java -Xss1024m -Xms1024m -Xmx1024m -Xmn256m -XX:MaxHeapSize=134217728 -XX:+HeapDumpOnOutOfMemoryError -classpath "*.jar" -jar %jruby_jar% -X+O --server --fast -S %main_script% --ng > %starting_path%%main_script%.log
java -Xms1024m -Xmx1024m -Xmn256m -classpath "*.jar" -jar %jruby_jar% -X+O -S %main_script% --ng > %starting_path%%main_script%.log

REM -J-Xss10240k
REM echo " ================================================================ "


REM jruby -J-verbose:gc -J-XX:+PrintGCTimeStamps -J-XX:+PrintGCDetails -J-Xloggc:./gc.log -J-XX:+DisableExplicitGC -J-Xmx512m -S glassfish -e production [1]
