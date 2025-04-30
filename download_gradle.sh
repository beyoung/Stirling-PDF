#!/bin/bash

# 设置要下载的 Gradle 版本
GRADLE_VERSION="8.14"
GRADLE_ZIP="gradle-${GRADLE_VERSION}-all.zip"
GRADLE_URL="https://mirrors.cloud.tencent.com/gradle/gradle-8.14-all.zip"

# 本地存储路径（你也可以自定义）
LOCAL_GRADLE_DIR="./local-gradle"
mkdir -p "${LOCAL_GRADLE_DIR}"
echo $GRADLE_URL
echo "📥 正在从清华镜像下载 Gradle ${GRADLE_VERSION}..."
curl -# -L -o "${LOCAL_GRADLE_DIR}/${GRADLE_ZIP}" "${GRADLE_URL}"

if [ $? -ne 0 ]; then
  echo "❌ 下载失败，请检查网络连接或镜像地址是否正确。"
  exit 1
fi

echo "✅ 下载完成：${LOCAL_GRADLE_DIR}/${GRADLE_ZIP}"

# 修改 gradle-wrapper.properties 文件
WRAPPER_PROPERTIES="gradle/wrapper/gradle-wrapper.properties"

if [ ! -f "${WRAPPER_PROPERTIES}" ]; then
  echo "❌ 找不到 ${WRAPPER_PROPERTIES}，请确保在一个 Gradle 项目根目录下运行此脚本。"
  exit 1
fi

# 使用 file URL 替代原有的 distributionUrl
ZIP_ABS_PATH="$(cd "${LOCAL_GRADLE_DIR}"; pwd)/${GRADLE_ZIP}"
ESCAPED_PATH=$(echo "$ZIP_ABS_PATH" | sed 's/ /%20/g')

echo "🔧 正在修改 ${WRAPPER_PROPERTIES} 使用本地 Gradle 包..."
sed -i.bak "s|distributionUrl=.*|distributionUrl=file://${ESCAPED_PATH}|" "${WRAPPER_PROPERTIES}"

echo "🎉 已成功配置本地 Gradle！你可以运行 ./gradlew build 来构建项目。"