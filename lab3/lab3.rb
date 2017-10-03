f = File.new("dpkg.log.1", :encoding => 'utf-8')
f.each do |line|
    date = '(\d{4})-([01]\d)-([0-3]\d)'
    time = '([0-2]\d):([0-5]\d):([0-5]\d)'
    keyword = '([a-z]+)'
    package_name = '([\w_-:\.]+)'
    version = '([\w\.-]+):'
    puts(line)
    match_data = line.match(/^#{date} #{time} #{keyword} /)
    tail = match_data.post_match
    break
end
f.close

class DpkgLogger
    def __initialize__
        @@date = '(\d{4})-([0|1]\d)-([0-3]\d)'
        @@time = '([0-2]\d):([0-5]\d):([0-5]\d)'
        @@keyword = '([a-z]+)'
        @@package_name = '([\w_-:\.]+)'
        @@version = '([\w\.-]+):'
    end
    def parse_line(line)

    end
end

class DpkgRecord
    def __initialize__(time)
        @time = time
    end
end

class DpkgActionRecord < DpkgRecord
    def __initialize__(time, action)
        @action = action
        super(time)
    end
end

class DpkgStatusRecord < DpkgRecord
    def __initialize__(time, status)
        super(time)
    end
end

puts(Time.new("2017-10-01 17:02:22"))

