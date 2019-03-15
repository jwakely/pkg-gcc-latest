define(`TITLE_FROM_MD', `esyscmd(`sed -n "1s/^# //p" $1')dnl')dnl
define(`BODY_FROM_MD', `esyscmd(`markdown $1')dnl')dnl
<!DOCTYPE html>
<html>
<head>
<title>
TITLE_FROM_MD(INPUT)
</title>
</head>
<body>
BODY_FROM_MD(INPUT)
</body>
</html>
