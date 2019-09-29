FROM redis:latest

RUN apt-get update && apt-get install -y sysfsutils
RUN echo 'kernel/mm/transparent_hugepage/enabled = never' >> /etc/sysfs.conf \
 && echo 'kernel/mm/transparent_hugepage/defrag = never' >> /etc/sysfs.conf
