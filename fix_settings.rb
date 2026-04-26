require 'xcodeproj'
project_path = 'NetworkImplementation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  debug_settings = target.build_configurations.find { |c| c.name == 'Debug' }.build_settings.clone
  release_settings = target.build_configurations.find { |c| c.name == 'Release' }.build_settings.clone

  ['Debug Development', 'Debug Production'].each do |name|
    config = target.build_configurations.find { |c| c.name == name }
    if config
      # merge existing specific settings (like INFOPLIST_KEY) over the base debug_settings
      merged_settings = debug_settings.merge(config.build_settings)
      
      # For different environments, we usually want different bundle identifiers
      # Let's keep the base bundle identifier but perhaps we don't need to append suffixes unless user requested.
      
      config.build_settings = merged_settings
    end
  end

  ['Release Development', 'Release Production'].each do |name|
    config = target.build_configurations.find { |c| c.name == name }
    if config
      merged_settings = release_settings.merge(config.build_settings)
      config.build_settings = merged_settings
    end
  end
end

project.save
puts "Fixed settings!"
