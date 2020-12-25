Kernel.class_exec do
  def monkey_path(method)
    database = if File.exists?('monkey_paths.yml')
                 YAML.load_file('monkey_paths.yml')
               else
                 {}
               end
    current = { method.owner.to_s => { method.name.to_s => { 'sha1' => Digest::SHA1.hexdigest(method.source) } }
    }
    new_database = database.merge(current)
    File.open('monkey_paths.yml', 'w') { |f| f.puts(new_database.to_yaml) }
    puts 'ok!'
  end
end
