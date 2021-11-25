# safe_monkey_patching

**Przykład**
```ruby
module ActiveJob
  class Base
    class << self
      monkey_patch :deserialize

      def deserialize(job_data)
        ...
      end
    end
  end
end
````

metoda `#monkey_patch` generuje hash kodu źródłowego `#deserialize` (tej oryginalnej) i zapisze go do pliku
```yml
---
ActiveJob::Core::ClassMethods:
  deserialize:
    sha1: c29634da4f1731775868a6eba5efc837dd711a54
```
a więc, gdy podbijemy railsy i zmieni się kod źródłowy, to `gif diff` nam o tym powie 🤩


```diff

diff --git a/monkey_patches-old.yml b/monkey_patches-old.yml

 ActiveJob::Core::ClassMethods:
   deserialize:
-    sha1: c29634da4f1731775868a6eba5efc837dd711a54
+    sha1: 131d3acf24768b30a3ccb1052591b1cdb603f0cd
```

Również pojawi się plik `WRONG_MONKEY_PATCHES.txt`, który pokazuje niekompatybilności z gemów.

Dzięki temu będziemy wiedzieli do jakich metod trzeba będzie zajrzeć 🥳

Aby zaktualizować monkey_patche, to trzeba po prostu zcomitować ten plik `monkey_patches-old.yml` i będzie git.

