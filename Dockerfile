# name the portage image
FROM gentoo/portage:latest as portage

# image is based on stage3-amd64
FROM gentoo/stage3-amd64:latest

# copy the entire portage volume in
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

# timezone
RUN echo 'Asia/Tokyo' > /etc/timezone && emerge --config timezone-data && \
  echo 'FEATURES="-ipc-sandbox -pid-sandbox -mount-sandbox -network-sandbox -sandbox -usersandbox"' >> /etc/portage/make.conf && \
  MAKEOPTS="-j6" emerge -v vim dev-vcs/git sys-devel/distcc sys-devel/multilib-gcc-wrapper

RUN eselect_binutils=$(eselect binutils list |grep '2.33' | awk '{print $1}' | sed -e 's/\[//' -e 's/\]//') && \
      eselect binutils set ${eselect_binutils} && \
      etc-update --automode -5

CMD /usr/bin/distccd --user distcc --daemon --no-detach --port 3632 --log-stderr
