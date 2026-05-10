# This is a smart wrapper to load the actual podhelper from the Flutter SDK
flutter_root = ENV['FLUTTER_ROOT']
if flutter_root.nil? || flutter_root.empty?
  # Fallback for local Windows development if needed, but primarily for CI
  flutter_root = 'C:/flutter' 
end

podhelper_path = File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper.rb')

if File.exist?(podhelper_path)
  load podhelper_path
else
  # If everything fails, try a relative path as a last resort
  load File.expand_path(File.join('..', '..', '..', 'packages', 'flutter_tools', 'bin', 'podhelper.rb'), __FILE__)
end
