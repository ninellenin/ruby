require 'java'

class ParallelArray < Array
    def parallel(threads_num, &handler)
        (0..threads_num - 1).map{|i| 
            yield self[i + ((size % threads_num > i - 1)? i: (size % threads_num))..
            i - 1 + size / threads_num + ((size % threads_num > i)? (i + 1): (size % threads_num))]
        }
    end
    def parallel_map(threads_num=2, &handler)
        super.map(&handler)
    end
end

array = ParallelArray.new([1, 2, 3, 4, 5])
#puts(array.map{|i| i + 1})
array.parallel(3){|i| puts(i.to_s)}
