LOCAL_PATH:= $(call my-dir)

common_CFLAGS := \
    -Wpointer-arith -Wwrite-strings -Wunused -Winline \
    -Wnested-externs -Wmissing-declarations -Wmissing-prototypes \
    -Wno-long-long -Wfloat-equal -Wno-multichar -Wsign-compare \
    -Wno-format-nonliteral -Wendif-labels -Wstrict-prototypes \
    -Wdeclaration-after-statement -Wno-system-headers

JANSSON_HEADERS := \
    config.h \
    hashtable.h \
    jansson.h \
    jansson_private.h \
    strbuffer.h \
    utf.h \
    util.h

#########################
# Build static libjannson
include $(CLEAR_VARS)

JANSSON_SRC_FILES := \
    dump.c \
    hashtable.c \
    load.c \
    strbuffer.c \
    utf.c \
    value.c

LOCAL_SRC_FILES := $(addprefix compat/jansson/,$(JANSSON_SRC_FILES))
LOCAL_C_INCLUDES += \
    $(addprefix compat/jansson/,$(JANSSON_HEADERS))
LOCAL_CFLAGS += $(common_CFLAGS)

LOCAL_COPY_HEADERS := $(addprefix compat/jansson/,$(JANSSON_HEADERS))

LOCAL_MODULE := libjansson_static
LOCAL_MODULE_TAGS := optional

include $(BUILD_STATIC_LIBRARY)


#####################
# Build minerd binary
include $(CLEAR_VARS)

MINER_HEADERS := \
    compat.h \
    cpuminer-config.h \
    elist.h \
    miner.h

MINER_SRC_FILES += \
    sha2.c \
    scrypt.c \
    util.c \
    cpu-miner.c

ifeq ($(TARGET_ARCH),arm)
    MINER_SRC_FILES += \
        sha2-arm.S \
        scrypt-arm.S
endif

ifeq ($(TARGET_ARCH),x86)
    MINER_SRC_FILES += \
        sha2-x86.S \
        scrypt-x86.S
endif

MINER_SHARED_LIBS := \
    libc \
    libcurl \
    libssl \
    libcrypto \
    libz

LOCAL_SRC_FILES := $(MINER_SRC_FILES)
LOCAL_C_INCLUDES += \
    $(MINER_INCLUDES) \
    $(LOCAL_PATH)/../curl/include \
    $(addprefix compat/jansson/,$(JANSSON_HEADERS))
LOCAL_CFLAGS += $(common_CFLAGS) \
    -O3

ifeq ($(TARGET_ARCH),arm)
    LOCAL_CFLAGS += -D__arm__ -D__APCS_32__
    ifeq ($(ARCH_ARM_HAVE_NEON),true)
	    LOCAL_CFLAGS += -D__ARM_NEON__ -mfpu=neon
    endif
endif

LOCAL_MODULE := minerd
LOCAL_MODULE_TAGS := optional

LOCAL_STATIC_LIBRARIES := libcurl_static libjansson_static
LOCAL_SYSTEM_SHARED_LIBRARIES := $(MINER_SHARED_LIBS)

include $(BUILD_EXECUTABLE)
