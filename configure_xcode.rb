require 'xcodeproj'

project_path = 'NetworkImplementation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Create or get Config group
config_group = project.main_group.find_subpath('Config', true)

# 2. Add .xcconfig files to the project
dev_xcconfig_path = 'NetworkImplementation/Config/Development.xcconfig'
prod_xcconfig_path = 'NetworkImplementation/Config/Production.xcconfig'

dev_file_ref = config_group.files.find { |f| f.path == dev_xcconfig_path }
unless dev_file_ref
  dev_file_ref = config_group.new_file(dev_xcconfig_path)
end

prod_file_ref = config_group.files.find { |f| f.path == prod_xcconfig_path }
unless prod_file_ref
  prod_file_ref = config_group.new_file(prod_xcconfig_path)
end

# 3. Create or Update Build Configurations
# Instead of 4 configurations, let's stick to adding the missing ones if needed.
# Since we want to map "Development" to Debug and "Production" to Release, 
# or standard practice: "Debug Development", "Release Development", "Debug Production", "Release Production".

def ensure_config(project, name, base_type)
  config = project.build_configurations.find { |c| c.name == name }
  unless config
    config = project.add_build_configuration(name, base_type)
  end
  config
end

debug_dev = ensure_config(project, 'Debug Development', :debug)
release_dev = ensure_config(project, 'Release Development', :release)
debug_prod = ensure_config(project, 'Debug Production', :debug)
release_prod = ensure_config(project, 'Release Production', :release)

debug_dev.base_configuration_reference = dev_file_ref
release_dev.base_configuration_reference = dev_file_ref
debug_prod.base_configuration_reference = prod_file_ref
release_prod.base_configuration_reference = prod_file_ref

# Apply configurations to all targets
project.targets.each do |target|
  target.build_configurations.each do |config|
    if config.name == 'Debug Development' || config.name == 'Release Development'
      config.base_configuration_reference = dev_file_ref
    elsif config.name == 'Debug Production' || config.name == 'Release Production'
      config.base_configuration_reference = prod_file_ref
    end
    
    # Inject INFOPLIST_KEY_* for new configurations
    if ['Debug Development', 'Release Development', 'Debug Production', 'Release Production'].include?(config.name)
      config.build_settings['INFOPLIST_KEY_API_BASE_URL'] = '$(API_BASE_URL)'
      config.build_settings['INFOPLIST_KEY_ENVIRONMENT'] = '$(ENVIRONMENT)'
      config.build_settings['INFOPLIST_KEY_ENABLE_LOGGING'] = '$(ENABLE_LOGGING)'
    end
  end
  
  # Also duplicate configurations in the target if they are missing
  ['Debug Development', 'Release Development', 'Debug Production', 'Release Production'].each do |config_name|
    target_config = target.build_configurations.find { |c| c.name == config_name }
    unless target_config
      base_type = config_name.start_with?('Debug') ? :debug : :release
      target_config = target.add_build_configuration(config_name, base_type)
      
      # Inherit settings from base project config
      target_config.base_configuration_reference = config_name.include?('Development') ? dev_file_ref : prod_file_ref
      target_config.build_settings['INFOPLIST_KEY_API_BASE_URL'] = '$(API_BASE_URL)'
      target_config.build_settings['INFOPLIST_KEY_ENVIRONMENT'] = '$(ENVIRONMENT)'
      target_config.build_settings['INFOPLIST_KEY_ENABLE_LOGGING'] = '$(ENABLE_LOGGING)'
    end
  end
end

project.save
puts "Project modified successfully."

# 4. Create Schemes
# Xcodeproj scheme creation is a bit involved, but we can use Xcodeproj::XCScheme
# The easiest way is to duplicate an existing scheme or create from scratch.

target = project.targets.first
shared_schemes_dir = Xcodeproj::XCScheme.shared_data_dir(project_path)
FileUtils.mkdir_p(shared_schemes_dir)

def create_scheme(name, target, debug_config, release_config, project_path, shared_schemes_dir)
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  
  scheme.launch_action.build_configuration = debug_config
  scheme.test_action.build_configuration = debug_config
  scheme.profile_action.build_configuration = release_config
  scheme.analyze_action.build_configuration = debug_config
  scheme.archive_action.build_configuration = release_config
  
  scheme.save_as(project_path, name, true)
  puts "Created scheme: #{name}"
end

create_scheme('NetworkImplementation-Development', target, 'Debug Development', 'Release Development', project_path, shared_schemes_dir)
create_scheme('NetworkImplementation-Production', target, 'Debug Production', 'Release Production', project_path, shared_schemes_dir)

puts "All done!"
