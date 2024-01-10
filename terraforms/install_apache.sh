yum update -y
yum install httpd
systemctl start httpd
systemctl enable httpd

echo "Hello my darling,my name is Tris. This is my firt application.I'm from ${hostname-f}" > var/www/html/index.html



