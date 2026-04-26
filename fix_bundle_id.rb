require 'xcodeproj'

project_path = 'NetworkImplementation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = '$(inherited)'
  end
end

project.save
puts "Bundle Identifier is now inherited from xcconfig files!"
