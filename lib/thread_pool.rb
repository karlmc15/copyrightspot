require 'rubygems'
require 'thread'
require 'net/http'
require 'hpricot'

class ThreadPool
  
  def initialize(max_size)
    @pool = []
    @max_size = max_size
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
  end
  
  def dispatch(*args)
    Thread.new do
      # wait for space in the pool
      @pool_mutex.synchronize do
        while @pool.size >= @max_size
          # Sleep until some other thread calls @pool_cv.signal
          @pool_cv.wait(@pool_mutex)
        end
      end
      @pool << Thread.current
      begin
        yield(*args)
      rescue => e
        #exception(self, e, *args)
        puts "exception caught in thread #{thread}: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
      ensure
        @pool_mutex.synchronize do
          # remove thread from current pool
          @pool.delete(Thread.current)
          # Signal the next waiting thread that there's a space in the pool
          @pool_cv.signal
        end
      end
    end # end of Thread.new block
  end
  
  def shutdown
    @pool_mutex.synchronize { @pool_cv.wait(@pool_mutex) until @pool.empty? }
  end
  
  def exception(thread, exception, *original_args)
    # Subclass this method to handle an Exception within a thread
    puts "Exception in thread #{thread}: #{exception}"
  end
  
end

# pool = ThreadPool.new(3)
# @count = 0
# 1.upto(5){|i| pool.dispatch(i){|i| @count += (10 * i)}}
# print @count
# pool.shutdown
