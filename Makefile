all: clean desktop dist

desktop: lovefile win64 dist
console: lovefile switch
appimage: lovefile

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

	wget https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip
	mv -f love-11.5-win64.zip requirements/win64/
	unzip requirements/win64/love-11.5-win64.zip -d requirements/win64
	mv -f requirements/win64/love-11.5-win64 requirements/win64/love
	
	rm requirements/win64/love-11.5-win64.zip

	cp -r requirements/win64/love/* build/$(GameName)-win64
	rm -rf requirements/win64/love

	cp requirements/win64/*.dll build/$(GameName)-win64
	cp requirements/steam_appid.txt build/$(GameName)-win64

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

	chmod +x ./requirements/appimage/appimagetool-x86_64.AppImage
	./requirements/appimage/love.AppImage --appimage-extract
	cat ./requirements/appimage/squashfs-root/bin/love build/$(GameName)-lovefile/$(GameName).love > ./requirements/appimage/squashfs-root/bin/love

	chmod +x ./requirements/appimage/squashfs-root/bin/love
	./requirements/appimage/appimagetool-x86_64.AppImage ./requirements/appimage/squashfs-root/ build/$(GameName)-appimage/$(GameName).AppImage
	rm -rf ./requirements/appimage/squashfs-root

dist:
	rm -rf build/dist
	mkdir build/dist
	cd build/$(GameName)-win64 && zip -9 -r ../../build/dist/$(GameName)-win64.zip *
	cp build/$(GameName)-lovefile/$(GameName).love build/dist/$(GameName).love