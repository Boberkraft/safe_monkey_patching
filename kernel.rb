Kernel.class_exec do
  def monkey_path(method)
    database = begin
                 YAML.load_file('monkey_paths.yml')
               rescue Errno::ENOENT
                 {}
               end
    current = {
      method.owner.to_s => { method.name.to_s =>
                               { 'sha1' => Digest::SHA1.hexdigest(method.source) }
      }
    }
    new_database = database.merge(current)
    File.open('monkey_paths.yml', 'w') { |f| f.puts(new_database.to_yaml) }
  end
end
