module SafeMonkeyPatching
  module Behavior
    def monkey_path(method_sym)
      method = instance_method(method_sym)
      database = begin
                   YAML.load_file('monkey_paths.yml')
                 rescue Errno::ENOENT
                   {}
                 end
      method_entry = { method.owner.to_s => { method.name.to_s =>
                                                { 'sha1' => Digest::SHA1.hexdigest(method.source) } } }

      new_database = database.merge(method_entry)
      File.open('monkey_paths.yml', 'w') { |f| f.puts(new_database.to_yaml) }
    end
  end
end

class Object
  prepend SafeMonkeyPatching::Behavior
end