#!/bin/bash -e

# Clone Eyespy repo
git clone --branch "${EYESPY_TAG}" --depth 1 "${EYESPY_REPO}" eyespy_cam

# Copy services over to image
mkdir -p "${ROOTFS_DIR}/usr/local/bin/eyespy/detector/model"
mkdir -p "${ROOTFS_DIR}/usr/local/bin/eyespy/auth"

cp -r ./eyespy_cam/camera/detector/src/* "${ROOTFS_DIR}/usr/local/bin/eyespy/detector"
cp -r ./eyespy_cam/camera/detector/model/* "${ROOTFS_DIR}/usr/local/bin/eyespy/detector/model"
cp -r ./eyespy_cam/camera/auth/src/* "${ROOTFS_DIR}/usr/local/bin/eyespy/auth"

# Copy systemd configs for services
cp -r ./eyespy_cam/camera/systemd/*.service "${ROOTFS_DIR}/etc/systemd/system"

# Delete github repo
rm -rf ./eyespy_cam

# Start NetworkManager to handle Wifi Connections
on_chroot << EOF
systemctl enable NetworkManager.service
systemctl enable eyespy.auth.service
EOF

