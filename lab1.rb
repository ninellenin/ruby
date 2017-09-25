def getStrings(letters, n)
    (0..n-2).reduce(letters) {|result, position| 
        (0..result.count - 1).map {|i| 
            letters.select {|l| l != result[i][position]}
                .map{ |tail| result[i] + tail}
        }.reduce([]){|flat, element| flat + element}
    }
end

def checkString(string)
    (0..string.length - 2).reduce(true){|check, i| check and string[i] != string[i + 1]}
end

def testStrings(letters, n)
    result = getStrings(letters, n)
    puts("Результат: " + result.to_s)
    puts("Нет двух символов подряд: " + result.reduce(true){|check, string| check and checkString(string)}.to_s)
    m = letters.count
    puts("Количество строк равно m * (m - 1)**(n - 1), где m - количество букв: " + 
        (result.count == m * ((m-1)**(n - 1))).to_s)
    puts("Строки различные: " + (result.uniq.count == result.count).to_s)
end

letters = ['a', 'b', 'c']
testStrings(letters, 5)