require 'fileutils'

Dir.glob("NetworkImplementation.xcodeproj/xcshareddata/xcschemes/NetworkImplementation-*.xcscheme").each do |path|
  xml = File.read(path)
  
  runnable_xml = <<-XML
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "092B0C3E2F9AA71700040204"
            BuildableName = "NetworkImplementation.app"
            BlueprintName = "NetworkImplementation"
            ReferencedContainer = "container:NetworkImplementation.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
XML

  if !xml.include?("<BuildableProductRunnable")
    xml.gsub!(/(<LaunchAction[^>]*>)/, "\\1\n#{runnable_xml}")
    xml.gsub!(/(<ProfileAction[^>]*>)/, "\\1\n#{runnable_xml}")
    File.write(path, xml)
    puts "Fixed #{path}"
  end
end
