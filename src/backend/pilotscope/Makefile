#-------------------------------------------------------------------------
#
# Makefile--
#    Makefile for backend/pilotscope
#
# IDENTIFICATION
#    src/backend/pilotscope/Makefile
#
#-------------------------------------------------------------------------

subdir = src/backend/pilotscope
top_builddir = ../../..
include $(top_builddir)/src/Makefile.global

OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
OBJS += $(patsubst %.c,%.o,$(wildcard utils/*.c))

include $(top_srcdir)/src/backend/common.mk
