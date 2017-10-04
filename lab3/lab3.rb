require 'set'

class DpkgParser
        @@date = '(\d{4})-([0|1]\d)-([0-3]\d)'
        @@time = '([0-2]\d):([0-5]\d):([0-5]\d)'
        @@action = '(install|upgrade|remove|purge|configure|trigproc)'
        @@package_name = '([\w_\-:\.]+)'
        @@file_name = @@package_name
        @@version = '(<нет>|[~+:\w\.\-]+)'
        @@state = '([\-\w]+)'
        @@decision = '(install|keep)'
        @@startup_action = '([\w]+ [\w]+)'
    def parse_line(line)
        if (not (match_data = line.match(/^#{@@date} #{@@time} /)))
            handle_matching_error(line)
        end
        tail = match_data.post_match
        time = Time.new(*match_data[1, 6])
        # <action> <package> <installed_version> <available_version>
        if (match_data = tail.match(/#{@@action} #{@@package_name} #{@@version} #{@@version}$/))
            record = DpkgActionRecord.new(time, *match_data[1, 4])
        # <status <state> <package> <installed_version>
        elsif (match_data = tail.match(/status #{@@state} #{@@package_name} #{@@version}$/))
            record = DpkgStatusRecord.new(time, *match_data[1, 3])
        elsif (match_data = tail.match(/conffile #{@@file_name} #{@@decision}$/))
            record = DpkgConffileChangesRecord.new(time, *match_data[1, 2])
        elsif (match_data = tail.match(/startup #{@@startup_action}$/))
            record = DpkgStartupRecord.new(time, match_data[1])
        else
            handle_matching_error(line)
        end

        record
    end
    def handle_matching_error(line)
        puts("Unknown record: \"#{line[0, line.size - 1]}\"")
    end
end

class DpkgRecord
    def initialize(time)
        @time = time
    end
    def time
        @time
    end
end

class DpkgStartupRecord < DpkgRecord
    def initialize(time, action)
        @action = action
        super(time)
    end
    def action
        @action
    end
end

class DpkgConffileChangesRecord < DpkgRecord
    def initialize(time, file_name, decision)
        @file_name = file_name
        @decision = decision
        super(time)
    end
    def file_name
        @file_name
    end
    def decision
        @decision
    end
end

class DpkgActionRecord < DpkgRecord
    def initialize(time, action, package, installed_version, available_version)
        @action = action
        @package = package
        @installed_version = installed_version
        @available_version = available_version
        super(time)
    end
    def action
        @action
    end
    def package
        @package
    end
    def installed_version
        @installed_version
    end
    def available_version
        @available_version
    end
end

class DpkgStatusRecord < DpkgRecord
    def initialize(time, state, package, installed_version)
        @state = state
        @package = package
        @installed_version = installed_version
        super(time)
    end
    def state
        @state
    end
    def package
        @package
    end
    def installed_version
        @installed_version
    end
end

class DpkgStatistics
    def initialize
        @parser = DpkgParser.new
        @records = []
        @installed_packages = Set.new
        @upgraded_packages = Set.new
        @removed_packages = Set.new
        @up_to_date_packages = Set.new
        @startups = Hash.new
    end
    def add_line(line)
        if (record = @parser.parse_line(line))
            @records.push(record)
            if (record.instance_of? DpkgActionRecord)
                case (record.action)
                when 'install'
                    @installed_packages.add(record.package + ' ' + record.installed_version)
                when 'remove'
                    @removed_packages.add(record.package + ' ' + record.installed_version)
                when 'upgrade'
                    @removed_packages.add(record.package + ' ' + record.installed_version)
                end
                if (record.installed_version == record.available_version)
                    @up_to_date_packages.add(record.package + ' ' + record.available_version)
                end
            end
            if (record.instance_of? DpkgStartupRecord)
                @startups[record.action] = record.time
            end
        end
    end
    def print_all_statistics
        puts("Statistic for #{@records.size} records:")
        print_packages("Up-to-date", @up_to_date_packages)
        print_packages("Installed", @installed_packages)
        print_packages("Removed", @removed_packages)
        print_packages("Upgraded", @upgraded_packages)
        print_startups
    end
    def print_packages(type, packages)
        puts(type + " #{packages.size} packages:")
        p(packages.to_a)
    end
    def print_startups
        puts("Last startups are: ")
        @startups.each{|startup, time| puts("#{time} #{startup}") }
    end
end

f = File.new("dpkg.log.1", :encoding => 'utf-8')
dpkgStatistics = DpkgStatistics.new
f.each do |line|
    dpkgStatistics.add_line(line)
end
f.close
dpkgStatistics.print_all_statistics
