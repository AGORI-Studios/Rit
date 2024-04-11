# ISGIT argument true/false
# if no arguments are passed, run all
ifeq ($(ISGIT), true)
	ISGIT = true
else
	ISGIT = false
endif
default:
	@echo "$(ISGIT)" > "src/isgit.bool"
	@make clean
	@make desktop
	@make dist
	@echo $(ISGIT)
	@echo "false" > "src/isgit.bool"

all: desktop console dist

desktop: lovefile win64 dist
console: lovefile switch
linux: lovefile

# define GameName = "GameName"
GameName = Rit

clean:
	rm -rf build

lovefile:
	mkdir build
	mkdir build/$(GameName)-lovefile
	# zip all files in src/ into a love file
	cd src && zip -9 -r ../build/$(GameName)-lovefile/$(GameName).love *

win64: lovefile
	mkdir build/$(GameName)-win64
	cp -r requirements/win64/love/* build/$(GameName)-win64
	cp requirements/win64/discord-rpc.dll build/$(GameName)-win64
	cp requirements/win64/luasteam.dll build/$(GameName)-win64
	cp requirements/win64/steam_api64.dll build/$(GameName)-win64
	cp requirements/steam_appid.txt build/$(GameName)-win64
	cp requirements/win64/https.dll build/$(GameName)-win64
	cat build/$(GameName)-win64/love.exe build/$(GameName)-lovefile/$(GameName).love > build/$(GameName)-win64/$(GameName).exe
	rm build/$(GameName)-win64/love.exe
	rm build/$(GameName)-win64/lovec.exe

macos: lovefile
	mkdir build/$(GameName)-macos
	cp -r requirements/macos/love.app build/$(GameName)-macos
	cp requirements/macos/libdiscord-rpc.dylib build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/luasteam.so build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/libsteam_api.dylib build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/steam_appid.txt build/$(GameName)-macos/love.app/Contents/MacOS
	cp requirements/macos/https.so build/$(GameName)-macos/love.app/Contents/MacOS
	mv build/$(GameName)-macos/love.app build/$(GameName)-macos/$(GameName).app
	cp build/$(GameName)-lovefile/$(GameName).love build/$(GameName)-macos/$(GameName).app/Contents/Resources/

# love nx loll
switch: lovefile
	rm -rf build/$(GameName)-switch
	mkdir -p "build/$(GameName)-switch"

	nacptool --create "Rit" "AGORI Studios" "$(shell cat src/__VERSION__.txt)" build/$(GameName)-switch/Rit.nacp
	mkdir build/$(GameName)-switch/romfs
	cp build/$(GameName)-lovefile/$(GameName).love build/$(GameName)-switch/romfs/game.love

	elf2nro requirements/switch/love.elf build/$(GameName)-switch/Rit.nro --nacp=build/$(GameName)-switch/Rit.nacp --romfsdir=build/$(GameName)-switch/romfs

	rm -r build/$(GameName)-switch/romfs
	rm build/$(GameName)-switch/Rit.nacp

appimage: lovefile
	rm -rf build/$(GameName)-appimage
	mkdir -p "build/$(GameName)-appimage"

	./requirements/linux/love.AppImage --appimage-extract
	cat ./requirements/linux/squashfs-root/bin/love build/$(GameName)-lovefile/$(GameName).love > ./requirements/linux/squashfs-root/bin/love

	#repackage with appimagetool-x86_64.AppImage
	./requirements/linux/appimagetool-x86_64.AppImage ./requirements/linux/squashfs-root/ build/$(GameName)-appimage/$(GameName).AppImage
	rm -rf ./requirements/linux/squashfs-root

dist:
	mkdir build/dist
	cd build/$(GameName)-win64 && zip -9 -r ../../build/dist/$(GameName)-win64.zip *
	cp build/$(GameName)-lovefile/$(GameName).love build/dist/$(GameName).love