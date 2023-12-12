clean:
	rm -rf ./.dart_tool/native_assets_builder/*
	cd ./llama.cpp/ && $(MAKE) clean
