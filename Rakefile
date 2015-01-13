task :default => [:run]

TARGET  = "abp.dylib"
SOURCES = "ABetterPlace.m ABPNaiiveSwizzler.m ABPTweetScore.m"

task :run => [:build] do
	system("DYLD_INSERT_LIBRARIES=./build/#{TARGET} /Applications/Tweetbot.app/Contents/MacOS/Tweetbot &")
end

task :build do
	if (!File.exists?(Dir.getwd + "/build")) then
		system("mkdir build")
		system("clang -arch x86_64 \
			-dynamiclib -single_module \
			-O3 \
			-fobjc-link-runtime \
			-current_version 1.0.1 \
			-compatibility_version 1.0.1 \
			-framework Cocoa \
			-o ./build/#{TARGET} #{SOURCES}")
	end
end

task :clean do
	system("rm -Rf ./build")
end
