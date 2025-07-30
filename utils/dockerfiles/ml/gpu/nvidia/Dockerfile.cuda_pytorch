FROM nvcr.io/nvidia/pytorch:22.11-py3 
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch

WORKDIR /home

RUN pip3 install pip --upgrade
RUN pip3 install setuptools wheel
RUN pip3 install pandas

WORKDIR "/home/user"

CMD ["bash"]