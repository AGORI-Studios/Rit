# if no arguments are passed, run all
default: all

all: clean desktop

desktop: lovefile win32 win64 macos dist

# define GameName = "GameName"
GameName = "Rit"

clean:
	rm -rf build

lovefile:
	mkdir build
	mkdir build/$(GameName)-lovefile
	# zip all files in src/ into a love file
	cd src && zip -9 -r ../build/$(GameName)-lovefile/$(GameName).love *

win32: lovefile
	mkdir build/$(GameName)-win32
	cp -r requirements/win32/love/* build/$(GameName)-win32 
	cp requirements/win32/discord-rpc.dll build/$(GameName)-win32
	cp requirements/win32/luasteam.dll build/$(GameName)-win32
	cp requirements/win32/steam_api.dll build/$(GameName)-win32
	cp requirements/steam_appid.txt build/$(GameName)-win32
	cat build/$(GameName)-win32/love.exe build/$(GameName)-lovefile/$(GameName).love > build/$(GameName)-win32/$(GameName).exe
	rm build/$(GameName)-win32/love.exe
	rm build/$(GameName)-win32/lovec.exe

win64: lovefile
	mkdir build/$(GameName)-win64
	cp -r requirements/win64/love/* build/$(GameName)-win64
	cp requirements/win64/discord-rpc.dll build/$(GameName)-win64
	cp requirements/win64/luasteam.dll build/$(GameName)-win64
	cp requirements/win64/steam_api64.dll build/$(GameName)-win64
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
	mv build/$(GameName)-macos/love.app build/$(GameName)-macos/$(GameName).app
	cp build/$(GameName)-lovefile/$(GameName).love build/$(GameName)-macos/$(GameName).app/Contents/Resources/

dist:
	mkdir build/dist
	zip -9 -r build/dist/$(GameName)-win32.zip build/$(GameName)-win32
	zip -9 -r build/dist/$(GameName)-win64.zip build/$(GameName)-win64
	zip -9 -r build/dist/$(GameName)-macos.zip build/$(GameName)-macos
	cp build/$(GameName)-lovefile/$(GameName).love build/dist/$(GameName).love