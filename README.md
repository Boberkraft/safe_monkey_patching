# safe_monkey_patching

**Przykład**
```ruby
module ActiveJob
  class Base
    attr_accessor :attempt_number

    class << self
      monkey_path # <- o to tutaj
      def deserialize(job_data)
        bla
        ...
        bla
      end
    end
  end
end
````

metoda `#monkey_path` generuje hash kodu źródłowego `#deserialize` (tej oryginalnej) i zapisze go do pliku
```yml
---
ActiveJob::Core::ClassMethods:
  deserialize:
    sha1: c29634da4f1731775868a6eba5efc837dd711a54
```
a więc, gdy podbijemy railsy i zmieni się kod źródłowy, to `gif diff` nam o tym powie 🤩


```diff

diff --git a/monkey_paths.yml b/monkey_paths.yml

 ActiveJob::Core::ClassMethods:
   deserialize:
-    sha1: c29634da4f1731775868a6eba5efc837dd711a54
+    sha1: 131d3acf24768b30a3ccb1052591b1cdb603f0cd
```

Dzięki temu będziemy wiedzieli, że trzeba tam zajrzeć 🥳

