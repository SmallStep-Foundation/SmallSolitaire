# GNUmakefile for SmallSolitaire (Linux/GNUstep)
#
# Klondike solitaire game. Uses SmallStepLib for app lifecycle, menus,
# and window style.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

# Guard: always build the app by default. An explicit .DEFAULT_GOAL makes
# plain 'make' immune to reordering of rules below (e.g. a before-all::
# block before the application.make include would otherwise become the
# default goal and silently skip the app build).
.DEFAULT_GOAL := all

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
	$(SMALLSTEP_INCLUDE_DIRS)

# SmallStep framework (shared discovery - SmallStepLib/GNUmakefile.include)
-include ../SmallStepLib/GNUmakefile.include

SmallSolitaire_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallSolitaire_OBJCFLAGS = -std=gnu99
SmallSolitaire_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallSolitaire_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallSolitaire_TOOL_LIBS = -lSmallStep -lobjc

SmallSolitaire_RESOURCE_FILES = \
	Resources/SmallSolitaire.png \
	Resources/logo.png
# Application icon (bare filename; copied into the bundle Resources dir)
SmallSolitaire_APPLICATION_ICON = SmallSolitaire.png


include $(GNUSTEP_MAKEFILES)/application.make

# Copy the shared logo into Resources before the build (defined after
# the application.make include so it is not the makefile default goal)
before-all::
	mkdir -p Resources && cp -f ../SmallStepLib/Resources/logo.png Resources/logo.png 2>/dev/null || true

