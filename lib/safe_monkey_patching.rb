module SafeMonkeyPatching
  module Behavior
    class << self
      def load_store(path)
        begin
          YAML.load_file(path)
        rescue Errno::ENOENT
          {}
        end
      end

      def gems_with_patches
        (@gem_paths || []).uniq
      end

      def add_gem_with_patch(path)
        @gem_paths ||= []
        @gem_paths << path
      end
    end

    where = ENV.fetch('SAFE_MONKEY_PATCHING_STORE_PATH', '.')
    ERROR_LOCATION = File.join(where, "WRONG_MONKEY_PATCHES.txt")

    unless ENV['GITHUB_SHA']
      begin
        File.delete(ERROR_LOCATION)
      rescue Errno::ENOENT
      end
    end

    def monkey_patch(method_sym)
      caller = caller_locations.first.path
      gem_path = Gem::Specification.find do |spec|
        File.fnmatch(File.join(spec.full_gem_path, '*'), caller)
      end&.full_gem_path || Rails.root

      SafeMonkeyPatching::Behavior.add_gem_with_patch(gem_path)
      return unless Rails.env.test?

      method = instance_method(method_sym)
      database = SafeMonkeyPatching::Behavior.load_store(File.join(gem_path, 'monkey_patches-new.yml'))

      method_entry = { method.owner.to_s => { method.name.to_s =>
                                                { 'sha1' => Digest::SHA1.hexdigest(method.source) } } }

      new_database = database.merge(method_entry)
      File.open(File.join(gem_path, 'monkey_patches-new.yml'), 'w') do |f|
        f.puts(new_database.to_yaml)
      end
    end
  end
end

class Object
  prepend SafeMonkeyPatching::Behavior
end

at_exit do
  return unless Rails.env.test?
  SafeMonkeyPatching::Behavior.gems_with_patches.each do |gem_path|
    old_patches = SafeMonkeyPatching::Behavior.load_store(File.join(gem_path, "monkey_patches-old.yml")).to_yaml
    new_patches = SafeMonkeyPatching::Behavior.load_store(File.join(gem_path, "monkey_patches-new.yml")).to_yaml

    FileUtils.mv(File.join(gem_path, "monkey_patches-new.yml"),
                 File.join(gem_path, "monkey_patches-old.yml"))

    diff = Diffy::Diff.new(old_patches, new_patches)

    if diff.to_s.size.positive?
      $stderr.puts 'Wrong monkeypatches!'.red.bold
      $stderr.puts gem_path
      $stderr.puts diff.to_s(:color)

      open(ERROR_LOCATION, 'a') do |f|
        f.puts("\n")
        f.puts(gem_path)
        f.puts(diff.to_s)
      end
    end
  end
end
