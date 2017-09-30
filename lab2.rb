require 'java'

class ParallelArray < Array
    def get_bound(i, threads_num)
        result = i * (size / threads_num) + ((size % threads_num > i)? i: (size % threads_num))
    end
    def parallel(threads_num, &handler)
        result = {}
        (0..threads_num - 1).map{|i| 
            new_thread = java.lang.Thread.new {
                result[i] = yield self[get_bound(i, threads_num) .. get_bound(i + 1, threads_num) - 1]
            }
            new_thread.run
            [i, new_thread]
        }.map{|thread| 
            thread[1].join 
            result[thread[0]]}
    end
    def parallel_any(threads_num=2, &handler)
        result = parallel(threads_num) {
            |sub_array| sub_array.any?(&handler)
        }
        result.any?
    end
    def parallel_all(threads_num=2,&handler)
        result = parallel(threads_num) {
            |sub_array| sub_array.all?(&handler)
        }
        result.all?
    end
    def parallel_map(threads_num=2, &handler)
        result = parallel(threads_num){|sub_array| sub_array.map(&handler)}
        result.flatten(1)
    end
    def parallel_select(threads_num=2, &handler)
        result = parallel(threads_num) {|sub_array| sub_array.select(&handler)}
        result.flatten(1)
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

def test()
    puts("Test get_bound_method: " + test_get_bound_method.to_s)
    array = ParallelArray.new([1, 2, 3, 4, 5])
    puts("Test parallel map: "+ (array.parallel_map(2){|i| i + 1} == [2, 3, 4, 5, 6]).to_s)
    puts("Test parallel any: " + (array.parallel_any(3){|i| i > 3} == true and 
        array.parallel_any(3){|i| i < 1} == false).to_s)
    puts("Test parallel all: " + (array.parallel_all(3){|i| i > 3} == false and 
        array.parallel_all(3){|i| i > 0} == true).to_s)
    puts("Test parallel select: " + (array.parallel_select(3){|i| i % 2 == 1 } == [1, 3, 5]).to_s)
end

test