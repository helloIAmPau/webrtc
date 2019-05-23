RELEASE=m75

all:

depot-tools:
	if [ ! -d depot_tools/ ]; then git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git; fi

ios: depot-tools
	if [ ! -d ios ]; then mkdir -p ios && export PATH=$$PATH:$$(pwd)/depot_tools && cd ios && fetch --nohooks webrtc_ios; fi
	export PATH=$$PATH:$$(pwd)/depot_tools && cd ios && gclient sync --with_branch_heads --with_tags
	export PATH=$$PATH:$$(pwd)/depot_tools && cd ios/src && if [ "$$(git branch | head -n 1 | awk '{ print $2 }')" != ${RELEASE} ]; then git checkout -B ${RELEASE} refs/remotes/branch-heads/m75 && gclient sync; fi
	export PATH=$$PATH:$$(pwd)/depot_tools && cd ios/src/tools_webrtc/ios && ./build_ios_libs.sh
	mkdir -p out && rm -rf out/WebRTC.framework && cp -rf ios/src/out_ios_libs/WebRTC.framework out

release-ios: ios
	cd out/ && zip -r webrtc.framework.zip WebRTC.framework && mv webrtc.framework.zip ../

android: depot-tools
	if [ ! -d android ]; then mkdir -p android && export PATH=$$PATH:$$(pwd)/depot_tools && cd android && fetch --nohooks webrtc_android; fi
	export PATH=$$PATH:$$(pwd)/depot_tools && cd android && gclient sync --with_branch_heads --with_tags
	export PATH=$$PATH:$$(pwd)/depot_tools && cd android/src && if [ "$$(git branch | head -n 1 | awk '{ print $2 }')" != ${RELEASE} ]; then git checkout -B ${RELEASE} refs/remotes/branch-heads/m75 && gclient sync; fi
	export PATH=$$PATH:$$(pwd)/depot_tools && cd android/src && . ./build/android/envsetup.sh && gn gen out/Debug --args='target_os="android" target_cpu="arm,arm64,x86,x64"' && ninja -C out/Debug

.PHONY: all depot-tools ios release-ios android
