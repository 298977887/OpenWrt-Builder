# 使用官方Ubuntu镜像作为基础镜像
FROM ubuntu:22.04

# 避免在安装过程中出现提示
ARG DEBIAN_FRONTEND=noninteractive

# 更新软件包列表并安装sudo和OpenSSH服务器
# 安装Node.js 18 为了安装指定版本的Node.js，我们会使用NodeSource的二进制分发
RUN apt-get update && \
    apt-get install -y sudo openssh-server curl && \
    mkdir /var/run/sshd && \
	echo 'root:123456' | chpasswd && \
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#CMD ["/usr/sbin/sshd", "-D"]

# 允许所有用户无密码使用sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 创建一个名为builder的用户，并添加到sudo组
RUN useradd -m builder && echo "builder:builder" | chpasswd && usermod -aG sudo builder

# 安装Node.js 18 为了安装指定版本的Node.js，我们会使用NodeSource的二进制分发
#RUN apt-get install -y curl && \
#  curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
#  apt-get install -y nodejs

# 安装jq，用于解析JSON数据
#RUN apt-get install -y jq

# 安装pip3，用于安装Python3包
#RUN apt-get install -y python3-pip

# 预配置 tzdata 包并设置时区为中国（上海）
RUN apt-get update -y && \
  apt-get install -y tzdata && \
  ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  apt-get full-upgrade -y && \
  apt-get install -y \
  ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
  git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev \
  libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev \
  libssl-dev libtool lrzsz mkisofs msmtp ninja-build p7zip p7zip-full patch pkgconf python3 \
  python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo \
  uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 切换到新创建的用户
USER builder

# 设置工作目录
WORKDIR /home/builder

# 验证安装
RUN node -v && npm -v

# 验证安装
#RUN node -v && npm -v && python2.7 -V && python3 --version
RUN node -v && npm -v

# 切换回root用户以便启动SSH服务
USER root

# 暴露SSH端口
EXPOSE 22

# 启动SSH服务
CMD ["/usr/sbin/sshd", "-D"]