# safe_monkey_patching

Przykład
```ruby
module ActiveJob
  class Base
    attr_accessor :attempt_number

    class << self
      monkey_path instance_method(:deserialize)
      def deserialize(job_data)
        bla
        ...
        bla
      end
    end
  end
end
````

metoda `#monkey_path` generuje hash kodu źródłowego `#deserialize` (oryginalnej)
```yml
---
ActiveJob::Core::ClassMethods:
  deserialize:
    sha1: c29634da4f1731775868a6eba5efc837dd711a54
```
a więc, gdy podbijemy railsy, i zmieni się kod źródłowy, to zobaczymy zmianę hasha w `gif diff` 
