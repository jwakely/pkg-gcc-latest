define(`TITLE_FROM_MD', `esyscmd(`sed -n "1s/^# //p" $1')dnl')dnl
define(`BODY_FROM_MD', `esyscmd(`m4 -DDATE='DATE` -DSVNREV='SVNREV` $1 | markdown -')dnl')dnl
<!DOCTYPE html>
<html lang="en">
<head>
<title>
TITLE_FROM_MD(INPUT)
</title>
</head>
<body>
BODY_FROM_MD(INPUT)
</body>
</html>
