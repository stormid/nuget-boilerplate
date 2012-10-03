require 'albacore'
require 'fileutils'

task :default => :build

task :build => ['build:specs']

namespace :build do
	msbuild :compile, [:target] => ['clean:build'] do |msb, args|
		msb.targets [:clean, :rebuild]
		msb.properties = {
			:configuration => args[:target] || :Debug,
			:outdir => "#{Dir.pwd}/build/"
		}
		msb.verbosity = "minimal"
		msb.solution = "MyPackage.sln"
	end
	
	mspec :specs => :compile do |mspec|
		mspec.command = "packages/Machine.Specifications.0.5.8/tools/mspec-clr4.exe"
		mspec.assemblies "build/MyPackage.Specs.dll"
	end
end

namespace :clean do
	task :build do
		rm_rf("build") if File.directory? "build"
	end
	
	task :release do
		rm_rf("release") if File.directory? "release"
	end
end

task :publish, [:apikey] => ['build', 'clean:release'] do |task, args|
	Rake::Task['build:compile'].execute({:target => :Release})
	mkdir_p("release/lib/net20")
	cp "build/MyPackage.dll", "release/lib/net20"
	Rake::Task['nuget:create'].invoke
	Rake::Task['nuget:pack'].invoke
	Rake::Task['nuget:push'].invoke(args.apikey)
end

namespace :nuget do
	nuspec :create do |nuspec|
		nuspec.id = "MyPackage"
		nuspec.version = "0.0.0-alpha"
		nuspec.authors = "Rory Fitzpatrick"
		nuspec.description = "My awesome package"
		nuspec.title = "MyPackage"
		nuspec.projectUrl = "https://github.com/roryf/nuget-boilerplate"
		nuspec.tags = "nuget"
		nuspec.working_directory = "release"
		nuspec.output_file = "MyPackage.nuspec"
		nuspec.copyright = "Rory Fitzpatrick"
	end
	
	nugetpack :pack do |nuget|
		nuget.command = ".nuget/Nuget.exe"
		nuget.nuspec = "release/MyPackage.nuspec"
		nuget.base_folder = "release"
		nuget.output = "release"
	end
	
	nugetpush :push, [:apikey] do |nuget, args|
		nuget.command = ".nuget/Nuget.exe"
		nuget.package = "release\\MyPackage.0.0.0-alpha.nupkg"
		nuget.apikey = args.apikey
	end
end