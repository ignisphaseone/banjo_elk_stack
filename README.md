Banjo AWS ELK Stack Demo
===
Manual steps so far:
1) Set up AWS. Security Group to allow access to the AWS instance.
2) Install Oracle Java. This has that pesky "accept Oracle License" nonsense.
    apt-add-repository ppa:webupd8team/java
    apt update
    apt install oracle-java8-installer
3) install nginx
    apt update
    apt install nginx

These are the steps that aren't automated (yet). This is just manual setup stuff; scripts are provided for the
subcomponents of the stack (NGINX/Elasticsearch/Logstash/Kibana).

