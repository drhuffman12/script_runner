REM ** Usage:
REM **   getinfo.bat <username> <password> <websphere_root> <target_host>
REM ** eg:
REM **   getinfo.bat abc xyz D:\MaximoSuite\WAS61\AppServer localhost

REM See "http://www.stevencharlesrobinson.com/sites/scrobinson.nsf/docs/Jython%20script%20to%20list%20ports%20on%20a%20WebSphere%20Node."

SET un=%1
SET pw=%2
REM SET ws_runtime_root=com.ibm.websphere.v61_6.1.202
SET was_root=%3
SET target_host=%4
REM SET output_path=jython\scripting\scripts
REM SET jython_scripts_root=.
SET jython_script_path=%5
REM SET jython_script_name=getinfo.py
SET jython_script_name=%6
REM SET output_path=%7
SET output_file_name=%7

REM %was_root%\bin\wsadmin.bat -username %un% -password %pw% -lang jython -f %jython_script_path%\%jython_script_name% -conntype SOAP -host %target_host% > %output_path%\%jython_script_name%.host(%target_host%).output

%was_root%\bin\wsadmin.bat -username %un% -password %pw% -lang jython -f %jython_script_path%\%jython_script_name% -conntype SOAP -host %target_host% > %output_file_name%
