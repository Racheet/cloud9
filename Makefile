.PHONY:    apf ext worker mode theme package test

# packages apf
apf:
	cd node_modules/packager; node package.js projects/apf_cloud9.apr
	cd node_modules/packager; cat build/apf_release.js | sed 's/\(\/\*FILEHEAD(\).*//g' > ../../plugins-client/lib.apf/www/apf-packaged/apf_release.js

# package debug version of apf
apfdebug:
	cd node_modules/packager/projects; cat apf_cloud9.apr | sed 's/<p:define name=\"__DEBUG\" value=\"0\" \/>/<p:define name=\"__DEBUG\" value=\"1\" \/>/g' > apf_cloud9_debug2.apr
	cd node_modules/packager/projects; cat apf_cloud9_debug2.apr | sed 's/apf_release/apf_debug/g' > apf_cloud9_debug.apr; rm apf_cloud9_debug2.apr
	cd node_modules/packager; node package.js projects/apf_cloud9_debug.apr
	cd node_modules/packager; cat build/apf_debug.js | sed 's/\(\/\*FILEHEAD(\).*\/apf\/\(.*\)/\1\2/g' > ../../plugins-client/lib.apf/www/apf-packaged/apf_debug.js

# packages core
core:
	mkdir -p build/src
	node build/r.js -o build/core.build.js

# generates packed template
helper: 
	node build/packed_helper.js

# packages ext
ext: 
	node build/r.js -o build/app.build.js
	echo "module = {exports: undefined};" | cat - plugins-client/lib.packed/www/packed.js > temp_file && mv temp_file plugins-client/lib.packed/www/packed.js

# calls dryice on worker & packages it
worker:
	mkdir -p plugins-client/lib.ace/www/worker
	rm -rf /tmp/c9_worker_build
	mkdir -p /tmp/c9_worker_build/ext
	ln -s `pwd`/plugins-client/ext.language /tmp/c9_worker_build/ext/language
	ln -s `pwd`/plugins-client/ext.codecomplete /tmp/c9_worker_build/ext/codecomplete
	ln -s `pwd`/plugins-client/ext.jslanguage /tmp/c9_worker_build/ext/jslanguage
	./Makefile.dryice.js worker
	cp node_modules/ace/build/src/worker* plugins-client/lib.ace/www/worker

# copies built ace modes
mode:
	mkdir -p plugins-client/lib.ace/www/mode
	cp `find node_modules/ace/build/src | grep -E "mode-[a-zA-Z_]+.js"`  plugins-client/lib.ace/www/mode

# copies built ace themes
theme:
	mkdir -p plugins-client/lib.ace/www/theme
	cp `find node_modules/ace/build/src | grep -E "theme-[a-zA-Z_]+.js"` plugins-client/lib.ace/www/theme

gzip:
	gzip plugins-client/lib.packed/www/packed.js

package: apf core worker mode theme ext

test:
	$(MAKE) -C test
