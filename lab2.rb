require 'java'

class ParallelArray < Array
    def get_bound(i, threads_num)
        result = i * (size / threads_num) + ((size % threads_num > i)? i: (size % threads_num))
    end
    def parallel(threads_num, &handler)
        (0..threads_num - 1).map{|i| 
            yield self[get_bound(i, threads_num) .. get_bound(i + 1, threads_num) - 1]
        }
    end
    def parallel_map(threads_num=2, &handler)
        parallel(threads_num, &handler)
    end
end

class TestParallelArray < ParallelArray
    def test_get_bound_method(threads_num, bounds)
        (0..threads_num).reduce(true){|result, i| 
            if (bounds[i] == get_bound(i, threads_num))
                result
            else
                puts(bounds[i].to_s + "!= (get_bounds(" + i.to_s + ", " + threads_num.to_s + ") = " + 
                    get_bound(i, threads_num).to_s + ")")
                false
            end
        }
    end
end

def test_get_bound_method()
    array = TestParallelArray.new(5, 1)
    {2 => [0, 3, 5], 3 => [0, 2, 4, 5]}.map{ |threads_num, bounds|
        array.test_get_bound_method(threads_num, bounds)
    }.reduce{|result, test| (result and test) }
end

array = ParallelArray.new([1, 2, 3, 4, 5])

puts("Test get_bound_method: " + test_get_bound_method.to_s)
#puts(array.map{|i| i + 1})
array.parallel(2){|i| puts(i.to_s)}
