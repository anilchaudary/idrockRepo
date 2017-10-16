
COMPILE_FLAG=0

echo "usage for compiling : startIAM.sh -c "
echo "usage for running : startIAM.sh  -r"

if [ $# -eq 1 ]
then
	echo "Value entered >> $1"
	if [ $1 = '-c' ] 
	then 
		echo " Compling & Running the binaries..."
		COMPILE_FLAG=1 
	elif [ $1 = '-r' ]
	then
		COMPILE_FLAG=0
	else
		echo " Error: Check thie usage "
		exit
	fi

else
	echo " Error: Check the usage "
	exit
fi


echo " Stopping already jars if any >>>"
kill -9 $(lsof -t -i:9039)
kill -9 $(lsof -t -i:9091)
kill -9 $(lsof -t -i:9090)
kill -9 $(lsof -t -i:2552)
kill -9 $(lsof -t -i:2553)
kill -9 $(lsof -t -i:2554)

echo " Compile flag: $COMPILE_FLAG"
if [ $COMPILE_FLAG -eq 1 ]
then
	echo " Compiling the Code >>>"
	ant -f ~/Server/ukmPortal/build.xml
	cd ~/Server/ukm
	mvn clean install -Dmaven.test.skip=true 
	cd ~/Server/OauthSpray
	mvn clean install -Dmaven.test.skip=true

	echo " Deploying War File for Portal >>"
	sudo /usr/local/apache-tomcat-7.0.54/bin/shutdown.sh
	cp ~/Server/ukmPortal/build/ukmPortal.war /usr/local/apache-tomcat-7.0.54/webapps/
	sudo /usr/local/apache-tomcat-7.0.54/bin/startup.sh
fi

echo " Running jars >>> "
echo "Running IAM Server"
#java -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true  -jar ~/Server/ukm/target/ukm-1.0.jar &
java -Xms512m -Xmx768m  -jar ~/Server/ukm/target/ukm-1.0.jar &
echo "Running Oauth Server"
java -Xms512m -Xmx768m  -jar ~/Server/OauthSpray/target/OauthServer-1.0.jar &
echo " Restarting tomcat start >>> "
sudo /usr/local/apache-tomcat-7.0.54/bin/shutdown.sh
sudo /usr/local/apache-tomcat-7.0.54/bin/startup.sh
