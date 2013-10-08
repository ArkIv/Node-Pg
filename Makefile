


#
#   Native variables
#


CC = gcc 

C_FLAGS = -fno-inline -O3 -Wall -fPIC -DPIC -pthread
LINK_FLAGS = -shared -pthread 

JS_BUILD_HOME ?= /usr/lib/js-build-tools
JS_ROOT_DIR = ./

JS_CUSTOM_EXTERNS = lib/externs.js

include $(JS_BUILD_HOME)/js-variables.mk

MODULE_NAME ?= node-pg



#
#   Common
#

all: js native-build


clean:
	rm -rf bin/*.o bin/*.node
	node-gyp clean



#
#   Native
#


native-build : setup-build-dir pg.node


pg.node : 
	node-gyp configure build
	cp ./build/Release/pg.node ./bin


%.o : %.cc
	$(CC) $(C_FLAGS) $(addprefix -I, $(INCLUDE_DIRS)) -o bin/$@  -c $<



#
#	  JS
#


js: js-externs js-export


js-build : setup-build-dir index.js


js-lint : $(shell cat src.d)
	gjslint --beep --strict --custom_jsdoc_tags='namespace,event' $^;


js-check : $(shell cat src.d)
	$(JS_COMPILER) $(JS_COMPILER_ARGS) --compilation_level ADVANCED_OPTIMIZATIONS \
	               $(addprefix --js , $^)


index.js : $(shell cat src.d)
	$(JS_COMPILER) $(JS_COMPILER_ARGS) --compilation_level WHITESPACE_ONLY \
	               $(addprefix --js , $^) > bin/$@



#
#   Setup compiler and linter
#

setup : setup-compiler setup-linter check-node-gyp


setup-compiler :
	if [ ! -f .build/compiler.jar ]; \
	then \
	mkdir .build/ ; \
	wget http://closure-compiler.googlecode.com/files/compiler-latest.zip -O .build/google-closure.zip ; \
	unzip .build/google-closure.zip -d .build/ compiler.jar ; \
	rm .build/google-closure.zip > /dev/null ; \
	fi


setup-linter :
	which gjslint > /dev/null; \
	[ $$? -eq 0 ] || sudo pip install -U http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz;


check-node-gyp :
	if [ -z "$(shell npm list -g 2>/dev/null | grep node-gyp)" ]; \
	then \
	echo "\033[31mPlease, install node-gyp: sudo npm install -g node-gyp\033[0m"; \
	exit 1; \
	fi


setup-build-dir :
	mkdir -p bin/


include $(JS_BUILD_HOME)/js-rules.mk

