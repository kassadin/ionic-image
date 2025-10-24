# ===========================================================
# 基础镜像：JDK 21 + Android SDK 35 + Node 22
# 基于 Ubuntu 22.04 Jamm
# ===========================================================

FROM eclipse-temurin:21-jdk-jammy

ARG VERSION=1.0.0
LABEL version=$VERSION
LABEL maintainer="kassadin@foxmail.com"
LABEL description="JDK 21 + Android SDK 35 + Node 22 CI 环境"

# ---- 环境变量 ----
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# ---- 系统依赖 ----
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl unzip wget git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ---- 安装 Node 22 ----
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y nodejs \
 && npm install -g pnpm yarn \
 && node -v && npm -v

# ---- 安装 Android SDK ----
RUN mkdir -p $ANDROID_HOME/cmdline-tools \
 && cd $ANDROID_HOME/cmdline-tools \
 && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip \
 && unzip -q cmdline-tools.zip \
 && rm cmdline-tools.zip \
 && mv cmdline-tools latest 

# ---- 安装 SDK 组件（API 35）----
RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses \
 && sdkmanager --sdk_root=$ANDROID_HOME \
      "platform-tools" \
      "platforms;android-35" \
      "build-tools;34.0.0" \
      "build-tools;35.0.0" \
      "cmdline-tools;latest"

WORKDIR /workspace
