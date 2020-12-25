# safe_monkey_patching

This
```ruby
module ActiveJob
  class Base
    attr_accessor :attempt_number

    class << self
      monkey_path instance_method(:deserialize)
      def deserialize(job_data)
        job = super
        job.send(:attempt_number=, (job_data['attempt_number'] || 0))
        job
      end
    end
  end
end
````

creates this:
```yml
---
ActiveJob::Core::ClassMethods:
  deserialize:
    sha1: c29634da4f1731775868a6eba5efc837dd711a54
```
