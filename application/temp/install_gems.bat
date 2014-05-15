REM cd D:\FGG_SVN\MaximoScriptGeneratorAndUtils

REM Update RubyGems:
java -jar jruby-complete.jar -S gem -v
REM java -jar jruby-complete.jar -S gem update --system
REM java -jar jruby-complete.jar -S jgem update --system

REM Install Gems:
java -jar jruby-complete.jar -S gem install -i jdbcmssql addressable --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql faker --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql hoe --no-rdoc --no-ri
REM # java -jar jruby-complete.jar -S gem install -i jdbcmssql pg --no-rdoc --no-ri # 'native' gem errors
java -jar jruby-complete.jar -S gem install -i jdbcmssql rbench --no-rdoc --no-ri

java -jar jruby-complete.jar -S gem install -i jdbcmssql activerecord --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql ActiveRecord-JDBC --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql activerecord-jdbcmssql-adapter --no-rdoc --no-ri

REM #java -jar jruby-complete.jar -S gem install -i jdbcmssql rubyzip --no-rdoc --no-ri # 'rubyzip2' instead
java -jar jruby-complete.jar -S gem install -i jdbcmssql rubyzip2 --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql nokogiri -v 1.5.0.beta.4 --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql spreadsheet --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql google-spreadsheet-ruby --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql roo --no-rdoc --no-ri

java -jar jruby-complete.jar -S gem install -i jdbcmssql rack --no-rdoc --no-ri

REM # java -jar jruby-complete.jar -S gem install -i jdbcmssql curb --no-rdoc --no-ri # 'native' gem errors
REM # java -jar jruby-complete.jar -S gem install -i jdbcmssql em-http-request --no-rdoc --no-ri # 'native' gem errors
java -jar jruby-complete.jar -S gem install -i jdbcmssql jeweler --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql mocha --no-rdoc --no-ri
REM # java -jar jruby-complete.jar -S gem install -i jdbcmssql typhoeus --no-rdoc --no-ri # 'native' gem errors

java -jar jruby-complete.jar -S gem install -i jdbcmssql jruby-win32ole --no-rdoc --no-ri
java -jar jruby-complete.jar -S gem install -i jdbcmssql json --no-rdoc --no-ri

REM <<<<<<< .mine
java -jar jruby-complete.jar -S gem install -i jdbcmssql grit -s http://gemcutter.org --no-rdoc --no-ri

REM =======
REM See "http://rails-erd.rubyforge.org"
java -jar jruby-complete.jar -S gem install -i jdbcmssql ruby-graphviz --no-rdoc 
java -jar jruby-complete.jar -S gem install -i jdbcmssql rails-erd --no-rdoc --no-ri

REM See "http://compositekeys.rubyforge.org/"
java -jar jruby-complete.jar -S gem install -i jdbcmssql composite_primary_keys --no-rdoc --no-ri

REM >>>>>>> .r31222
REM Put Gems in Jar:
jar cf jdbcmssql-gems.jar -C jdbcmssql .


