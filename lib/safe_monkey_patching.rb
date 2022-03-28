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
      return unless Rails.env.test?

      caller = caller_locations.first.path
      gem_path = Gem::Specification.find do |spec|
        File.fnmatch(File.join(spec.full_gem_path, '*'), caller)
      end&.full_gem_path || Rails.root

      SafeMonkeyPatching::Behavior.add_gem_with_patch(gem_path)

      method = instance_method(method_sym)
      database = SafeMonkeyPatching::Behavior.load_store(File.join(gem_path, 'monkey_patches-new.yml'))

      method_entry = { method.owner.to_s => { method.name.to_s =>
                                                { 'sha1' => Digest::SHA1.hexdigest(method.source),
                                                  'to_s' => method.to_s
                                                } } }

      new_database = database.deep_merge(method_entry)
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
  generate_file = ENV.key?('MONKEY') || ENV.key?('GITHUB_SHA')
  written = false

  SafeMonkeyPatching::Behavior.gems_with_patches.each do |gem_path|
    old_patches = SafeMonkeyPatching::Behavior.load_store(File.join(gem_path, "monkey_patches-old.yml")).sort.to_h.to_yaml
    new_patches = SafeMonkeyPatching::Behavior.load_store(File.join(gem_path, "monkey_patches-new.yml")).sort.to_h.to_yaml

    if generate_file
      File.write(File.join(gem_path, "monkey_patches-old.yml"), old_patches)
      File.write(File.join(gem_path, "monkey_patches-new.yml"), new_patches)

      FileUtils.mv(File.join(gem_path, "monkey_patches-new.yml"),
                   File.join(gem_path, "monkey_patches-old.yml"))
    end

    diff = Diffy::Diff.new(old_patches, new_patches)

    if diff.to_s.size.positive?
      unless written
        written = true
        $stderr.puts
        $stderr.puts "Wrong monkey_patches! Did you changed something?".red.bold
        $stderr.puts "to correct them:"
        $stderr.puts "#{"-".blue.bold} Rerun rspec with variable #{ "MONKEY=1".green }" unless generate_file
        $stderr.puts "#{"-".blue.bold} Commit generated file #{ "monkey_patches-old.yml".green }"
      end

      if generate_file
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
end
