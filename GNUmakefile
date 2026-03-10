# GNUmakefile for SmallSolitaire (Linux/GNUstep)
#
# Klondike solitaire game. Uses SmallStepLib for app lifecycle, menus,
# and window style.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallSolitaire

SmallSolitaire_OBJC_FILES = \
	main.m \
	App/AppDelegate.m \
	UI/SolitaireWindow.m \
	UI/SolitaireView.m

SmallSolitaire_HEADER_FILES = \
	App/AppDelegate.h \
	UI/SolitaireWindow.h \
	UI/SolitaireView.h

SmallSolitaire_INCLUDE_DIRS = \
	-I. \
	-IApp \
	-IUI \
	-I../SmallStepLib/SmallStep/Core \
	-I../SmallStepLib/SmallStep/Platform/Linux

# SmallStep framework (from SmallStepLib)
SMALLSTEP_FRAMEWORK := $(shell find ../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

SmallSolitaire_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallSolitaire_OBJCFLAGS = -std=gnu99
SmallSolitaire_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallSolitaire_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallSolitaire_TOOL_LIBS = -lSmallStep -lobjc

before-all::
	mkdir -p Resources && cp -f ../SmallStepLib/Resources/logo.png Resources/logo.png 2>/dev/null || true
SmallSolitaire_RESOURCE_FILES = Resources/logo.png

include $(GNUSTEP_MAKEFILES)/application.make
