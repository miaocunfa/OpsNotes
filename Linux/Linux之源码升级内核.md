---
title: "Linux源码升级内核"
date: "2020-07-02"
categories:
    - "技术"
tags:
    - "Linux"
    - "Kernel"
    - "内核升级"
toc: false
indent: false
original: false
---

## 1、升级脚本

``` shell
kernel=4.19.76
workdir=/app/build
mkdir -p $workdir
cd $workdir

sudo yum install -y elfutils-libelf-devel ncurses-devel

wget -P $workdir -c https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$kernel.tar.xz
tar Jxf linux-$kernel.tar.xz
cd linux-$kernel
cp /boot/config-$(uname -r)  $workdir/linux-$kernel/.config

cat >> .config <<EOF
CONFIG_KVM_GUEST=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_BLK_DEV_SD
CONFIG_SCSI_VIRTIO=y
CONFIG_VIRTIO_NET=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y

# XEN
CONFIG_XEN=y
CONFIG_XEN_PV=y
CONFIG_XEN_PV_SMP=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_PVHVM_SMP=y
CONFIG_XEN_512GB=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
CONFIG_XEN_PVH=y
CONFIG_PCI_XEN=y
CONFIG_XEN_PCIDEV_FRONTEND=m
# CONFIG_NET_9P_XEN is not set
CONFIG_XEN_BLKDEV_FRONTEND=m
CONFIG_XEN_BLKDEV_BACKEND=m
CONFIG_XEN_SCSI_FRONTEND=m
CONFIG_NETXEN_NIC=m
CONFIG_XEN_NETDEV_FRONTEND=m
CONFIG_XEN_NETDEV_BACKEND=m
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=m
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_TCG_XEN=m
CONFIG_XEN_WDT=m
# CONFIG_DRM_XEN is not set
CONFIG_XEN_FBDEV_FRONTEND=y
# CONFIG_SND_XEN_FRONTEND is not set
# CONFIG_MMC_SDHCI_XENON is not set
# Xen driver support
CONFIG_XEN_BALLOON=y
CONFIG_XEN_SELFBALLOONING=y
CONFIG_XEN_BALLOON_MEMORY_HOTPLUG=y
CONFIG_XEN_BALLOON_MEMORY_HOTPLUG_LIMIT=512
CONFIG_XEN_SCRUB_PAGES_DEFAULT=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=m
CONFIG_XEN_GRANT_DEV_ALLOC=m
# CONFIG_XEN_GRANT_DMA_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=m
CONFIG_XEN_PCIDEV_BACKEND=m
# CONFIG_XEN_PVCALLS_FRONTEND is not set
# CONFIG_XEN_PVCALLS_BACKEND is not set
CONFIG_XEN_SCSI_BACKEND=m
CONFIG_XEN_PRIVCMD=m
CONFIG_XEN_ACPI_PROCESSOR=m
CONFIG_XEN_MCE_LOG=y
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_SYMS=y
CONFIG_XEN_HAVE_VPMU=y

# BPF
CONFIG_CGROUP_BPF=y
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_NETFILTER_XT_MATCH_BPF=m
CONFIG_BPFILTER=y
CONFIG_BPFILTER_UMH=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_ACT_BPF=m
CONFIG_BPF_JIT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_HAVE_EBPF_JIT=y
CONFIG_BPF_EVENTS=y
CONFIG_XDP_SOCKETS=y

# IPVLAN
CONFIG_IPVLAN=m

# RAID
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_DM_RAID=m

# DRIVER
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_MEGARAID_SAS=m
CONFIG_ATA_PIIX=y

# FS
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_ONLINE_SCRUB is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_VXFS_FS=m

CONFIG_OVERLAY_FS=m
CONFIG_NVDIMM_DAX=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
# CONFIG_DEV_DAX is not set
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y

EOF


# load config
sh -c 'yes "" | make oldconfig'

# review config
#make menuconfig
# load .config  then save and exit

make bzImage
make -j8 modules
make -j8
make install
make modules_install

# update grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# reboot


# build rpm

APP=linux-kernel
VERSION=4.19.76

cat > /lib/modules/upgrade-kernel.sh <<-EOF
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
EOF
chmod 755 /lib/modules/upgrade-kernel.sh

PKG=rpm
fpm -s dir -t ${PKG} -n ${APP} -v ${VERSION} --epoch 0 --rpm-user=root -p ${APP}-${VERSION}.${PKG} \
--after-install /lib/modules/upgrade-kernel.sh \
--exclude  /lib/modules/$VERSION/build --exclude  /lib/modules/$VERSION/source \
/boot/*$VERSION*  /lib/modules/$VERSION  

# no need for /lib/firmware/$VERSION
```

## 2、常见问题

系统启动不来报错：/dev/centos/root does not exist dracut

``` zsh
make install
make modules_install
dracut -f /boot/initramfs-vmlinuz-4.19.76.img vmlinuz-4.19.76
```

> 参考文章:  
> 1、<https://www.tecmint.com/compile-linux-kernel-on-centos-7/>  
> 2、<https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/8.0_release_notes/RHEL-8_0_0_release#kernel_technology_preview>  
> 3、<https://www.jianshu.com/p/a2c409123f38>  
>