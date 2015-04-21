# nim -r -p:lib -d:useSysAssert -d:useGcAssert c src/main
nimble build
./src/nimatoad
