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

There are still a few order of operations to figure out (like when to install nginx, before starting a logstash helper
process, so it can find the access.log file, and making sure to stop nginx before updating files and restarting it so
configs change), but the scripts and steps work for setting up an instance rapidly.

Known Issues
===
1) Time field is _not_ the nginx time, as requested; it is still the elasticsearch insertion time. There's probably a
template setting or filter setting to configure it that I am missing.
2) The nginx access log does not get to the 10,000 limit. It falls quite short, since activity to the server is
limited.

Future Improvements
===
1) Ansibilize everything. The setup of this node should be much easier now that the steps are recorded as shell
scripts. Should just take a while to translate them from bash to corresponding Ansible commands.
2) More improvements to the logstash portion (better `grok` filters, more information, translation of information from
one type of data to another.
