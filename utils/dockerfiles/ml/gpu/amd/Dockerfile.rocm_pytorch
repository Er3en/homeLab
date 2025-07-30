FROM rocm/pytorch:latest
# https://hub.docker.com/r/rocm/pytorch

WORKDIR /home

RUN pip3 install pip --upgrade
RUN pip3 install setuptools wheel
RUN pip3 install pandas

WORKDIR "/home/user"

CMD ["bash"]