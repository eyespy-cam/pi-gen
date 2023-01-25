#!/bin/bash -e

# Clone Eyespy repo
git clone --branch "${EYESPY_TAG}" --depth 1 "${EYESPY_REPO}" eyespy_cam

# Copy services over to image
mkdir -p "${ROOTFS_DIR}/usr/local/bin/eyespy/detector/model"
mkdir -p "${ROOTFS_DIR}/usr/local/bin/eyespy/auth"

cp -r ./eyespy_cam/camera/detector/src/* "${ROOTFS_DIR}/usr/local/bin/eyespy/detector"
cp -r ./eyespy_cam/camera/detector/model/* "${ROOTFS_DIR}/usr/local/bin/eyespy/detector/model"
cp -r ./eyespy_cam/camera/auth/src/* "${ROOTFS_DIR}/usr/local/bin/eyespy/auth"

cp -r ./eyespy_cam/camera/auth/requirements.txt "${ROOTFS_DIR}/req_auth.txt"
cp -r ./eyespy_cam/camera/detector/requirements.txt "${ROOTFS_DIR}/req_detector.txt"

# Copy systemd configs for services
cp -r ./eyespy_cam/camera/systemd/*.service "${ROOTFS_DIR}/etc/systemd/system"

# Start services and install python requirements
on_chroot << EOF
systemctl enable NetworkManager.service
systemctl enable eyespy.auth.service

python3 -c "import platform;print('Architecture: ' + platform.machine());"
python3 -m pip install -r req_auth.txt --extra-index-url=https://www.piwheels.org/simple --upgrade
python3 -m pip install -r req_detector.txt --extra-index-url=https://www.piwheels.org/simple --upgrade
rm req_auth.txt req_detector.txt
EOF

# Delete github repo
rm -rf ./eyespy_cam
