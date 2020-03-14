mkdir dist

call sass src/css/main.scss dist/css/zd-pivotview.css

xcopy /Y /S dist\*.* %gopath%\src\consol_web\factory-scheduling-tool\public\fst\css

@rem sass call sass src/css/main.scss dist/css/zd-pivotview.css --watch
