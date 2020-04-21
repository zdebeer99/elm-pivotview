mkdir dist/js
mkdir dist/css

# call sass src/css/main.scss dist/css/zd-pivotview.css

elm make src/PivotView.elm --output=dist/js/pivotview.js --optimize

# sass call sass src/css/main.scss dist/css/zd-pivotview.css --watch
