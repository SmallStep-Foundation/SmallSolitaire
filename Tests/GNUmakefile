#
# SmallSolitaire unit tests
# Build from SmallSolitaire: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallSolitaire
#

include $(GNUSTEP_MAKEFILES)/common.make

# From Tests/ we have .. = SmallSolitaire, so SmallStepLib is ../../SmallStepLib
SMALLSTEP_FRAMEWORK := $(shell find ../../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

TOOL_NAME = test_SmallSolitaire
test_SmallSolitaire_OBJC_FILES = \
	SmallSolitaireTests.m \
	../App/AppDelegate.m \
	../UI/SolitaireWindow.m \
	../UI/SolitaireView.m

test_SmallSolitaire_INCLUDE_DIRS = -I.. -I../App -I../UI
test_SmallSolitaire_INCLUDE_DIRS += -I../../SmallStepLib/SmallStep/Core -I../../SmallStepLib/SmallStep/Platform/Linux
test_SmallSolitaire_INCLUDE_DIRS += -I../../SmallStepLib/Tests
test_SmallSolitaire_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc
test_SmallSolitaire_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
test_SmallSolitaire_OBJCFLAGS = -std=gnu99

before-all::
	$(MAKE) -C ../../SmallStepLib
	$(MAKE) -C ..

include $(GNUSTEP_MAKEFILES)/tool.make
