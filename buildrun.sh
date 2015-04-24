# nim -r -p:lib -d:useSysAssert -d:useGcAssert c src/main
nimble build
if [ $? -eq 0 ]
then
  ./src/nimatoad
else
  echo "BUILD FAILED"
fi
