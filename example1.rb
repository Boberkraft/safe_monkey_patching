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

